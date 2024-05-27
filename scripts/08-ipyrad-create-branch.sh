#!/usr/bin/env bash

# Variables
DIR="/hpcfs/users/$USER/dart-analyses"

# Make the output directory and change into it
cd "${DIR}/results/ipyrad" || exit 1

source "/home/a1645424/hpcfs/micromamba/etc/profile.d/micromamba.sh"
micromamba activate ipyrad

# Creating a branch 
#   - Change 'example_aipysurus_branch' to whatever name you want
#   - The last argument 'ALA-APO-samples.txt' contains the subset of samples to use in this branch
ipyrad -p params-pre-process -b example_aipysurus_branch '../data/ALA-APO-samples.txt'

# NOTE: This command will create a new params file using the name of the branch.
#   - e.g. 'params-example_aipysurus_branch.txt'
# This is the file we need to edit to run the remaining steps of the pipeline.
# Set all remaining parameters that we haven't already set. Feel free to trial
# default settings as these are usually pretty good starting points.
#
# Key settings to consider:
#   - [5] = Assembly method (reference)
#   - [6] = Path to reference sequence
#   - [7] = Type of data (ddrad)
#   - [14] = Clustering threshold
#   - [17] = Minimum length of reads
#   - [21] = Minimum number of samples per locus
#   - [27] = Output files we want
#   - [28] = Path to population assignment file

micromamba deactivate