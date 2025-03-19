include("common.jl")

m = KerrMetric(1.0, 0.998)
x = SVector(0.0, 1e4, deg2rad(60), 0.0)
d = ThinDisc(0.0, Inf)

tfs = transferfunctions(m, x, d; verbose = true)

heights = reverse([2.0, 5.0, 10.0, 20.0])
profs = map(heights) do h
    model = LampPostModel(h = h, θ = 1e-4)
    emissivity_profile(m, d, model; n_samples = 5000)
end

bins = collect(range(0.01, 1.46, 500))
lps = map(profs) do prof
    integrate_lineprofile(prof, tfs, bins)
end

begin
    bgcolor = RGBAf(1.0,1.0,1.0,0.0)
    fig = Figure(size = (600, 360), backgroundcolor = bgcolor)
    ax1 = Axis(fig[2,1], xscale = log10, yscale = log10, xticks = [1, 2, 5, 10, 20, 50], xminorticksvisible = true, xminorticks = [3, 4, 6, 7, 8, 9, 30, 40, 60, 70, 80, 90], xlabel = "Radius on disc", ylabel = "Emissivity", backgroundcolor = bgcolor)
    ylims!(ax1, 1e-8, 2)
    xlims!(ax1, 0.9, 1e2)

    ax2 = Axis(fig[2,2], yaxisposition = :right, xlabel = "E/E₀", ylabel = "Flux (normalised)", backgroundcolor = bgcolor)
    xlims!(ax2, 0.01, 1.5)
    ylims!(ax2, 0, nothing)

    c = _default_palette()
    _lins = map(profs) do prof
        lines!(ax1, prof.radii, prof.ε, color = popfirst!(c))
    end
    c = _default_palette()
    for lp in lps
        lines!(ax2, bins, lp, color = popfirst!(c))
    end

    Legend(
        fig[1, 1:2],
        _lins, 
        ["h = $(trunc(Int,i))" for i in heights],
        orientation = :horizontal,
        framewidth = 0,
        backgroundcolor = bgcolor
    )

    save("rawfigs/emissivity-changes-lineshape.svg", fig)
    fig
end