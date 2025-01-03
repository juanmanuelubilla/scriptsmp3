import os
import sys
from mutagen.oggvorbis import OggVorbis
from PIL import Image
import io

def convertir_a_jpeg_bytes(jpg_file):
    """Convierte el archivo JPG a un array de bytes en formato JPEG."""
    with Image.open(jpg_file) as img:
        with io.BytesIO() as img_byte_arr:
            img.convert("RGB").save(img_byte_arr, format="JPEG")
            return img_byte_arr.getvalue()

def agregar_caratura(ogg_file, jpg_file):
    """Agrega una carátula al archivo OGG utilizando un archivo JPG."""
    try:
        # Cargar el archivo OGG
        audio = OggVorbis(ogg_file)

        # Convertir la imagen JPG a un formato JPEG adecuado en bytes
        imagen_bytes = convertir_a_jpeg_bytes(jpg_file)

        # Asignar la imagen como un bloque de metadatos de tipo 'METADATA_BLOCK_PICTURE'
        audio["METADATA_BLOCK_PICTURE"] = [
            (3, "image/jpeg", len(imagen_bytes), imagen_bytes)  # Los datos deben estar en formato binario (bytes)
        ]

        # Guardar el archivo OGG con la nueva carátula
        audio.save()

        print(f"Carátula agregada exitosamente a: {ogg_file} desde {jpg_file}")
    
    except Exception as e:
        print(f"Error al procesar {ogg_file}: {str(e)}")

def buscar_ogg_y_jpg(directorio):
    """Recorre el directorio y subdirectorios buscando archivos OGG y JPG."""
    print(f"Buscando en el directorio: {directorio}")
    for root, dirs, files in os.walk(directorio):  # Recorrido en subdirectorios
        ogg_files = [f for f in files if f.endswith(".ogg")]
        jpg_files = [f for f in files if f.endswith(".jpg")]

        for ogg_file in ogg_files:
            ogg_path = os.path.join(root, ogg_file)
            
            for jpg_file in jpg_files:
                jpg_path = os.path.join(root, jpg_file)
                print(f"\nProcesando archivo OGG: {ogg_path}")
                print(f"Usando carátula JPG: {jpg_path}")
                agregar_caratura(ogg_path, jpg_path)

# Ejemplo de uso
if __name__ == "__main__":
    # Tomar el directorio desde el argumento pasado al script
    if len(sys.argv) != 2:
        print("Por favor, proporciona un directorio como argumento.")
        sys.exit(1)
    
    directorio = sys.argv[1]  # Obtener el directorio del argumento
    if not os.path.isdir(directorio):
        print(f"El directorio {directorio} no es válido.")
        sys.exit(1)
    
    buscar_ogg_y_jpg(directorio)
