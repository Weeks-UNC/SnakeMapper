# SnakeMapper

This Snakemake pipeline orchestrates the Weeks and Mustoe labs' "Mapper suite" of
software for RNA structure probing, modeling, and visualization.

- SHAPE-MaP reactivity profiling
- RING-MaP and PAIR-MaP correlation analysis
- DANCE-MaP deconvolution of alternative structures
- RNAstructure (Mathews Lab) folding/pairing-probability calculations
- RNAvigate figure generation

Given raw modified/untreated fastq reads and a target fasta, it runs the full
suite for each sample/target pair and produces structure models, pairing
probabilities, and arc plots.

## Status

This pipeline is under active development.
Some steps (e.g. clustered folding) are optional and can be disabled per run.
See [TODO.md](TODO.md) for planned changes.

## Requirements

- [Snakemake](https://snakemake.readthedocs.io/) (with `--use-conda` support)
- conda or mamba
- The following tools, installed separately and pointed to in
  `config/config.yaml`'s `exe_locations` (see [Dependencies](#dependencies)):
  - [Shapemapper2](https://github.com/Weeks-UNC/shapemapper2)
  - [RingMapper / PairMapper](https://github.com/Weeks-UNC/RingMapper)
  - [DanceMapper](https://github.com/MustoeLab/DanceMapper)
  - [RNAstructure](https://rna.urmc.rochester.edu/RNAstructure.html)
    (`Fold-smp`, `partition-smp`, `ProbabilityPlot`)

All other Python dependencies (including RNAvigate) are installed
automatically by Snakemake into per-rule conda environments via
`--use-conda`.

## Usage

1. Copy the contents of this repository into your run directory.
2. Edit `config/config.yaml`:
   - Set `exe_locations` to the paths of the tools listed above (or leave
     as the bare command if they're already on your `$PATH`).
   - Add an entry under `samples` for each sample/target pair, following the
     naming rules documented in the comments in `config/config.yaml`.
   - Enable/disable pipeline `steps` and adjust `parameters` as needed.
3. Run with Snakemake, e.g.:

   ```bash
   snakemake --use-conda --cores 8
   ```

   On an HPC cluster running SLURM, use `map_suite_nohup.sh` instead. It will run the
   workflow controller on the login node in a detached state with no time limit, and
   it doesn't end when you log out. This is preferred over submitting the workflow
   controller as a SLURM job because the controller requires very little resources but
   can run for a long time. The controller timing out can be very costly.

   ```bash
   ./map_suite_nohup.sh
   ```

   Edit the three paths at the top of the script for your environment. Start
   it from a plain login node shell. The script will refuse to run inside a SLURM job.

There is currently no nicely bundled example dataset to run out of the box.
Supply your own fastq/fasta inputs per the config format above.

## Dependencies

SnakeMapper is orchestration code: it does not reimplement the underlying
structure-probing analyses. If you use this pipeline, please also cite the
tools it wraps:

- [Shapemapper2](https://github.com/Weeks-UNC/shapemapper2)
- [RingMapper and PairMapper](https://github.com/Weeks-UNC/RingMapper)
- [DanceMapper](https://github.com/MustoeLab/DanceMapper)
- [RNAstructure](https://rna.urmc.rochester.edu/RNAstructure.html)
- [RNAvigate](https://github.com/Weeks-UNC/RNAvigate)

## License

Released under the [MIT License](LICENSE).
