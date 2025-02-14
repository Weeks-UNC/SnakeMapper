rule fold_nodata:
    input: output_patterns["prep_fastas"]["fold_fasta"],
    output: **output_patterns["fold_nodata"]
    log: "results/fold/{sample}_{target}_nodata_log.txt"
    params:
        basedir=workflow.basedir,
        config=get_parameters("fold_nodata"),
        **config["exe_locations"],
    resources: **resources["RNAstructure"]
    conda: "envs/rnavigate.yml"
    group: "nodata"
    shell: """
        {params.fold} {input} {output.ct} {params.config} \
        && {params.partition} {input} {output.pfs} {params.config} \
        && {params.probplot} -t {output.pfs} {output.dp} \
        > {log}
    """

rule fold_popavg:
    input:
        fasta=output_patterns["prep_fastas"]["fold_fasta"],
        shapemapper_done=str(output_patterns["shapemapper"]["done"]),
    output:
        **output_patterns["fold_popavg"]
    log: "results/fold/{sample}_{target}_popavg_log.txt"
    params:
        basedir=workflow.basedir,
        config=get_parameters("fold_popavg"),
        constraints=get_RNAstructure_constraints_parameter,
        **config["exe_locations"],
    resources: **resources["RNAstructure"]
    conda: "envs/rnavigate.yml"
    group: "{sample}_{target}_popavg"
    shell: """
        {params.fold} \
            {input.fasta} {output.ct} \
            {params.config} {params.constraints} \
        && {params.partition} \
            {input.fasta} {output.pfs} \
            {params.config} {params.constraints} \
        && {params.probabilityplot} -t {output.pfs} {output.dp} \
        > {log}
    """


rule fold_popavg_pairs:
    input:
        fasta=output_patterns["prep_fastas"]["fold_fasta"],
        pairs=output_patterns["pairmapper"]["pair_constraints"],
        shapemapper_done = str(output_patterns["shapemapper"]["done"])
    output: **output_patterns["fold_popavg_pairs"]
    log: "results/fold/{sample}_{target}_popavg_pairs_log.txt"
    params:
        basedir=workflow.basedir,
        config=get_parameters("fold_popavg_pairs"),
        constraints=get_RNAstructure_constraints_parameter,
        **config["exe_locations"],
    resources: **resources["RNAstructure"]
    conda: "envs/rnavigate.yml"
    group: "{sample}_{target}_popavg_pairs"
    shell: """
        {params.fold} {input.fasta} {output.ct} \
            {params.config} {params.constraints} \
            -x {input.pairs} \
        && {params.partition} {input.fasta} {output.pfs} \
            {params.config} {params.constraints} \
            -x {input.pairs} \
        && {params.probabilityplot} -t {output.pfs} {output.dp} \
        > {log}
    """


rule fold_cluster:
    input:
        reactivities=output_patterns["dancemapper_fit"]["reactivities"],
    output:
        touch(output_patterns["fold_cluster"]["done"])
    log:
        fold="results/dancemapper/{sample}_{target}_fold_cluster_nopairs_log.txt",
        prob="results/dancemapper/{sample}_{target}_prob_cluster_nopairs_log.txt"
    params:
        config=get_parameters("fold_cluster"),
        foldclusters=config["exe_locations"]["foldclusters"],
    resources: **resources["RNAstructure"]
    conda: "envs/mapper.yml"
    group: "{sample}_{target}_cluster"
    shell: """
        python {params.foldclusters} {input.reactivities} \
            results/dancemapper/{wildcards.sample}_{wildcards.target}_nopairs \
            {params.config} \
            > {log.fold}
        python {params.foldclusters} {input.reactivities} \
            results/dancemapper/{wildcards.sample}_{wildcards.target}_nopairs \
            {params.config} --prob \
            > {log.prob}
    """


rule fold_cluster_pairs:
    input:
        reactivities="results/dancemapper/{sample}_{target}-reactivities.txt",
        dance_done=str(output_patterns["dancemapper_rings_pairs"]["done"])
    output:
        touch(output_patterns["fold_cluster_pairs"]["done"])
    log:
        fold="results/dancemapper/{sample}_{target}_fold_cluster_pairs_log.txt",
        prob="results/dancemapper/{sample}_{target}_prob_cluster_pairs_log.txt"
    params:
        config=get_parameters("fold_cluster_pairs"),
        foldclusters=config["exe_locations"]["foldclusters"],
    resources: **resources["RNAstructure"]
    conda: "envs/mapper.yml"
    group: "{sample}_{target}_cluster_pairs"
    shell: """
        {params.foldclusters} {input.reactivities} \
            results/dancemapper/{wildcards.sample}_{wildcards.target}_pairs \
            --bp results/dancemapper/{wildcards.sample}_{wildcards.target} \
            {params.config} \
            > {log.fold}
        {params.foldclusters} {input.reactivities} \
            results/dancemapper/{wildcards.sample}_{wildcards.target}_pairs \
            --bp results/dancemapper/{wildcards.sample}_{wildcards.target} \
            {params.config} --prob
            > {log.prob}
    """


rule plot:
    input: *[str(output_patterns[k]["done"]) for k in config["steps"] if k != "plot"]
    output:
        **{k: v for k, v in output_patterns["plot"].items() if k in config["steps"]},
        done=output_patterns["plot"]["done"]
    log: "results/figures/{sample}_{target}_plot_log.txt"
    params: basedir=workflow.basedir,
    resources: **resources["RNAstructure"]
    conda: "envs/rnavigate.yml"
    group: "{sample}_{target}_all"
    shell: """
        python {params.basedir}/scripts/fold_all.py \
            --sample {wildcards.sample} \
            --target {wildcards.target} \
        > {log}
    """
