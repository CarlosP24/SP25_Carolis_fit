@with_kw struct Barrier_params
    LB::Float64 = 50
    VB::Float64 = 100
end

function lorentzian(x::Float64, x0::Float64, σ::Float64)
    γ = σ/2
    d = (x - x0)^2 + γ^2
    return γ^2 / d
end

function barrier_v2(params::Barrier_params)
    @unpack LB, VB = params
    σ = LB/4
    z0 = 6 * σ
    LC = 12 * σ
    V(z) = VB * lorentzian(z, z0, σ)
    return V, LC
end

function barrier_v1(params::Barrier_params)
    @unpack LB, VB = params
    return z -> VB * exp(-25 * (z - LB/2)^2/LB^2), LB
end

function build_SC(wire::Params, L::Float64)
    @unpack R, d, Δ0, ξd, shell, τΓ = wire 
    Λ(Φ) = pairbreaking(Φ, round(Int, Φ), Δ0, ξd, R, d)
    if shell == "Usadel"
        ΣS = FullShell.ΣS3DUsadel
    elseif shell == "Ballistic"
        ΣS = FullShell.ΣS3DBallistic
    elseif shell == "Usadel_old" 
        ΣS = FullShell.ΣS3DUsadel_old
    else
        ΣS = FullShell.ΣΔ
    end
    ΣS! = @onsite!((o, r; ω = 0, Φ = 0, τΓ = τΓ) ->
            o + τΓ * ΣS(Δ0, Λ(Φ), ω);
            region = r -> r[1] >= L
    )
    return ΣS!
end

function build_barrier_v2(h::Quantica.AbstractHamiltonian1D, wire::Params, barrier_params::Barrier_params)
    @unpack R, w, a0 = wire
    @unpack LB = barrier_params
    V, LC = barrier(barrier_params)

    # Onsite modifier
    V! = @onsite!((o, r;) -> 
        o + V(r[1]) * σ0τz;
    )

    # Central region
    hC = h |> supercell(region = r -> 0 <= r[1] <= LC)

    # Add barrier and SC
    ΣS! = build_SC(wire, 2 * LB)
    hCS = hC |> ΣS! |> V!

    return hCS, LC
end

function build_barrier_v1(h::Quantica.AbstractHamiltonian1D, wire::Params, barrier_params::Barrier_params)
    @unpack R, w, a0 = wire
    @unpack LB = barrier_params
    V, LC = barrier_v1(barrier_params)

    # Onsite modifier
    V! = @onsite!((o, r;) -> 
        o + V(r[1]) * σ0τz;
    )

    # Central region
    hC = h |> supercell(region = r -> 0 <= r[1] <= LC)

    hCS = hC |> V!

    return hCS, LC
end