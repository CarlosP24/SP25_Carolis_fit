function pfΦωZ(f, Φrng, ωrng, Zs; kw...)
    pts = Iterators.product(Φrng, ωrng, Zs)
    FΦωZ = @showprogress pmap(pts) do pt
        Φ, ω, Z = pt 
        ld = try
            f(ω; ω, Φ, Z, kw...)
        catch
            NaN
        end
        return sum(ld)
    end
    FΦωZarray = reshape(FΦωZ, size(pts)...)
    FΦωZdict = Dict(Z => FΦωZarray[:, :, i] for (i, Z) in enumerate(Zs))
    return FΦωZdict
end