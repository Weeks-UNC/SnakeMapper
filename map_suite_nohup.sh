#!/usr/bin/env bash
# Use this script to run SnakeMapper on a Slurm cluster.
# It launches the workflow controller detached with no wall-clock limit.
# The controller submits each rule to Slurm when their dependencies are met.
#
# Usage: ./map_suite_nohup.sh [extra snakemake args ...]
#   e.g. ./map_suite_nohup.sh --set-resources shapemapper:runtime=5760

set -euo pipefail

# --- edit for your environment ----------------------------------------

CONDA_ENV=/path/to/conda/envs/snakemake
SNAKEMAKE_ENVS=/path/to/snakemake_envs/
SLURM_ACCOUNT=your_slurm_account

# ----------------------------------------------------------------------

# nohup doesn't outlive the allocation it was started in. Defeats the purpose.

if [[ -n "${SLURM_JOB_ID:-}" ]]; then
    echo "ERROR: this shell is inside Slurm job $SLURM_JOB_ID." >&2
    echo "Start this from a login node shell instead." >&2
    exit 1
fi

if [[ ! -f config/config.yaml ]]; then
    echo "ERROR: no config/config.yaml here; run from the run directory." >&2
    exit 1
fi

LOG="snakemake_$(date +%Y%m%d_%H%M%S).log"

set +u
source "$CONDA_ENV/bin/activate" "$CONDA_ENV"
set -u

nohup snakemake \
    --use-conda \
        --conda-frontend conda \
        --conda-prefix "$SNAKEMAKE_ENVS" \
    --executor slurm \
    --default-resources slurm_account="$SLURM_ACCOUNT" \
    --jobs 20 \
    --cores 8 \
    --rerun-incomplete \
    --keep-going \
    --latency-wait 60 \
    "$@" \
    > "$LOG" 2>&1 &

PID=$!
echo "$PID" > .snakemake_controller.pid
echo "controller PID $PID"
echo "log            $LOG"
echo
echo "watch:         tail -f $LOG"
echo "stop:          kill $PID"
echo "  doesn't cancel running Slurm jobs; scancel them separately if needed."
