#!/bin/bash

# Directorios relevantes
READS_DIR="/home/sapodaca/tcruzi_project/trimmed_reads"
GENOME_DIR="/home/sapodaca/tcruzi_project/reference/index_Bo1Fc10A"
LOG_DIR="/home/sapodaca/tcruzi_project/STAR_Boa"

# Crear el directorio de logs si no existe
mkdir -p $LOG_DIR

# Verificar existencia de los archivos de entrada
if [[ ! -d "$READS_DIR" ]]; then
    echo "Error: El directorio de lecturas ($READS_DIR) no existe."
    exit 1
fi

# Lista de muestras emparejadas
SAMPLES=(
  "Grupo1CtrlH014"
  "Grupo1PosM030"
  "Grupo1PosM083"
  "Grupo2CtrlH020"
  "Grupo2CtrlM076"
  "Grupo2Negat21NH"
  "Grupo2NegatM059"
  "Grupo2NegatM108"
  "Grupo2PosM072"
  "Grupo3CtrlM038"
  "Grupo4Ctrl16GB"
  "Grupo4Pos15II"
  "Grupo5CtrlH011"
  "Grupo5CtrlH013"
  "Grupo5Negat48QP"
  "Grupo5NegatM084"
  "Grupo5PosM070"
  "Grupo5PosM098"
)

# Loop a través de las muestras
for SAMPLE in "${SAMPLES[@]}"
do
  # Archivos emparejados
  READ1="${SAMPLE}_1_paired.fastq.gz"
  READ2="${SAMPLE}_2_paired.fastq.gz"

  # Verificar si ambos archivos existen
  if [[ -f "$READS_DIR/$READ1" && -f "$READS_DIR/$READ2" ]]; then
    echo "Procesando muestra: $SAMPLE"

    # Crear un directorio por muestra para los archivos de log
    SAMPLE_LOG_DIR="$LOG_DIR/$SAMPLE"
    mkdir -p $SAMPLE_LOG_DIR

    # Ejecutar STAR con los parámetros para T. cruzi
    STAR --runThreadN 8 \
         --genomeDir $GENOME_DIR \
         --readFilesIn $READS_DIR/$READ1 $READS_DIR/$READ2 \
         --readFilesCommand zcat \
         --outFileNamePrefix $SAMPLE_LOG_DIR/$SAMPLE \
         --outSAMtype BAM SortedByCoordinate \
         --outFilterMismatchNmax 5 \
         --outFilterMultimapNmax 50 \
         --winAnchorMultimapNmax 100 \
         > $SAMPLE_LOG_DIR/${SAMPLE}_$(date +'%Y%m%d_%H%M%S').log 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Error en el alineamiento de la muestra $SAMPLE"
    else
        echo "Alineamiento completado para la muestra: $SAMPLE"
    fi

  else
    echo "Archivos faltantes para la muestra: $SAMPLE"
  fi
done
