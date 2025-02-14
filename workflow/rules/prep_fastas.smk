rule prep_fastas:
    input:
        fasta=get_input_fasta,
    output:
        **output_patterns["prep_fastas"]
    resources: **resources["RNAstructure"]
    group: "nodata"
    shell: """
        awk '/^>/{{$0=">{wildcards.target}"}}/^[^>]/{{gsub(/u/,"t") gsub(/U/, "T")}}1' \
            {input.fasta} > {output.map_fasta} \
        && awk '/^>/{{$0=">{wildcards.target}"}}/^[^>]/{{$0=toupper($0)}}1' \
            {input.fasta} > {output.fold_fasta}
    """
