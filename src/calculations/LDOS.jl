function calc_LDOS(name::String)
    wire_system = wire_systems[name]
    @unpack wire, calc_params = wire_system
    @unpack Brng, ωrng, outdir = calc_params

    # Setup output path
    path = "$(outdir)/LDOS/$(name).jld2"
    mkpath(dirname(path))

    # Build nanowire
    hSM, hSC, params = build_cyl(wire)

    # Get Greens function
    g = hSC |> greenfunction(GS.Schur(boundary = 0))

    BtoΦ = get_Φ(wire)
    Φrng = BtoΦ.(Brng)
    Zs = wire.Zs
    LDOS = pfΦωZ(ldos(g[cells = (-1,)]), Φrng, ωrng, Zs)

    return Results(;
        params = calc_params,
        wire = wire,
        LDOS = LDOS,
        path = path
    )   
end