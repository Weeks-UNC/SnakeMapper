#!/usr/bin/env bash

#SBATCH --mem=2g
#SBATCH -t 4-00:00:00

module purge
module add anaconda

snakemake \
    --use-conda \
        --conda-frontend conda \
        --conda-prefix /opt/conda/envs \
    --cores 8 \
    --rerun-incomplete \
    --slurm \
    --default-resources slurm_account=rc_kweeks_pi \
    --jobs 20 \
    --latency-wait 30

snakemake --report report.html
