function calc_Conductance(name::String)
    system = systems[name]

    @unpack wire, barrier_params, calc_params = system
    @unpack Brng, ωrng, outdir = calc_params

    # Setup output path
    path = "$(outdir)/Conductance/$(name).jld2"
    mkpath(dirname(path))

    # Build leads
    hSM, hSC, params = build_cyl(wire)

    # Superconducting lead 
    gS = hSC |> greenfunction(GS.Schur(boundary = 0))

    # Normal lead
    gN = hSM |> greenfunction(GS.Schur(boundary = 0))

    # Central region 
    hC, LC = build_barrier(hSM, params, barrier_params)

    # Build system
    g = hC |> attach(gS; region = r -> r[1] == LC) |> attach(gN; region = r -> r[1] == 0) |> greenfunction()

    # Calculate conductance
    BtoΦ = get_Φ(wire)
    Φrng = BtoΦ.(Brng)
    Zs = wire.Zs
    G = pfΦωZ(conductance(g[2, 2]; nambu = true), Φrng, ωrng, Zs)

    return Results(;
        params = calc_params,
        wire = wire,
        barrier = barrier_params,
        G = G,
        path = path
    )
end