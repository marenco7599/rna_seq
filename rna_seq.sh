#!/bin/bash
#SBATCH --job-name=rnaseq_job      # Nome del job
#SBATCH --output=rnaseq_output.log  # File di log dell'output
#SBATCH --time=38:00:00             # Tempo massimo di esecuzione
#SBATCH --ntasks=1                  # Numero di task
#SBATCH --cpus-per-task=12           # CPU per task
#SBATCH --mem=72GB                  # Memoria richiesta

set -euo pipefail  # Ferma su errori o variabili non definite

echo "Starting job script"

export PATH="/hpcnfs/home/ieo7599/bin:$PATH"
echo "PATH is: $PATH"

eval "$(micromamba shell hook -s bash)"
echo "Micromamba shell hook initialized"

micromamba activate nextflow_env || { echo "ERROR: micromamba activate failed"; exit 1; }
echo "Activated environment: ${MAMBA_DEFAULT_ENV:-<undefined>}"

echo "Job script finished"

export PATH="$PATH:/hpcnfs/software/singularity/4.0.0/bin"

export NXF_SINGULARITY_CACHEDIR="/hpcnfs/scratch/UC/.singularity_cache"
mkdir -p "$NXF_SINGULARITY_CACHEDIR"

export LD_LIBRARY_PATH="/hpcnfs/techunits/bioinformatics/software/petagene/petalink_1.3.15/bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

WORKDIR="/hpcnfs/scratch/temporary/marenco/seqera/" 
cd "$WORKDIR" || { echo "❌ Directory di lavoro non trovata: $WORKDIR"; exit 1; }

echo "📄 Contenuto di sample.csv prima di lanciare Nextflow:"
head -n 10 data/sample.csv

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_REGION
export NXF_SINGULARITY_ALLOW_PULL="false"

echo "AWS env vars before Nextflow:"
env | grep AWS || echo "No AWS vars set"

nextflow run nf-core/rnaseq \
  -profile singularity \
  --input data/sample.csv \
  --outdir results \
  --fasta /hpcnfs/scratch/temporary/marenco/Zhan/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
  --gtf /hpcnfs/scratch/temporary/marenco/Zhan/genome/Homo_sapiens.GRCh38.104.gtf.gz \
  -resume \
  -with-report report.html \
  -with-trace trace.txt



echo "✅ Pipeline RNA-Seq completata con successo!"
