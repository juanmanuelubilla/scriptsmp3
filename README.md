# Scripts de conversión de audio

Colección de scripts Bash (Linux) y una interfaz gráfica en Python multiplataforma para convertir bibliotecas de música con carátulas y metadata.

## Requisitos

### Scripts Bash (Debian 12 / 13)

Paquetes instalados automáticamente vía `lib/install_deps.sh` (solo los disponibles en apt):

| Uso | Paquetes principales |
|-----|----------------------|
| OGG/M4A, MP3/M4A | `ffmpeg`, `atomicparsley`, `mediainfo`, `parallel` |
| OGG → MP3 | `ffmpeg`, `lame`, `eyed3`, `vorbis-tools` |
| MP3 → OGG | `ffmpeg`, `dir2ogg`, `flac`, `lame`, … |

**Nota Debian 13:** `faac` y `fdkaac` ya no están en los repositorios. Las conversiones a M4A usan **ffmpeg** con codec AAC.

- Varios scripts piden ejecutarse como **root** (`sudo ./inicio.sh`).

### Interfaz gráfica (Windows, macOS, Linux)

- [FFmpeg](https://ffmpeg.org/download.html) en el `PATH`
- Python 3.10+
- [mutagen](https://mutagen.readthedocs.io/): `pip install -r requirements-gui.txt`

## Uso rápido — Punto de entrada

**Empieza siempre por:**

```bash
chmod +x inicio.sh convertogg.sh convertm4a.sh convertmp3.sh convertmp3_to_m4a.sh
sudo ./inicio.sh
```

`inicio.sh` hace lo siguiente:

1. Pide carpeta de origen (y destino opcional para copiar antes de convertir).
2. Ofrece instalar **todas** las dependencias apt (`install_deps_all`).
3. Menú con conversión bash **o** interfaz gráfica Python.

| Opción | Descripción |
|--------|-------------|
| 1 | MP3 → OGG (bash + dir2ogg) |
| 2 | OGG → M4A (bash + ffmpeg) |
| 3 | MP3 → M4A (bash + ffmpeg) |
| 4 | OGG → MP3 (bash + ffmpeg) |
| 5 | **Interfaz gráfica** (Python/tkinter) |
| 8 | Reinstalar dependencias del sistema |

Cada script `convert*.sh` también instala lo que necesita si falta algo.

## Uso directo — Bash (sin inicio.sh)

| Opción | Descripción |
|--------|-------------|
| — | Ver tabla anterior; mismos flujos vía `convertogg.sh`, etc. |

También puedes invocar cada flujo directamente:

```bash
sudo ./convertogg.sh /ruta/a/musica
sudo ./convertm4a.sh /ruta/a/musica [bitrate]
sudo ./convertmp3_to_m4a.sh /ruta/a/musica
sudo ./convertmp3.sh /ruta/a/musica [bitrate]
```

## Uso rápido — GUI Python

Desde el menú: `sudo ./inicio.sh` → opción **5**.

O manualmente:

```bash
pip install -r requirements-gui.txt   # o: apt install python3-tk python3-mutagen ffmpeg
python3 audio_converter.py
# o: python3 -m gui
```

La GUI usa **ffmpeg + mutagen** (como los scripts bash actualizados en Debian 13, sin faac). Incluye los 4 flujos y los mismos pasos opcionales (renombrar, covers, metadata, borrar JPG, eliminar origen).

1. Elige la carpeta con los archivos.
2. Selecciona el tipo de conversión (MP3→OGG, OGG→M4A, etc.).
3. Marca los pasos deseados (renombrar, extraer/importar carátula, metadata…).
4. Pulsa **Iniciar**.

La GUI usa **ffmpeg** y **mutagen** en lugar de herramientas solo Linux (`dir2ogg`, `AtomicParsley`, PowerShell), por lo que funciona en cualquier sistema con esas dependencias.

## Interfaz de texto (whiptail + barras de progreso)

- Menús y checklist unificados en `lib/ui_common.sh` (`whiptail_msg`, `whiptail_parse_checklist`).
- Copia con barra de progreso en `inicio.sh` vía `whiptail_rsync_copy` (gauge 0–100 %).
- Barras `[####....] NN% (i/N)` coherentes; en tareas **paralelas** el progreso usa contador en archivo + `flock` (sin mezclar líneas de log).
- Los detalles `[OK]` / `[ERROR]` se muestran al final del paso, no durante la barra.

## Correcciones recientes en Bash

- **Debian 13:** eliminados `faac` y `fdkaac`; M4A vía `ffmpeg -c:a aac`.
- `lib/install_deps.sh`: instala solo paquetes existentes en apt (sin fallar si falta uno obsoleto).
- `convertm4a.sh`: el bitrate usaba `$3` en lugar de `$2`.
- `to_mp3/oggconvert.sh`: el bitrate no se exportaba a procesos paralelos.
- `to_mp3/oggextractimage.sh` y `mp3_to_m4a/mp3importmetadata.sh`: `xargs` no pasaba el nombre de archivo al subproceso.
- `to_m4a/oggconvert.sh`, `oggimportimage.sh`, `oggimportmetadata.sh`: mismo arreglo en paralelización.
- `convertmp3.sh`: mensajes incorrectos (decía M4A); ahora menú whiptail coherente con OGG→MP3.
- `convertmp3_to_m4a.sh`: texto del menú corregido y paso de importación de metadata añadido.

## Estructura

```
inicio.sh              # Menú principal (whiptail)
convertogg.sh          # MP3 → OGG
convertm4a.sh          # OGG → M4A
convertmp3_to_m4a.sh   # MP3 → M4A
convertmp3.sh          # OGG → MP3
to_ogg/                # Pasos MP3 → OGG
to_m4a/                # Pasos OGG → M4A
to_mp3/                # Pasos OGG → MP3
mp3_to_m4a/            # Pasos MP3 → M4A
gui/                   # Interfaz Python
OLD/                   # Versiones antiguas (referencia)
```
