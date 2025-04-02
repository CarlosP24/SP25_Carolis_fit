using Pkg
Pkg.activate("plots")
Pkg.instantiate()
using CairoMakie, Parameters, JLD2, Quantica, FullShell

##

function plot_LDOS(pos, name::String; basename = "LDOS", colorrange = (0, 2e-2))
    res = load("data/$(basename)/$(name).jld2", "res")
    @unpack wire, LDOS, params = res
    @unpack Brng, ωrng = params

    ax = Axis(pos; xlabel = "B (T)", ylabel = "ω (meV)")

    ωrng = vcat(real(ωrng), - reverse(real(ωrng))[2:end])
    LDOS = LDOS |> values |> sum
    LDOS = hcat(LDOS, reverse(LDOS, dims = 2)[:, 2:end])
    heatmap!(ax, Brng, ωrng, LDOS; colormap = :thermal, colorrange)
    return ax 
end

function plot_conductance(pos, name::String; basename = "Conductance", colorrange = (0, 1))
    res = load("data/$(basename)/$(name).jld2", "res")
    @unpack wire, G, params = res
    @unpack Brng, ωrng = params
    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$ω$ (meV)")

    ωrng = vcat(real(ωrng), - reverse(real(ωrng))[2:end])
    G = G |> values |> sum
    G = hcat(G, reverse(G, dims = 2)[:, 2:end])
    heatmap!(ax, Brng, ωrng, G; colormap = :thermal, colorrange)
    return ax 
end

function find_B(B, Brng)
    return findmin(abs.(Brng .- B))[2]
end

function plot_linecut(pos, name::String, basename::String; Φs = [0, 1, 2], ylabel = L"$$ LDOS")
    res = load("data/$(basename)/$(name).jld2", "res")
    @unpack wire, G, LDOS, params  = res
    @unpack Brng, ωrng = params

    if basename == "LDOS"
        data = LDOS
    else
        data = G
    end

    ΦtoB = get_B(wire)
    Bs = ΦtoB.(Φs)
    print(Bs)
    Bis = map(B ->find_B(B, Brng), Bs)

    ωrng = vcat(real(ωrng), - reverse(real(ωrng))[2:end])
    data = data |> values |> sum
    data = hcat(data, reverse(data, dims = 2)[:, 2:end])

    ax = Axis(pos; xlabel = "ω (meV)", ylabel)

    for (i, Bi) in enumerate(Bis)
        lines!(ax, ωrng, data[Bi, :], label = L"$\Phi = %$(Φs[i]) \Phi_0$")
    end

    axislegend(ax, position = (0.5,1), framevisible = false)
    return ax
end

function plot_proposal()
    fig = Figure(size = (600, 800))
    ax = plot_LDOS(fig[1, 1], "dev_1")
    hidexdecorations!(ax, ticks = false)
    Colorbar(fig[1, 2], colormap = :thermal, limits = (0, 1), ticks = [0, 1], label = L"$$LDOS (arb. units)", labelpadding = -10)
    ax = plot_conductance(fig[2, 1], "sys_1"; colorrange = (0, 0.5))
    Colorbar(fig[2, 2], colormap = :thermal, limits = (0, 0.5), ticks = [0, 0.4], label = L"$G$ $(e^2/h)$", labelpadding = -20)

    fig_cuts = fig[3, 1:2] = GridLayout()

    ax = plot_linecut(fig_cuts[1, 1], "dev_1", "LDOS"; Φs = [0, 1, 2])
    ax = plot_linecut(fig_cuts[1, 2], "sys_1", "Conductance"; Φs = [0, 1, 2], ylabel = L"G (e^2/h)")

    rowgap!(fig.layout, 1, 5)
    rowgap!(fig.layout, 2, 5)
    colgap!(fig.layout, 1, 5)
    return fig 
end
o
fig = plot_proposal()