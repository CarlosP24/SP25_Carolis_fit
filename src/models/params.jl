@with_kw struct Calc_Params
    Brng = subdiv(-0.0925, 0.3275, 101)
    ωrng = subdiv(-.26, 0,  101) .+ 1e-3im
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