@with_kw struct Calc_Params
    Brng = subdiv(-0.093, 0.333, 801)
    ωrng = subdiv(-0.325, 0.325, 601) .+ 3e-3im
    outdir = "data"
end

@with_kw struct Results
    params = nothing
    wire = nothing
    barrier = nothing
    LDOS = nothing
    G = nothing
    path = nothing
end