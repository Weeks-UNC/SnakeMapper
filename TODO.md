OBJECTIVE
=========

All you need is snakemake and singularity or apptainer
- Usage:
  1. copy contents to your run directory
  2. edit config
  3. run with flags dependent on your environment
    - pulls docker image or uses preexisting (maintained via github)
    - installs conda envs or uses preexisting

TODO
====

- rewrite to stop after dancefit and determine remaining expected output files
- config.yaml validation
- more flexible inputs for fasta naming
  - Idea:
    - Target is a list of fasta files.
    - Concatenate during prep_fastas.
    - Shapemapper specifies outputs for each target using expand.
  - Idea 2:
    - Target is the fasta used in Shapemapper.
    - Parse the contents for target names.
  - Idea 3:
    - provide all target names as a seperate parameter.
- restructure?
  - 1 rule for fold/partition for nodata or w/wo PAIRs
  - 1 for foldClusters.py w/wo PAIRs

DONE
====

- automatic snakemake report and figure generation
- prep fastas
- automatic capitalization for RNAstructure inputs
- ability to use primers files
- ability to specify --folders and --unpaired shapemapper inputs
