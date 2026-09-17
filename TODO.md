OBJECTIVE
=========

All you need is Snakemake and singularity or apptainer

- Usage:
  1. copy contents to your run directory
  2. edit config
  3. run with flags dependent on your environment
    - pulls or reuses docker image
    - installs or reuses conda envs

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

Full pipeline testing
---------------------

Goal: exercise the entire pipeline (raw fastq -> shapemapper -> ring/pair/dance
-> fold -> plot) end to end inside `.devcontainer/`.

Notes:

- Download fastqs from which DanceMapper's example were derived:
  - From the DANCE-MaP paper: WT adenine riboswitch (GSE182552):
    - Modified: SRR15560843 ("WT, adenine 0, rep 1"), ~196 MB, ~1.05M reads.
    - Untreated: SRR15560865 ("WT, etoh, rep 1"), ~67 MB.
  - Fastq download via ENA (direct https, no sra-tools needed), e.g.:
    `ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/043/SRR15560843/SRR15560843_{1,2}.fastq.gz`
    and the equivalent path for SRR15560865.

Remaining steps:

1. Find the amplicon target fasta + primer sequences used in this study, might be in
   GEO supplemental files.
2. Build `.devcontainer/` (~4GB, expect a long build time)
3. Download the fastqs above (~260 MB total) into `data/`
4. Configure `config/config.yaml` with the real data files
5. Run the full pipeline (`snakemake --use-conda --cores N`) and confirm outputs
