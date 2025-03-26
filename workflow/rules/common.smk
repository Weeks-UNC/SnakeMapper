from pathlib import Path

def get_parameters(tool):
    parameters = []
    if config["parameters"][tool] is False:
        return ""
    for k, v in (config["parameters"][tool]).items():
        if v is True:
            parameters.append(f"--{k}")
        else:
            parameters.append(f"--{k} {v}")
    return parameters


def get_shapemapper_samples_parameter(wildcards, input):
    sample = wildcards.sample
    parameters = [f"--name {sample}"]
    def add_param(parameters, key, value):
        if key == "target":
            parameters.append(f"--target {input.fasta}")
        elif value is True:
            parameters.append(f"--{key}")
        elif value is False:
            return
        elif isinstance(value, dict):
            parameters.append(f"--{key}")
            for k, v in value.items():
                add_param(parameters, k, v)
        else:
            parameters.append(f"--{key} {value}")
    for key, value in config["samples"][sample].items():
        add_param(parameters, key, value)
    return " ".join(parameters)


def get_shapemapper_inputs(wildcards):
    files = []
    for key in ["modified", "untreated"]:
        for value in config["samples"][wildcards.sample][key].values():
            files.append(value)
    return files


def get_input_fasta(wildcards):
    fastas = [sample["target"] for sample in config["samples"].values()]
    fastas = {Path(fasta).stem: fasta for fasta in fastas}
    return fastas[wildcards.target]


def get_RNAstructure_constraints_parameter(wildcards, input):
    if config["samples"][wildcards.sample]["dms"] is True:
        return f"--dmsnt results/shapemapper/{wildcards.sample}_{wildcards.target}.dms"
    if config["samples"][wildcards.sample]["dms"] is False:
        return f"--SHAPE results/shapemapper/{wildcards.sample}_{wildcards.target}.shape"

# TODO: compute based on inputs, auto restart with double in profile
resources = {
    "RNAstructure": {"mem": 8000, "runtime": 60},
    "shapemapper": {"mem": 8000, "runtime": 60*24, "threads": 8},
    "ringmapper": {"mem": 8000, "runtime": 60*4},
    "pairmapper": {"mem": 8000, "runtime": 60*4},
    "dancemapper_fit": {"mem": 8000, "runtime": 60*24*5},
    "dancemapper_rings_pairs": {"mem": 60000, "runtime": 60*24},
}

output_patterns = {
    "prep_fastas": {
        "map_fasta": "results/shapemapper_fastas/{sample}_{target}.fasta",
        "fold_fasta": "results/fold_fastas/{sample}_{target}.fasta",
    },
    "fold_nodata": {
        "ct": "results/fold/{sample}_{target}_nodata.ct",
        "pfs": "results/fold/{sample}_{target}_nodata.pfs",
        "dp": "results/fold/{sample}_{target}_nodata.dp",
    },
    "shapemapper": {
        "profile": "results/shapemapper/{sample}_{target}_profile.txt",
        "mod_parsed_mut": "results/shapemapper/{sample}_Modified_{target}_parsed.mut",
        "unt_parsed_mut": "results/shapemapper/{sample}_Untreated_{target}_parsed.mut",
        # TODO: is this meant to disappear? if so, remove it, specify a fixed temp dir
        # "temp": temp(directory("results/shapemapper/{sample}_{target}_temp")),
        "profiles": report("results/shapemapper/{sample}_{target}_profiles.pdf", category="{sample}_{target}"),
        "histograms": report("results/shapemapper/{sample}_{target}_histograms.pdf", category="{sample}_{target}"),
        "depths": report("results/shapemapper/{sample}_{target}_mapped_depths.pdf", category="{sample}_{target}"),
    },
    "fold_popavg": {
        "ct": "results/fold/{sample}_{target}_popavg.ct",
        "pfs": "results/fold/{sample}_{target}_popavg.pfs",
        "dp": "results/fold/{sample}_{target}_popavg.dp",
    },
    "ringmapper": {
        "rings": "results/ringmapper/{sample}_{target}_ringmap.txt",
    },
    "pairmapper": {
        "pairs": "results/pairmapper/{sample}_{target}-pairmap.txt",
        "pair_constraints": "results/pairmapper/{sample}_{target}.bp",
    },
    "fold_popavg_pairs": {
        "ct": "results/fold/{sample}_{target}_popavg_pairs.ct",
        "pfs": "results/fold/{sample}_{target}_popavg_pairs.pfs",
        "dp": "results/fold/{sample}_{target}_popavg_pairs.dp",
    },
    "dancemapper_fit": {
        "model": "results/dancemapper/{sample}_{target}.bm",
        "reactivities": "results/dancemapper/{sample}_{target}-reactivities.txt",
    },
    "fold_cluster": {},
    "dancemapper_rings_pairs": {
        "rings": "results/dancemapper/{sample}_{target}-0-rings.txt",
        "pairs": "results/dancemapper/{sample}_{target}-0-pairmap.txt",
        "pair_constraints": "results/dancemapper/{sample}_{target}-0-pairmap.bp",
    },
    "fold_cluster_pairs": {},
    "plot": {
        "fold_nodata": report(
            "results/figures/{sample}_{target}_nodata.svg",
            category="{sample}_{target}",
            subcategory="Structure modeling",
            labels={"reactivities": "N/A", "PAIRs": "N/A"}
        ),
        "fold_popavg": report(
            "results/figures/{sample}_{target}_popavg.svg",
            category="{sample}_{target}",
            subcategory="Structure modeling",
            labels={"reactivities": "population", "PAIRs": "N/A"}
        ),
        "fold_popavg_pairs": report(
            "results/figures/{sample}_{target}_popavg_pairs.svg",
            category="{sample}_{target}",
            subcategory="Structure modeling",
            labels={"reactivities": "population", "PAIRs": "Yes"}
        ),
        "fold_cluster": report(
            "results/figures/{sample}_{target}_cluster.svg",
            category="{sample}_{target}",
            subcategory="Structure modeling",
            labels={"reactivities": "cluster", "PAIRs": "N/A"}
            ),
        "fold_cluster_pairs": report(
            "results/figures/{sample}_{target}_cluster_pairs.svg",
            category="{sample}_{target}",
            subcategory="Structure modeling",
            labels={"reactivities": "cluster", "PAIRs": "Yes"}
            )
    },
}
done = "results/completed/{sample}_{target}/"
for key in output_patterns:
    output_patterns[key]["done"] = touch(f"{done}{key}.done")

def get_final_output():
    format_kwargs = {'sample': [], 'target': []}
    for sample, params in config["samples"].items():
        format_kwargs["sample"].append(sample)
        format_kwargs["target"].append(str(Path(params["target"]).stem))
    all_ouput = []
    for step in config["steps"]:
        all_ouput.append(expand(f"{done}{step}.done", zip, **format_kwargs))
    return all_ouput
