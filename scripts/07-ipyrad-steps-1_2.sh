#!/usr/bin/env bash
#SBATCH --job-name=01-preprocessing
#SBATCH -p icelake
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --ntasks-per-core=1
#SBATCH --time=02:00:00
#SBATCH --mem=20GB
#SBATCH -o ./joblogs/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=shannon.coppersmith@adelaide.edu.au

# Variables
DIR="/hpcfs/users/$USER/dart-analyses"

# Make the output directory and change into it
cd "${DIR}/results/ipyrad" || exit 1

source "/home/a1645424/hpcfs/micromamba/etc/profile.d/micromamba.sh"
micromamba activate ipyrad

# Run ONLY stages 1 and 2 of the pipeline
ipyrad -s 12 -p 'params-pre-processing.txt' -c "${SLURM_CPUS_PER_TASK}"

micromamba deactivate