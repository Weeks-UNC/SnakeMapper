import rnavigate as rnav
import yaml
from pathlib import Path
from argparse import ArgumentParser

# get the path of the current file
file_path = Path(__file__).resolve()
# get the parent directory of the current file
config = yaml.safe_load(open(file_path.parent.parent.parent / "config/config.yaml"))  #load config.yaml file

def get_rnav_sample(sample, target):
    single_state_steps = {
        "shapemapper": {
            "shapemap": f"results/shapemapper/{sample}_{target}_profile.txt"
        },
        "ringmapper": {
            "ringmap": {"ringmap": f"results/ringmapper/{sample}_{target}_ringmap.txt", "sequence": "sequence"}
        },
        "pairmapper": {
            "pairmap": {"pairmap": f"results/pairmapper/{sample}_{target}-pairmap.txt", "sequence": "sequence"}
        },
        "fold_nodata": {
            "ss_nodata": {"ss": f"results/fold/{sample}_{target}_nodata.ct"},
            "pp_nodata": {"pairprob": f"results/fold/{sample}_{target}_nodata.dp", "sequence": "sequence"},
        },
        "fold_popavg": {
            "ss_popavg": {"ss": f"results/fold/{sample}_{target}_popavg.ct"},
            "pp_popavg": {"pairprob": f"results/fold/{sample}_{target}_popavg.dp", "sequence": "sequence"},
        },
        "fold_popavg_pairs": {
            "ss_popavg_pairs": {"ss": f"results/fold/{sample}_{target}_popavg_pairs.ct"},
            "pp_popavg_pairs": {"pairprob": f"results/fold/{sample}_{target}_popavg_pairs.dp", "sequence": "sequence"},
        },
    }
    kwargs = {}
    for step, data_keywords in single_state_steps.items():
        if step in config["steps"]:
            kwargs |= data_keywords
    if kwargs == {}:
        return None
    else:
        sample = rnav.Sample(
            sample=sample,
            sequence=config["samples"][sample]["target"],
            **kwargs
        )
        return sample

def get_rnav_dance_samples(sample, target):
    with open(f"results/dancemapper/{sample}_{target}-reactivities.txt") as dance_file:
        line = dance_file.readline()
    # split by ";", take first part, split by " ", take first part as integer
    components = int(line.split(';')[0].split(' ')[0])
    dance_samples = []
    for component in range(components):
        multi_state_steps = {
            "dancemapper_fit": {
                "dancemap": {"dancemap": f"results/dancemapper/{sample}_{target}-reactivities.txt", "component": component}
            },
            "dancemapper_rings_pairs": {
                "ringmap": {"ringmap": f"results/dancemapper/{sample}_{target}-{component}-rings.txt", "sequence": "sequence"},
                "pairmap": {"pairmap": f"results/dancemapper/{sample}_{target}-{component}-pairmap.txt", "sequence": "sequence"},
            },
            "fold_cluster": {
                "ss_cluster": {"ss": f"results/dancemapper/{sample}_{target}_nopairs-{component}.ct"},
                "pp_cluster": {"pairprob": f"results/dancemapper/{sample}_{target}_nopairs-{component}.dp", "sequence": "sequence"},
            },
            "fold_cluster_pairs": {
                "ss_cluster_pairs": {"ss": f"results/dancemapper/{sample}_{target}_pairs-{component}.ct"},
                "pp_cluster_pairs": {"pairprob": f"results/dancemapper/{sample}_{target}_pairs-{component}.dp", "sequence": "sequence"},
            },
        }
        kwargs = {}
        for step, data_keywords in multi_state_steps.items():
            if step in config["steps"]:
                kwargs |= data_keywords
        if kwargs == {}:
            return None
        dance_samples.append(
            rnav.Sample(
                sample=sample,
                sequence=config["samples"][sample]["target"],
                **kwargs
            )
        )
    return dance_samples

def plot_nodata(rnav_sample):
    plot = rnav.plot_arcs(
        samples=[rnav_sample],
        sequence="sequence",
        profile="shapemap",
        structure="ss_nodata",
        interactions="pp_nodata",
        plot_kwargs={"cols": 1},
    )
    return plot

def plot_popavg(rnav_sample):
    plot = rnav.plot_arcs(
        samples=[rnav_sample],
        sequence="sequence",
        profile="shapemap",
        structure="ss_popavg",
        interactions="pp_popavg",
        plot_kwargs={"cols": 1},
    )
    return plot

def plot_popavg_pairs(rnav_sample):
    plot = rnav.plot_arcs(
        samples=[rnav_sample],
        sequence="sequence",
        profile="shapemap",
        structure="ss_popavg_pairs",
        interactions="pp_popavg_pairs",
        interactions2="pairmap",
        plot_kwargs={"cols": 1},
    )
    return plot

def plot_cluster(rnav_dance_samples):
    plot = rnav.plot_arcs(
        samples=rnav_dance_samples,
        sequence="sequence",
        profile="dancemap",
        structure="ss_cluster",
        interactions="pp_cluster",
        plot_kwargs={"cols": 1},
    )
    return plot

def plot_cluster_pairs(rnav_dance_samples):
    plot = rnav.plot_arcs(
        samples=rnav_dance_samples,
        sequence="sequence",
        profile="dancemap",
        structure="ss_cluster_pairs",
        interactions="pp_cluster_pairs",
        interactions2="pairmap",
        plot_kwargs={"cols": 1},
    )
    return plot

if __name__ == "__main__":
    # Parse arguments
    parser = ArgumentParser()
    parser.add_argument("--sample", type=str, required=True)
    parser.add_argument("--target", type=str, required=True)
    args = parser.parse_args()
    # Get rnav samples
    rnav_sample = get_rnav_sample(args.sample, args.target)
    rnav_dance_samples = None
    single_state_plots = {
        "fold_nodata": plot_nodata,
        "fold_popavg": plot_popavg,
        "fold_popavg_pairs": plot_popavg_pairs
    }
    multi_state_plots = {
        "fold_cluster": plot_cluster,
        "fold_cluster_pairs": plot_cluster_pairs,
    }
    for step in config["steps"]:
        if step in single_state_plots:
            plot = single_state_plots[step](rnav_sample)
        elif step in multi_state_plots:
            if rnav_dance_samples is None:
                rnav_dance_samples = get_rnav_dance_samples(args.sample, args.target)
            plot = multi_state_plots[step](rnav_dance_samples)
        else:
            continue
        suffix = step.split("_", 1)[1]
        plot.save(f"results/figures/{args.sample}_{args.target}_{suffix}.svg")
