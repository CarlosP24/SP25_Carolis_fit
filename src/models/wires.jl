@with_kw struct wire_system
    wire::Params
    calc_params = Calc_Params()
end

wires = Dict(
    "dev_1" => Params(;
        a0 = 1,
        R = 68.5,
        w = 45,
        d = 7,
        Δ0 = 0.2,
        ξd = 90,
        τΓ = 22,
        α = 0,
        preα = 0,
        μ = 35,
        g = 0,
        shell = "Usadel_old",
        Zs = -6:6
    )
)

wire_systems = Dict(
    key => wire_system(; wire) for (key, wire) in wires
)