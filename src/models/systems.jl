@with_kw struct System
    wire::Params
    barrier_params::Barrier_params = Barrier_params()
    calc_params::Calc_Params = Calc_Params()
end

systems = Dict(
    "sys_1" => System(;
        wire = wires["dev_1"],
        barrier_params = Barrier_params(;
            LB = 60,
            VB = 70
        )
    )
)