rule shapemapper:
    input:
        get_shapemapper_inputs,
        fasta=output_patterns["prep_fastas"]["map_fasta"],
    output: **output_patterns["shapemapper"]
    log: "results/shapemapper/{sample}_{target}_log.txt",
    params:
        shapemapper_exe=config["exe_locations"]["shapemapper"],
        samples=get_shapemapper_samples_parameter,
        config=get_parameters("shapemapper"),
    threads: resources["shapemapper"]["threads"]
    resources:
        mem=resources["shapemapper"]["mem"],
        runtime=resources["shapemapper"]["runtime"],
    group: "{sample}_{target}_popavg"
    shell: """
        {params.shapemapper_exe} \
            --out results/shapemapper/ \
            --log {log} \
            --temp results/shapemapper/temp/ \
            --nproc {threads} \
            {params.samples} {params.config}
    """

rule ringmapper:
    input:
        fasta=output_patterns["prep_fastas"]["map_fasta"],
        modified=output_patterns["shapemapper"]["mod_parsed_mut"],
        untreated=output_patterns["shapemapper"]["unt_parsed_mut"],
    output: 
        **output_patterns["ringmapper"],
    log: "results/ringmapper/{sample}_{target}_ringmapper_log.txt"
    params:
        config=get_parameters("ringmapper"),
        ringmapper_exe=config["exe_locations"]["ringmapper"],
    resources: **resources["ringmapper"]
    conda: "envs/mapper.yml"
    shell: """
        python {params.ringmapper_exe} \
            {params.config} \
            --fasta {input.fasta} \
            --untreated {input.untreated} \
            {input.modified} \
            {output.rings}
        > {log}
    """

rule pairmapper:
    input:
        fasta=output_patterns["prep_fastas"]["map_fasta"],
        profile=output_patterns["shapemapper"]["profile"],
        modified=output_patterns["shapemapper"]["mod_parsed_mut"],
        untreated=output_patterns["shapemapper"]["unt_parsed_mut"],
    output: 
        **output_patterns["pairmapper"],
    log: "results/pairmapper/{sample}_{target}_pairmapper_log.txt"
    resources: **resources["pairmapper"]
    params:
        config=get_parameters("pairmapper"),
        pairmapper_exe=config["exe_locations"]["pairmapper"],
    conda: "envs/mapper.yml"
    group: "{sample}_{target}_popavg_pairs"
    shell: """
        python {params.pairmapper_exe} \
            {params.config} \
            --profile {input.profile} \
            --untreated_parsed {input.untreated} \
            --modified_parsed {input.modified} \
            --out results/pairmapper/{wildcards.sample}_{wildcards.target} \
        > {log}
    """

rule dancemapper_fit:
    input:
        profile=output_patterns["shapemapper"]["profile"],
        modified=output_patterns["shapemapper"]["mod_parsed_mut"],
        untreated=output_patterns["shapemapper"]["unt_parsed_mut"],
    output:
        **output_patterns["dancemapper_fit"]
    log: "results/dancemapper/{sample}_{target}_fit_log.txt"
    params:
        config=get_parameters("dancemapper_fit"),
        dancemapper_exe=config["exe_locations"]["dancemapper"],
    resources: **resources["dancemapper_fit"]
    conda: "envs/mapper.yml"
    group: "{sample}_{target}_cluster"
    shell: """
        python {params.dancemapper_exe} \
            {params.config} \
            --profile {input.profile} \
            --untreated_parsed {input.untreated} \
            --modified_parsed {input.modified} \
            --outputprefix "results/dancemapper/{wildcards.sample}_{wildcards.target}" \
        > {log}
    """

rule dancemapper_rings_pairs:
    input:
        profile=output_patterns["shapemapper"]["profile"],
        modified=output_patterns["shapemapper"]["mod_parsed_mut"],
        untreated=output_patterns["shapemapper"]["unt_parsed_mut"],
        model=output_patterns["dancemapper_fit"]["model"],
    output:
        **output_patterns["dancemapper_rings_pairs"]
    log: "results/dancemapper/{sample}_{target}_rings_pairs_log.txt"
    params:
        config=get_parameters("dancemapper_rings_pairs"),
        dancemapper_exe=config["exe_locations"]["dancemapper"],
    resources: **resources["dancemapper_rings_pairs"]
    conda: "envs/mapper.yml"
    group: "{sample}_{target}_cluster_pairs"
    shell: """
        python {params.dancemapper_exe} \
            {params.config} \
            --readfromfile {input.model} \
            --profile {input.profile} \
            --untreated_parsed {input.untreated} \
            --modified_parsed {input.modified} \
            --outputprefix results/dancemapper/{wildcards.sample}_{wildcards.target}
        > {log}
    """
