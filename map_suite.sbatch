#!/usr/bin/env bash

#SBATCH --mem=2g
#SBATCH -t 4-00:00:00

# make double sure the environment is clean, no modules, no "base" conda env
module purge
module add anaconda
# TODO: why does "base" sometimes take precident?
conda deactivate
conda deactivate

snakemake \
    --use-conda \
        --conda-frontend conda \
        --conda-prefix /proj/kweeks/bin/snakemake_envs/ \
    --cores 8 \
    --rerun-incomplete \
    --slurm \
    --default-resources slurm_account=rc_kweeks_pi \
    --jobs 20 \
    --latency-wait 60

# snakemake --report report.html
