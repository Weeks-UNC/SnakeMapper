FROM continuumio/miniconda3

# Install git, build-essential
# TODO: it is not best practice to include build utilities in a production image
# FROM image as builder install things, FROM image copy built things from builder
RUN apt-get update && apt-get install -y build-essential git

# Install RNAstructure
# TODO: RNAstructure package is 300MB, consider removing unnecessary files
RUN wget https://rna.urmc.rochester.edu/Releases/current/RNAstructureLinuxTextInterfaces64bit.tgz -O /tmp/RNAstructureLinuxTextInterfaces64bit.tgz \
    && tar -C /usr/local -xvf /tmp/RNAstructureLinuxTextInterfaces64bit.tgz \
    && rm /tmp/RNAstructureLinuxTextInterfaces64bit.tgz
WORKDIR /usr/local/RNAstructure
RUN make ProbabilityPlot partition-smp Fold-smp
ENV PATH $PATH:/usr/local/shapemapper2-2.3:/usr/local/RNAstructure/exe

# Install shapemapper2
# TODO: shapemapper2 pre-compiled is ~3G, and contains redundant software in internals/thirdparty
# consider git cloning the source code and compiling it in the dockerfile
RUN wget https://github.com/Weeks-UNC/shapemapper2/releases/download/v2.3/shapemapper2-2.3.tar.gz -O /tmp/shapemapper2-2.3.tar.gz \
    && mkdir -p /usr/local \
    && tar -C /usr/local -xvf /tmp/shapemapper2-2.3.tar.gz \
    && rm /tmp/shapemapper2-2.3.tar.gz \
    && rm /usr/local/shapemapper2-2.3/internals/thirdparty/bowtie2-2.3.4.3-linux-x86_64.zip \
    && rm /usr/local/shapemapper2-2.3/internals/thirdparty/ghostscript-9.25.tar.gz \
    && rm /usr/local/shapemapper2-2.3/internals/thirdparty/pv-1.6.20.tar.gz

# Install conda environment needed to install Ring/Dancemapper
# TODO: If Ring/Dancemapper are converted to python3, one environment would do the job.
COPY mapper.yml /tmp/mapper.yml
COPY rnavigate.yml /tmp/rnavigate.yml
RUN conda env create -f /tmp/mapper.yml \
    && conda env create -f /tmp/rnavigate.yml \
    && rm /tmp/mapper.yml /tmp/rnavigate.yml \
    && conda clean --all -y

# Install RingMapper, DanceMapper, and StructureAnalysisTools
# TODO: look into installing these via pip
WORKDIR /usr/local
RUN git clone https://github.com/Weeks-UNC/RingMapper.git --depth 1 \
    && rm -rf /usr/local/RingMapper/.git \
    && git clone https://github.com/MustoeLab/StructureAnalysisTools.git --depth 1 \
    && rm -rf /usr/local/StructureAnalysisTools/.git \
    && git clone https://github.com/MustoeLab/DanceMapper.git --depth 1 \
    && rm -rf /usr/local/DanceMapper/.git \
    && rm -rf /usr/local/DanceMapper/example

SHELL ["conda", "run", "-n", "MaP", "/bin/bash", "-c"]
WORKDIR /usr/local/RingMapper
RUN python setup.py build_ext --inplace
WORKDIR /usr/local/DanceMapper
COPY externalpaths.py .
RUN python setup.py build_ext --inplace
