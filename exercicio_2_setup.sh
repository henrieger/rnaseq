#!/bin/bash

AVALIACAO=$HOME/avaliacao
MUSCLE_ID=SRR6262201
SKIN_ID=SRR7591066
OUTPUT_DIR=$AVALIACAO/outputs

# Create output directory if doesn't exist
mkdir -p ${OUTPUT_DIR}

# Download and uncompress clownfish reference transcriptome
if ! [ -f clownfish.fasta ]; then
  wget -O clownfish.fasta.gz "https://ftp.ensembl.org/pub/release-113/fasta/amphiprion_ocellaris/cdna/Amphiprion_ocellaris.ASM2253959v1.cdna.all.fa.gz"
  pigz -d clownfish.fasta.gz
else
  echo "Found clownfish reference transcriptome. Skipping download..."
fi

# Execute FastQC analysis for original files
if ! [ -f ${OUTPUT_DIR}/${MUSCLE_ID}_fastqc.html ]; then
  ln -s ${AVALIACAO}/${MUSCLE_ID}.fastq.gz ${MUSCLE_ID}.fastq.gz
  ln -s ${AVALIACAO}/${SKIN_ID}.fastq.gz ${SKIN_ID}.fastq.gz
  fastqc \
    -t 2 \
    --outdir=${OUTPUT_DIR} \
    ${AVALIACAO}/${MUSCLE_ID}.fastq.gz \
    ${AVALIACAO}/${SKIN_ID}.fastq.gz
else
  echo "Found FastQC result for first analysis. Skipping first FastQC..."
fi

# Trimm both muscle and skin FastQ files
if ! [ -f ${MUSCLE_ID}.trimmed.fastq.gz ]; then
  fastp \
    -i ${MUSCLE_ID}.fastq.gz \
    -o ${MUSCLE_ID}.trimmed.fastq.gz \
    -h ${OUTPUT_DIR}/fastp_${MUSCLE_ID}_report.html \
    -j ${OUTPUT_DIR}/fastp_${MUSCLE_ID}_report.json
  fastp \
    -i ${SKIN_ID}.fastq.gz \
    -o ${SKIN_ID}.trimmed.fastq.gz \
    -h ${OUTPUT_DIR}/fastp_${SKIN_ID}_report.html \
    -j ${OUTPUT_DIR}/fastp_${SKIN_ID}_report.json
else
  echo "Found trimmed muscle FastQ file. Skipping FastP..."
fi

# Re-run FastQC analysis for trimmed files
if ! [ -f ${OUTPUT_DIR}/${MUSCLE_ID}.trimmed_fastqc.html ]; then
  fastqc \
    -t 2 \
    --outdir=${OUTPUT_DIR} \
    ${MUSCLE_ID}.trimmed.fastq.gz \
    ${SKIN_ID}.trimmed.fastq.gz
else
  echo "Found FastQC result for second analysis. Skipping second FastQC..."
fi
