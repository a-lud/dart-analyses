#!/usr/bin/env bash
#SBATCH --job-name=02-process-samples
#SBATCH -p icelake
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --ntasks-per-core=1
#SBATCH --time=05:00:00
#SBATCH --mem=60GB
#SBATCH -o ./joblogs/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

# Variables
DIR="/hpcfs/users/$USER/dart-analyses"

# Make the output directory and change into it
cd "${DIR}/results/ipyrad" || exit 1

source "/home/a1645424/hpcfs/micromamba/etc/profile.d/micromamba.sh"
micromamba activate ipyrad

# Run the remaining steps of the pipeline for the branched data.
# NOTE: Simply change the parameters file to run a different branch.
ipyrad -s 34567 -p params-example_aipysurus_branch.txt -c "${SLURM_CPUS_PER_TASK}"

micromamba deactivate

