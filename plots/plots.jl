using Pkg
Pkg.activate("plots")
Pkg.instantiate()
using CairoMakie, Parameters, JLD2, Quantica, FullShell, CSV, Tables

##

function plot_LDOS(pos, name::String; basename = "LDOS", colorrange = (0, 3e-3), vlines = [0, 1, 2])
    res = load("data/$(basename)/$(name).jld2", "res")
    @unpack wire, LDOS, params = res
    @unpack Brng, ωrng = params

    ax = Axis(pos; xlabel = "B (T)", ylabel = "ω (meV)")

    #ωrng = vcat(real(ωrng), - reverse(real(ωrng))[2:end])
    ωrng = ωrng |> real
    LDOS = LDOS |> values |> sum .|> abs
    #LDOS = hcat(LDOS, reverse(LDOS, dims = 2)[:, 2:end])
    heatmap!(ax, Brng, ωrng, LDOS; colormap = :thermal, colorrange, rasterize = 5)
    ΦtoB = get_B(wire)
    vlines!(ax, ΦtoB.(vlines); color = :white, linestyle = :dash)

    return ax 
end

function export_LDOS(name::String; basename = "LDOS")
    res = load("data/$(basename)/$(name).jld2", "res")
    @unpack LDOS = res
    LDOS = LDOS |> values |> sum .|> abs
    CSV.write("data/$(basename)/$(name)_LDOS.csv", Tables.table(LDOS), writeheader=false)
end



function plot_conductance(pos, name::String; basename = "Conductance", colorrange = (0, 1), vlines = [1, 2])
    res = load("data/$(basename)/$(name).jld2", "res")
    @unpack wire, G, params, barrier = res
    @unpack Brng, ωrng = params
    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$ω$ (meV)")

    #ωrng = vcat(real(ωrng), - reverse(real(ωrng))[2:end])
    ωrng = ωrng |> real
    G = G |> values |> sum .|> abs
    #G = hcat(G, reverse(G, dims = 2)[:, 2:end])
    heatmap!(ax, Brng, ωrng, G; colormap = :thermal, colorrange, rasterize = 5)

    ΦtoB = get_B(wire)
    vlines!(ax, ΦtoB.(vlines); color = :white, linestyle = :dash)
    text!(ax, 0, 0.02; text = L"$V_B = %$(barrier.VB)$meV", color = :white, fontsize = 12, align = (:center, :center))
    text!(ax, 0, -0.02; text = L"$L_B = %$(barrier.LB)$nm", color = :white, fontsize = 12, align = (:center, :center))


    return ax 
end

function export_conductance(name::String; basename = "Conductance")
    res = load("data/$(basename)/$(name).jld2", "res")
    @unpack G = res
    G = G |> values |> sum .|> abs
    CSV.write("data/$(basename)/$(name)_Conductance.csv", Tables.table(G), writeheader=false)
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

    #ωrng = vcat(real(ωrng), - reverse(real(ωrng))[2:end])
    ωrng = ωrng |> real
    data = data |> values |> sum .|> abs
    #data = hcat(data, reverse(data, dims = 2)[:, 2:end])

    ax = Axis(pos; xlabel = "ω (meV)", ylabel)

    for (i, Bi) in enumerate(Bis)
        lines!(ax, ωrng, data[Bi, :], label = L"$\Phi = %$(Φs[i]) \Phi_0$")
    end

    axislegend(ax, position = (0.3,1), framevisible = false)
    return ax
end

function plot_proposal()
    fig = Figure(size = (600, 800)) 
    ax = plot_LDOS(fig[1, 1], "dev_1")
    hidexdecorations!(ax, ticks = false)
    Colorbar(fig[1, 2], colormap = :thermal, limits = (0, 1), ticks = [0, 1], label = L"$$LDOS (arb. units)", labelpadding = -10)
    ax = plot_conductance(fig[2, 1], "sys_1"; colorrange = (0, 0.5))
    hlines!(ax, 0; color = :white, linestyle = :dash)
    Colorbar(fig[2, 2], colormap = :thermal, limits = (0, 0.5), ticks = [0, 0.4], label = L"$G$ $(e^2/h)$", labelpadding = -20)

    fig_cuts = fig[3, 1:2] = GridLayout()

    ax = plot_linecut(fig_cuts[1, 1], "dev_1", "LDOS"; Φs = [0, 1, 2])
    ax = plot_linecut(fig_cuts[1, 2], "sys_1", "Conductance"; Φs = [0, 1, 2], ylabel = L"G (e^2/h)")

    Label(fig_cuts[1, 1, Top()], "LDOS")
    Label(fig_cuts[1, 2, Top()], "Conductance")
    rowgap!(fig.layout, 1, 5)
    rowgap!(fig.layout, 2, 5)
    colgap!(fig.layout, 1, 5)
    return fig 
end

fig = plot_proposal()
save("plots/figures/2025_04_07_proposal.pdf", fig)
export_LDOS("dev_1")
export_conductance("sys_1")
fig