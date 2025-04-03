@with_kw struct Calc_Params
    Brng = subdiv(-0.0925, 0.3275, 801)
    ωrng = subdiv(-.26, .26, 601) .+ 1e-3im
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