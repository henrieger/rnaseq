#!/bin/bash

TRINITY_OUTPUT=$HOME/aula1/trinity_out_dir.Trinity.fasta
TRANSDECODER_OUTPUT=exercicio_1.transdecoder_dir
AMINOACID_CUTOFF=50
THREADS=4

# Download and decompress ToxProt data from UniProtKB
if ! [ -f toxprot.fasta ]; then
  wget -O toxprot.fasta.gz "https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&query=%28%28taxonomy_id%3A33208%29+AND+%28%28cc_tissue_specificity%3Avenom%29+OR+%28keyword%3AKW-0800%29%29+AND+%28reviewed%3Atrue%29%29"
  pigz -d toxprot.fasta.gz
else
  echo "Found toxprot.fasta file. Skipping download..."
fi

# Find ORFs inside trinity output
if ! [ -d $TRANSDECODER_OUTPUT ]; then
  TransDecoder.LongOrfs -t ${TRINITY_OUTPUT} -m ${AMINOACID_CUTOFF} -O ${TRANSDECODER_OUTPUT}
  ln -s ${TRANSDECODER_OUTPUT}/longest_orfs.pep transdecoder_orfs.pep # Create symlink for PEP output
else
  echo "Found transdecoder output directory. Skipping TransDecoder..."
fi

# Make diamond database and blast transdecoder output
if ! [ -f toxprot.dmnd ]; then
  diamond makedb --in toxprot.fasta -d toxprot.dmnd
  diamond blastp \
    --db toxprot.dmnd \
    -q transdecoder_orfs.pep \
    -o diamond.outfmt6 \
    -e 1e-5 \
    --max-target-seqs 1 \
    --outfmt 6 \
    -p ${THREADS}
else
  echo "Found diamond database. Skipping diamond execution..."
fi
