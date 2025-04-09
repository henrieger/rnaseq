#!/bin/bash

AVALIACAO=$HOME/avaliacao
BASE_DIR=$AVALIACAO/exercicio_2
MUSCLE_ID=SRR6262201
SKIN_ID=SRR7591066
OUTPUT_DIR=$BASE_DIR/outputs
THREADS=8

# Uncomment and edit the block below if you wish to use AI models in MultiQC
#export OPENAI_API_KEY=ollama
#AI_PROVIDER=custom
#AI_ENDPOINT=http://localhost:11434/v1/chat/completions
#AI_MODEL=llama3.1:8b

if ! [ -f ${OUTPUT_DIR}/clownfish.index ]; then
  kallisto index -i ${OUTPUT_DIR}/clownfish.index clownfish.fasta
else
  echo "Found kallisto index. Skipping..."
fi

if ! [ -d ${OUTPUT_DIR}/kallisto_${MUSCLE_ID} ]; then
  kallisto quant \
    -i ${OUTPUT_DIR}/clownfish.index \
    -o ${OUTPUT_DIR}/kallisto_${MUSCLE_ID} \
    -t ${THREADS} \
    --single \
    -l 150 \
    -s 10 \
    ${MUSCLE_ID}.trimmed.fastq.gz \
    2>&1 | tee ${OUTPUT_DIR}/kallisto_${MUSCLE_ID}.log
else
  echo "Found kallisto output dir for muscle analysis. Skipping..."
fi

if ! [ -d ${OUTPUT_DIR}/kallisto_${SKIN_ID} ]; then
  kallisto quant \
    -i ${OUTPUT_DIR}/clownfish.index \
    -o ${OUTPUT_DIR}/kallisto_${SKIN_ID} \
    -t ${THREADS} \
    --single \
    -l 50 \
    -s 1 \
    ${SKIN_ID}.trimmed.fastq.gz \
    2>&1 | tee ${OUTPUT_DIR}/kallisto_${SKIN_ID}.log
else
  echo "Found kallisto output dir for skin analysis. Skipping..."
fi

if ! [ -f ${OUTPUT_DIR}/multiqc_report.html ]; then
  multiqc \
  # Uncomment lines below for AI summary
  #--ai-summary-full \
  #--ai-provider ${AI_PROVIDER} \
  #--ai-model ${AI_MODEL} \
  #--ai-custom-endpoint ${AI_ENDPOINT} \
    --outdir=${OUTPUT_DIR} \
    ${OUTPUT_DIR}
else
  echo "Found multiqc report. Skipping..."
fi

if ! [ -f ${AVALIACAO}/multiqc_report.html ]; then
  ln -s ${OUTPUT_DIR}/kallisto_${MUSCLE_ID}.log ${AVALIACAO}/kallisto_${MUSCLE_ID}.log
  ln -s ${OUTPUT_DIR}/kallisto_${SKIN_ID}.log ${AVALIACAO}/kallisto_${SKIN_ID}.log
  ln -s ${OUTPUT_DIR}/multiqc_report.html ${AVALIACAO}/multiqc_report.html
else
  echo "Found links for final outputs. Skipping..."
fi
