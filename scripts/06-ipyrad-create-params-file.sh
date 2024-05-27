#!/usr/bin/env bash

# Project directory: change this to your own path 
DIR="/hpcfs/users/$USER/dart-analyses"

# Make the output directory and change into it
mkdir "${DIR}/results/ipyrad"; cd "${DIR}/results/ipyrad" || exit 1

# Activate conda environment
source "/home/a1645424/hpcfs/micromamba/etc/profile.d/micromamba.sh"
micromamba activate ipyrad

# Create Ipyrad parameters file
ipyrad -n pre-processing

# After creating the parameter file, open it in VScode and edit the following fields:
#   - [4] Sorted_fastq_path = this is the path to the trimmed FASTQ files
#   - [7] Datatype = I believe this is 'ddrad'

micromamba deactivate

