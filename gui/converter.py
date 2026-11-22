"""Lógica de conversión de audio multiplataforma (ffmpeg + mutagen)."""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import unicodedata
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable

try:
    from mutagen import File as MutagenFile
    from mutagen.flac import Picture
    from mutagen.mp4 import MP4, MP4Cover
    from mutagen.id3 import APIC, ID3
    from mutagen.oggvorbis import OggVorbis
except ImportError:
    MutagenFile = None  # type: ignore

LogFn = Callable[[str], None]
ProgressFn = Callable[[int, int], None]

AUDIO_EXTENSIONS = {".mp3", ".ogg", ".m4a", ".flac", ".wav", ".aac", ".wma"}


@dataclass
class Pipeline:
    id: str
    label: str
    source_ext: str
    target_ext: str


PIPELINES = [
    Pipeline("mp3_ogg", "MP3 → OGG", ".mp3", ".ogg"),
    Pipeline("ogg_m4a", "OGG → M4A (auto)", ".ogg", ".m4a"),
    Pipeline("mp3_m4a", "MP3 → M4A (auto)", ".mp3", ".m4a"),
    Pipeline("ogg_mp3", "OGG → MP3", ".ogg", ".mp3"),
]

# Bitrate por defecto alineado con los scripts bash
DEFAULT_BITRATE = {
    "mp3_ogg": 0,  # libvorbis -q:a 4, no usa bitrate fijo
    "ogg_m4a": 96,
    "mp3_m4a": 128,
    "ogg_mp3": 128,
}


def ffmpeg_path() -> str | None:
    return shutil.which("ffmpeg")


def check_dependencies() -> list[str]:
    missing = []
    if not ffmpeg_path():
        missing.append("ffmpeg (no está en PATH)")
    if MutagenFile is None:
        missing.append("mutagen (pip install mutagen)")
    return missing


def _run(cmd: list[str], log: LogFn) -> bool:
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        if proc.returncode != 0:
            tail = (proc.stderr or proc.stdout or "").strip().splitlines()
            msg = tail[-1] if tail else f"código {proc.returncode}"
            log(f"Error: {' '.join(cmd[:4])}… — {msg}")
            return False
        return True
    except FileNotFoundError:
        log("ffmpeg no encontrado en PATH")
        return False


def clean_filename(path: Path) -> Path | None:
    parent = path.parent
    name = path.name
    normalized = unicodedata.normalize("NFKD", name)
    ascii_name = normalized.encode("ascii", "ignore").decode("ascii")
    cleaned = re.sub(r"[^A-Za-z0-9._\- ]", "", ascii_name).strip()
    if not cleaned or cleaned == name:
        return None
    target = parent / cleaned
    if target.exists():
        return None
    path.rename(target)
    return target


def find_audio_files(root: Path, extension: str) -> list[Path]:
    ext = extension.lower()
    return sorted(
        p for p in root.rglob("*") if p.is_file() and p.suffix.lower() == ext
    )


def cover_candidates(audio_file: Path) -> list[Path]:
    stem = audio_file.with_suffix("")
    folder = audio_file.parent
    names = [
        stem.with_suffix(".jpg"),
        stem.with_suffix(".png"),
        folder / "cover.jpg",
        folder / "cover.png",
    ]
    return [p for p in names if p.is_file()]


def extract_cover(audio_file: Path, log: LogFn) -> Path | None:
    out = audio_file.with_suffix(".jpg")
    if out.exists():
        return out
    cmd = [
        ffmpeg_path() or "ffmpeg",
        "-y",
        "-i",
        str(audio_file),
        "-an",
        "-vframes",
        "1",
        str(out),
    ]
    if _run(cmd, log):
        if out.exists() and out.stat().st_size > 0:
            log(f"Cover extraído: {audio_file.name}")
            return out
    if out.exists():
        out.unlink(missing_ok=True)
    return None


def convert_file(
    src: Path,
    dst: Path,
    pipeline: Pipeline,
    bitrate_kbps: int,
    log: LogFn,
) -> bool:
    if dst.exists():
        log(f"[omitido] Ya existe: {dst.name}")
        return True

    ff = ffmpeg_path() or "ffmpeg"
    br = str(bitrate_kbps)

    if pipeline.id == "mp3_ogg":
        cmd = [
            ff,
            "-y",
            "-i",
            str(src),
            "-map",
            "0:a",
            "-c:a",
            "libvorbis",
            "-q:a",
            "4",
            "-map_metadata",
            "0",
            "-map_metadata",
            "0:s:a:0",
            str(dst),
        ]
    elif pipeline.id == "ogg_mp3":
        cmd = [
            ff,
            "-y",
            "-i",
            str(src),
            "-map",
            "0:a",
            "-c:a",
            "libmp3lame",
            "-b:a",
            f"{br}k",
            "-id3v2_version",
            "3",
            "-map_metadata",
            "0",
            "-map_metadata",
            "0:s:a:0",
            str(dst),
        ]
    elif pipeline.id in ("ogg_m4a", "mp3_m4a"):
        cmd = [
            ff,
            "-y",
            "-i",
            str(src),
            "-map",
            "0:a",
            "-c:a",
            "aac",
            "-b:a",
            f"{br}k",
            "-movflags",
            "+faststart",
            "-map_metadata",
            "0",
            "-map_metadata",
            "0:s:a:0",
            str(dst),
        ]
    else:
        log(f"Pipeline desconocido: {pipeline.id}")
        return False

    ok = _run(cmd, log)
    if ok:
        log(f"[OK] {src.name} → {dst.name}")
    return ok


def import_cover_ffmpeg(audio: Path, cover: Path, log: LogFn) -> bool:
    ff = ffmpeg_path() or "ffmpeg"
    tmp = audio.with_name(f"{audio.stem}_cover_tmp{audio.suffix}")
    ext = audio.suffix.lower()

    if ext == ".mp3":
        cmd = [
            ff,
            "-y",
            "-i",
            str(audio),
            "-i",
            str(cover),
            "-map",
            "0:a",
            "-map",
            "1:v",
            "-c",
            "copy",
            "-id3v2_version",
            "3",
            "-map_metadata",
            "0",
            "-map_metadata",
            "0:s:a:0",
            "-disposition:v:0",
            "attached_pic",
            str(tmp),
        ]
    elif ext in (".m4a", ".mp4"):
        cmd = [
            ff,
            "-y",
            "-i",
            str(audio),
            "-i",
            str(cover),
            "-map",
            "0:a",
            "-map",
            "1:v",
            "-c",
            "copy",
            "-map_metadata",
            "0",
            "-map_metadata",
            "0:s:a:0",
            "-disposition:v:0",
            "attached_pic",
            str(tmp),
        ]
    elif ext == ".ogg":
        cmd = [
            ff,
            "-y",
            "-i",
            str(audio),
            "-i",
            str(cover),
            "-map",
            "0:a",
            "-map",
            "1:v",
            "-c:a",
            "copy",
            "-c:v",
            "libtheora",
            "-map_metadata",
            "0",
            "-map_metadata",
            "0:s:a:0",
            "-disposition:v:0",
            "attached_pic",
            str(tmp),
        ]
    else:
        log(f"Formato sin soporte de carátula: {audio}")
        return False

    if not _run(cmd, log):
        tmp.unlink(missing_ok=True)
        return False
    tmp.replace(audio)
    log(f"Carátula importada: {audio.name}")
    return True


def _tag_dict(audio: Path) -> dict[str, str]:
    if MutagenFile is None:
        return {}
    audio_file = MutagenFile(str(audio), easy=True)
    if audio_file is None:
        return {}
    keys = ("tracknumber", "artist", "title", "album", "genre", "date")
    out: dict[str, str] = {}
    for key in keys:
        val = audio_file.get(key)
        if val:
            if isinstance(val, list):
                val = val[0]
            out[key] = str(val)
    return out


def import_metadata(source: Path, target: Path, log: LogFn) -> bool:
    if MutagenFile is None:
        log("mutagen no instalado; omitiendo metadata")
        return False
    if not target.is_file():
        log(f"No existe destino para metadata: {target.name}")
        return False

    tags = _tag_dict(source)
    if not tags:
        return False

    ext = target.suffix.lower()
    try:
        if ext == ".mp3":
            try:
                id3 = ID3(str(target))
            except Exception:
                id3 = ID3()
            mapping = {
                "tracknumber": "TRCK",
                "artist": "TPE1",
                "title": "TIT2",
                "album": "TALB",
                "genre": "TCON",
                "date": "TDRC",
            }
            for k, frame in mapping.items():
                if k in tags:
                    id3[frame] = tags[k]
            id3.save(str(target))
        elif ext == ".m4a":
            mp4 = MP4(str(target))
            mp4["\xa9nam"] = tags.get("title", "")
            mp4["\xa9ART"] = tags.get("artist", "")
            mp4["\xa9alb"] = tags.get("album", "")
            mp4["\xa9gen"] = tags.get("genre", "")
            if "date" in tags:
                mp4["\xa9day"] = tags["date"]
            if "tracknumber" in tags:
                mp4["trkn"] = [(int(re.sub(r"\D.*", "", tags["tracknumber"]) or "0"), 0)]
            mp4.save()
        elif ext == ".ogg":
            ogg = OggVorbis(str(target))
            ogg["tracknumber"] = tags.get("tracknumber", "")
            ogg["artist"] = tags.get("artist", "")
            ogg["title"] = tags.get("title", "")
            ogg["album"] = tags.get("album", "")
            ogg["genre"] = tags.get("genre", "")
            ogg["date"] = tags.get("date", "")
            ogg.save()
        else:
            return False
        log(f"Metadata: {source.name} → {target.name}")
        return True
    except Exception as exc:
        log(f"Metadata falló ({target.name}): {exc}")
        return False


@dataclass
class JobOptions:
    root: Path
    pipeline: Pipeline
    bitrate: int
    rename_files: bool
    extract_covers: bool
    convert_audio: bool
    import_covers: bool
    import_metadata: bool
    delete_jpg: bool
    delete_source: bool
    workers: int


def _parallel_map(
    items: Iterable[Path],
    worker: Callable[[Path], None],
    workers: int,
    on_progress: ProgressFn | None,
) -> None:
    items = list(items)
    total = len(items)
    if total == 0:
        return
    done = 0
    with ThreadPoolExecutor(max_workers=max(1, workers)) as pool:
        futures = [pool.submit(worker, item) for item in items]
        for fut in as_completed(futures):
            fut.result()
            done += 1
            if on_progress:
                on_progress(done, total)


def run_job(
    opts: JobOptions,
    log: LogFn,
    on_progress: ProgressFn | None = None,
    cancel_event: Callable[[], bool] | None = None,
) -> None:
    root = opts.root.resolve()
    if not root.is_dir():
        raise ValueError(f"No es un directorio: {root}")

    def cancelled() -> bool:
        return cancel_event is not None and cancel_event()

    if opts.rename_files:
        log("Renombrando archivos…")
        all_files = [p for p in root.rglob("*") if p.is_file()]
        for i, path in enumerate(all_files, 1):
            if cancelled():
                return
            new = clean_filename(path)
            if new:
                log(f"Renombrado: {path.name} → {new.name}")
            if on_progress and all_files:
                on_progress(i, len(all_files))

    sources = find_audio_files(root, opts.pipeline.source_ext)
    log(f"Encontrados {len(sources)} archivo(s) {opts.pipeline.source_ext}")

    if opts.extract_covers:
        log("Extrayendo carátulas…")

        def _extract(p: Path) -> None:
            if not cancelled():
                extract_cover(p, log)

        _parallel_map(sources, _extract, opts.workers, on_progress)

    if opts.convert_audio:
        log(f"Convirtiendo a {opts.pipeline.target_ext}…")

        def _convert(p: Path) -> None:
            if cancelled():
                return
            dst = p.with_suffix(opts.pipeline.target_ext)
            convert_file(p, dst, opts.pipeline, opts.bitrate, log)

        _parallel_map(sources, _convert, opts.workers, on_progress)

    targets = find_audio_files(root, opts.pipeline.target_ext)

    if opts.import_covers:
        log("Importando carátulas…")

        def _import_cover(tgt: Path) -> None:
            if cancelled():
                return
            src_stem = tgt.with_suffix(opts.pipeline.source_ext)
            covers = cover_candidates(src_stem if src_stem.is_file() else tgt)
            if not covers:
                covers = cover_candidates(tgt)
            if covers:
                import_cover_ffmpeg(tgt, covers[0], log)

        _parallel_map(targets, _import_cover, opts.workers, on_progress)

    if opts.import_metadata:
        log("Importando metadata…")

        def _import_meta(src: Path) -> None:
            if cancelled():
                return
            dst = src.with_suffix(opts.pipeline.target_ext)
            if dst.is_file():
                import_metadata(src, dst, log)

        _parallel_map(sources, _import_meta, opts.workers, on_progress)

    if opts.delete_jpg:
        log("Eliminando JPG/PNG de carátula…")
        stems = {p.stem for p in sources} | {p.stem for p in targets}
        for pattern in ("*.jpg", "*.png"):
            for img in root.rglob(pattern):
                if img.is_file() and img.stem in stems:
                    img.unlink(missing_ok=True)
                    log(f"Eliminado: {img.name}")

    if opts.delete_source:
        log(f"Eliminando originales {opts.pipeline.source_ext}…")
        for src in sources:
            if cancelled():
                return
            if src.is_file():
                src.unlink(missing_ok=True)
                log(f"Eliminado: {src.name}")
