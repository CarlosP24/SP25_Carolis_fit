# Caroli-de Gennes-Matricon Analogs in Full-Shell Hybrid Nanowires theory model code

[![DOI](https://zenodo.org/badge/956493600.svg)](https://doi.org/10.5281/zenodo.15181152)

Code used to produce the theory figures of the manuscript [Caroli-de Gennes-Matricon Analogs in Full-Shell Hybrid Nanowires](https://arxiv.org/abs/2501.05419).

Based on [Quantica.jl](https://github.com/pablosanjose/Quantica.jl) and [FullShell.jl](https://github.com/CarlosP24/FullShell.jl).

## Usage
This code is prepared to run either in a slurm-managed cluster or locally. Requires [Julia 1.11.1](https://julialang.org/) and/or [juliaup](https://github.com/JuliaLang/juliaup). All other dependencies are installed automatically in a Julia environment when running the code for the first time.

To run in a cluster, set up a `launch_clustername.sh` file like the examples in `bin` and run
```
$ bash bin/launch_clustername.sh calc_name
```

To run locally, run from the repository root directory
```
$ julia --project bin/launch_local.jl calc_name
```

where `calc_name` is the key to a dictionary in `models/wires.jl` or `models/systems.jl` followed by `ldos` or `cond`. To reproduce the results shown in the manuscript, use  `dev_1_ldos` for the LDOS and `sys_1_cond` for the dI/dV.

Results are stored in `data`. Code in `plots` is used to produce preliminary figures and export data to non-julia formats.

Slurm launching code is available as a standalone template in [slurm_julia_block](https://github.com/CarlosP24/slurm_julia_block).