using JLD2
@everywhere begin
    using Quantica, FullShell
    using ProgressMeter, Parameters
    include("functions.jl")

    # Load builders
    include("builders/Barrier.jl")

    # Load models
    include("models/params.jl")
    include("models/wires.jl")
    include("models/systems.jl")

    # Load parallelizers
    include("parallelizers/3params.jl")

    # Load calculations
    include("calculations/LDOS.jl")
    include("calculations/Conductance.jl")
end

## Run 
key = ARGS[1]

kwires = wire_systems |> keys |> collect
ksys = systems |> keys |> collect

if key in kwires .* "_ldos"
    truekey = replace(key, "_ldos" => "")
    @info "Computing wire $truekey LDOS"
    res = calc_LDOS(truekey)
    save(res.path, "res", res)
    @info "Finished computing wire $truekey LDOS"
elseif key in ksys .* "_cond"
    truekey = replace(key, "_cond" => "")
    @info "Computing wire $truekey conductance"
    res = calc_Conductance(truekey)
    save(res.path, "res", res)
    @info "Finished computing wire $truekey conductance"
else
    @error "Key $key not found"
end
