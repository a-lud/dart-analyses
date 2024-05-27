#!/usr/bin/env bash
#SBATCH --job-name=qc
#SBATCH -p icelake
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -a 1-348%50
#SBATCH --ntasks-per-core=1
#SBATCH --time=04:00:00
#SBATCH --mem=60GB
#SBATCH -o /home/a1645424/hpcfs/analysis/shannon/scripts/joblogs/%x_%a_%A_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

# Paths
DIR='/home/a1645424/hpcfs/analysis/shannon'
CSV="${DIR}/data/240524-sample-linkage.csv"
FQDIR="${DIR}/data/fastq"

# Out directories
OUTDIR="${DIR}/results/qc"
MULTIQC="${OUTDIR}/multiqc"

# Databases
UNIVEC='/home/a1645424/hpcfs/database/univec/univec.fasta'
KDB='/home/a1645424/hpcfs/database/k2_standard_20210517'

# Make output directories
mkdir -p "${OUTDIR}" "${MULTIQC}" "${OUTDIR}/fastp" "${OUTDIR}/kraken2" "${OUTDIR}/bbduk"

source "/home/a1645424/hpcfs/micromamba/etc/profile.d/micromamba.sh"

# Array variables
FQ=$(find "${FQDIR}" -type f -name '*.gz' | tr '\n' ' ' | cut -d' ' -f "${SLURM_ARRAY_TASK_ID}")
BN=$(basename "${FQ%%.*}")

# Get total length of barcode and cut site overhang
B9l=$(grep "${BN}" "${CSV}" | head -n 1 | cut -d',' -f 4)
LENGTH=$(echo -n "${B9l}" | wc -c)

# Get sequencing run ID
SEQ_RUN=$(grep "${BN}" ${CSV} | head -n 1 | cut -d',' -f 1)

if [[ "${SEQ_RUN}" =~ ("DNote23-8392"|"DNote23-8556"|"DNote23-8773") ]]; then
  micromamba activate fastp
  # FASTP
  fastp \
    -i "${FQ}" \
    -o "${OUTDIR}/fastp/${BN}.fastq.gz" \
    --average_qual 10 \
    --length_required 25 \
    --thread "${SLURM_CPUS_PER_TASK}" \
    --json "${MULTIQC}/${BN}.fastp.json"
  micromamba deactivate
else
  # BBDUK > KRAKEN2 > FASTP
  micromamba activate bbmap
  bbduk.sh \
    --in="${FQ}" \
    --out="${OUTDIR}/bbduk/${BN}.fastq.gz" \
    --ref="${UNIVEC}" \
    --ktrim=r \
    --mink=11 \
    --ftl="${LENGTH}" \
    --threads="${SLURM_CPUS_PER_TASK}" 2> "${MULTIQC}/${BN}.bbduk.log"
  micromamba deactivate

# Kraken
  micromamba activate kraken2
  kraken2 \
    --db "${KDB}" \
    --threads "${SLURM_CPUS_PER_TASK}" \
    --gzip-compressed \
    --output '-' \
    --unclassified-out "${OUTDIR}/kraken2/${BN}-unclassified.fastq" \
    --report "${MULTIQC}/${BN}.report" \
    "${OUTDIR}/bbduk/${BN}.fastq.gz"

  pigz -p "${SLURM_CPUS_PER_TASK}" "${OUTDIR}/kraken2/${BN}-unclassified.fastq"

  micromamba activate fastp
  fastp \
    -i "${OUTDIR}/kraken2/${BN}-unclassified.fastq.gz" \
    -o "${OUTDIR}/fastp/${BN}.fastq.gz" \
    --average_qual 10 \
    --length_required 25 \
    --thread "${SLURM_CPUS_PER_TASK}" \
    --json "${MULTIQC}/${BN}.fastp.json"
  micromamba deactivate

  if [[ -f "${OUTDIR}/bbduk/${BN}.fastq.gz" ]]; then rm -v "${OUTDIR}/bbduk/${BN}.fastq.gz"; fi
  if [[ -f "${OUTDIR}/kraken2/${BN}-unclassified.fastq.gz" ]]; then rm -v "${OUTDIR}/kraken2/${BN}-unclassified.fastq.gz"; fi
fi
