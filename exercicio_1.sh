#!/bin/bash

TRINITY_OUTPUT=$HOME/aula1/trinit_out_dir.fasta
AMINOACID_CUTOFF=50
THREADS=4

# Download and decompress ToxProt data from UniProtKB
if ! [ -f toxprot.fasta ]; then
  wget -O toxprot.fasta.gz "https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&query=%28%28taxonomy_id%3A33208%29+AND+%28%28cc_tissue_specificity%3Avenom%29+OR+%28keyword%3AKW-0800%29%29+AND+%28reviewed%3Atrue%29%29"
  pigz -d toxprot.fasta.gz
fi

# Find ORFs inside trinity output
TransDecoder.LongOrfs -t ${TRINITY_OUTPUT} -m ${AMINOACID_CUTOFF} -O exercicio_1.transdecoder_dir

# Create symlink for PEP output
ln -s exercicio_1.transdecoder_dir/longest_orfs.pep transdecoder_orfs.pep

# Make diamond database and blast transdecoder output
diamond makedb --in toxprot.fasta -d toxprot.dmnd
diamond blastp \
  --db toxprot.dmnd \
  -q transdecoder_orfs.pep \
  -o diamond.outfmt6 \
  -e 1e-5 \
  --max-target-seqs 1 \
  --outfmt 6 \
  -p ${THREADS}
