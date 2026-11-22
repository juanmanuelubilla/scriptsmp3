#!/usr/bin/env python3
"""Interfaz gráfica multiplataforma para conversión de audio."""

from __future__ import annotations

import os
import sys
import threading
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

from pathlib import Path

from gui.converter import (
    DEFAULT_BITRATE,
    PIPELINES,
    JobOptions,
    Pipeline,
    check_dependencies,
    run_job,
)


class AudioConverterApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Conversor de audio")
        self.minsize(640, 520)
        self._cancel = threading.Event()
        self._worker: threading.Thread | None = None

        self.dir_var = tk.StringVar(
            value=os.environ.get("AUDIO_CONVERTER_DIR", "")
        )
        self.pipeline_var = tk.StringVar(value=PIPELINES[0].id)
        self.bitrate_var = tk.StringVar(
            value=str(DEFAULT_BITRATE.get(PIPELINES[0].id, 128) or 128)
        )
        self.workers_var = tk.IntVar(value=max(1, (os.cpu_count() or 4) - 1))

        self.opt_rename = tk.BooleanVar(value=True)
        self.opt_extract = tk.BooleanVar(value=True)
        self.opt_convert = tk.BooleanVar(value=True)
        self.opt_import_cover = tk.BooleanVar(value=True)
        self.opt_import_meta = tk.BooleanVar(value=True)
        self.opt_delete_jpg = tk.BooleanVar(value=True)
        self.opt_delete_source = tk.BooleanVar(value=False)

        self._build_ui()
        self._check_deps()

    def _build_ui(self) -> None:
        pad = {"padx": 8, "pady": 4}
        main = ttk.Frame(self, padding=10)
        main.pack(fill=tk.BOTH, expand=True)

        # Directorio
        row = ttk.Frame(main)
        row.pack(fill=tk.X, **pad)
        ttk.Label(row, text="Carpeta:").pack(side=tk.LEFT)
        ttk.Entry(row, textvariable=self.dir_var).pack(
            side=tk.LEFT, fill=tk.X, expand=True, padx=(6, 6)
        )
        ttk.Button(row, text="Examinar…", command=self._browse).pack(side=tk.LEFT)

        # Pipeline y bitrate
        opts = ttk.LabelFrame(main, text="Tipo de conversión", padding=8)
        opts.pack(fill=tk.X, **pad)

        for p in PIPELINES:
            ttk.Radiobutton(
                opts,
                text=p.label,
                variable=self.pipeline_var,
                value=p.id,
                command=self._on_pipeline_change,
            ).pack(anchor=tk.W)

        br_row = ttk.Frame(opts)
        br_row.pack(fill=tk.X, pady=(8, 0))
        ttk.Label(br_row, text="Bitrate (kbps):").pack(side=tk.LEFT)
        self.bitrate_combo = ttk.Combobox(
            br_row,
            textvariable=self.bitrate_var,
            values=["64", "96", "128", "192", "256", "320"],
            width=8,
            state="readonly",
        )
        self.bitrate_combo.pack(side=tk.LEFT, padx=6)
        ttk.Label(br_row, text="Hilos:").pack(side=tk.LEFT, padx=(16, 0))
        ttk.Spinbox(
            br_row,
            from_=1,
            to=32,
            textvariable=self.workers_var,
            width=5,
        ).pack(side=tk.LEFT, padx=6)

        # Pasos
        steps = ttk.LabelFrame(main, text="Pasos a ejecutar", padding=8)
        steps.pack(fill=tk.X, **pad)
        for text, var in [
            ("Renombrar archivos (quitar caracteres raros)", self.opt_rename),
            ("Extraer carátulas del audio origen", self.opt_extract),
            ("Convertir formato", self.opt_convert),
            ("Importar carátulas al archivo destino", self.opt_import_cover),
            ("Copiar metadata al archivo destino", self.opt_import_meta),
            ("Borrar JPG/PNG extraídos", self.opt_delete_jpg),
            ("Eliminar archivos origen (¡irreversible!)", self.opt_delete_source),
        ]:
            ttk.Checkbutton(steps, text=text, variable=var).pack(anchor=tk.W)

        # Progreso y log
        self.progress = ttk.Progressbar(main, mode="determinate")
        self.progress.pack(fill=tk.X, **pad)

        log_frame = ttk.LabelFrame(main, text="Registro", padding=4)
        log_frame.pack(fill=tk.BOTH, expand=True, **pad)
        self.log_text = tk.Text(log_frame, height=12, wrap=tk.WORD, state=tk.DISABLED)
        scroll = ttk.Scrollbar(log_frame, command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=scroll.set)
        self.log_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scroll.pack(side=tk.RIGHT, fill=tk.Y)

        # Botones
        btns = ttk.Frame(main)
        btns.pack(fill=tk.X, **pad)
        self.btn_run = ttk.Button(btns, text="Iniciar", command=self._start)
        self.btn_run.pack(side=tk.LEFT)
        self.btn_cancel = ttk.Button(
            btns, text="Cancelar", command=self._cancel_job, state=tk.DISABLED
        )
        self.btn_cancel.pack(side=tk.LEFT, padx=8)
        ttk.Button(btns, text="Salir", command=self.destroy).pack(side=tk.RIGHT)

    def _check_deps(self) -> None:
        missing = check_dependencies()
        if missing:
            self._log("Dependencias faltantes:")
            for m in missing:
                self._log(f"  • {m}")
            self._log("Instala ffmpeg y: pip install mutagen")

    def _browse(self) -> None:
        path = filedialog.askdirectory(title="Seleccionar carpeta de audio")
        if path:
            self.dir_var.set(path)

    def _on_pipeline_change(self) -> None:
        pid = self.pipeline_var.get()
        if pid == "mp3_ogg":
            self.bitrate_combo.configure(state="disabled")
            self.bitrate_var.set("—")
        else:
            self.bitrate_combo.configure(state="readonly")
            default = DEFAULT_BITRATE.get(pid, 128)
            self.bitrate_var.set(str(default))

    def _selected_pipeline(self) -> Pipeline:
        pid = self.pipeline_var.get()
        for p in PIPELINES:
            if p.id == pid:
                return p
        return PIPELINES[0]

    def _log(self, msg: str) -> None:
        def append() -> None:
            self.log_text.configure(state=tk.NORMAL)
            self.log_text.insert(tk.END, msg + "\n")
            self.log_text.see(tk.END)
            self.log_text.configure(state=tk.DISABLED)

        self.after(0, append)

    def _set_running(self, running: bool) -> None:
        state = tk.DISABLED if running else tk.NORMAL
        self.btn_run.configure(state=state)
        self.btn_cancel.configure(state=tk.NORMAL if running else tk.DISABLED)

    def _cancel_job(self) -> None:
        self._cancel.set()
        self._log("Cancelando…")

    def _start(self) -> None:
        root = self.dir_var.get().strip()
        if not root or not os.path.isdir(root):
            messagebox.showerror("Error", "Selecciona una carpeta válida.")
            return

        missing = check_dependencies()
        if missing:
            messagebox.showerror(
                "Dependencias",
                "Faltan:\n" + "\n".join(missing) + "\n\nInstala ffmpeg y mutagen.",
            )
            return

        if self.opt_delete_source.get():
            if not messagebox.askyesno(
                "Confirmar",
                "Se eliminarán los archivos origen. ¿Continuar?",
                icon=messagebox.WARNING,
            ):
                return

        if self._worker and self._worker.is_alive():
            return

        self._cancel.clear()
        self.progress["value"] = 0
        self._set_running(True)

        pipeline = self._selected_pipeline()
        pid = self.pipeline_var.get()
        if pid == "mp3_ogg":
            bitrate = 0
        else:
            try:
                bitrate = int(self.bitrate_var.get())
            except ValueError:
                bitrate = DEFAULT_BITRATE.get(pid, 128)

        opts = JobOptions(
            root=Path(root),
            pipeline=pipeline,
            bitrate=bitrate,
            rename_files=self.opt_rename.get(),
            extract_covers=self.opt_extract.get(),
            convert_audio=self.opt_convert.get(),
            import_covers=self.opt_import_cover.get(),
            import_metadata=self.opt_import_meta.get(),
            delete_jpg=self.opt_delete_jpg.get(),
            delete_source=self.opt_delete_source.get(),
            workers=int(self.workers_var.get()),
        )

        def task() -> None:
            try:
                run_job(
                    opts,
                    log=lambda m: self._log(m),
                    on_progress=lambda d, t: self.after(
                        0, lambda: self._update_progress(d, t)
                    ),
                    cancel_event=self._cancel.is_set,
                )
                if not self._cancel.is_set():
                    self._log("Proceso finalizado.")
            except Exception as exc:
                self._log(f"Error fatal: {exc}")
            finally:
                self.after(0, lambda: self._set_running(False))

        self._worker = threading.Thread(target=task, daemon=True)
        self._worker.start()

    def _update_progress(self, done: int, total: int) -> None:
        if total > 0:
            self.progress["maximum"] = total
            self.progress["value"] = done


def main() -> None:
    app = AudioConverterApp()
    app.mainloop()


if __name__ == "__main__":
    main()
