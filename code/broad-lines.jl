using Gradus, SpectralFitting, Reflionx
using Makie, CairoMakie

_default_palette() = Iterators.Stateful(Iterators.Cycle(Makie.wong_colors()))

function get_values(erange, spec)
    interp = Gradus._make_interpolation(spec.energy, spec.flux)
    interp.(erange)[1:end-1] ./ diff(erange)
end

reftable = Reflionx.parse_run("/home/lilith/developer/jl/data/reflionx/grid")
ref_spec = reftable.grids[4, 2, 3]

reftable.params[1][4]

m = KerrMetric(1.0, 0.998)
x = SVector(0.0, 10_000.0, deg2rad(40), 0.0)
d = ThinDisc(0.0, Inf)
tfs = transferfunctions(m, x, d; verbose = true)

model = LampPostModel(h = 10.0)

profile = emissivity_profile(m, d, model)
bins = collect(range(0.01, 1.5, 300))
f2 = integrate_lineprofile(profile, tfs, bins)
f2 ./= sum(f2)


_erange = collect(Gradus.Grids._geometric_grid(0.08, 100.1, 901))
# upscale the grid we are interested in
values = get_values(_erange, ref_spec)
erange = _erange[1:end-1]

tmp = zeros(Float64, length(values) - 1)

SpectralFitting.convolve!(tmp, values[1:end-1], erange, f2[1:end-1], bins)

begin
    bgcolor = RGBAf(1.0,1.0,1.0,0.0)
    fig = Figure(size=(580, 330), backgroundcolor=bgcolor)
    ax = Axis(fig[1,1], xscale = log10, yscale = log10, xlabel = "E (keV)", ylabel = "Flux", backgroundcolor=bgcolor)

    ylims!(ax, 70, nothing)
    xlims!(ax, extrema(erange[1:end-1])...)


    color = _default_palette()
    lines!(ax, erange, get_values(_erange, reftable.grids[4, 1, 3]), color = :grey, alpha = 0.4)
    lines!(ax, erange, get_values(_erange, reftable.grids[4, 3, 3]), color = :grey, alpha = 0.4)
    reg = lines!(ax, erange, values, color = popfirst!(color))
    blur = lines!(ax, erange[1:end-1], tmp, linewidth = 2.0, color = popfirst!(color))
    kernel = lines!(ax, bins .* 6.4 .+ 1e-11, (f2 .+ 1e-11) .* 0.2e6, color = popfirst!(color))

    pl = lines!(ax, erange, erange.^(-2.0) .* 1.3e5, linestyle = :dash, color = :grey)

    Legend(fig[1,2], [reg, blur, kernel, pl], ["Rest", "Blurred", "Lineprofile", "Powerlaw"], backgroundcolor = bgcolor)

    save("rawfigs/broad-lines.svg", fig)
    fig
end



bins = collect(range(0.01, 1.5, 400))

arange = range(0.0, 0.9982, 5)
lineprofs = map(arange) do a
    m = KerrMetric(1.0, a)
    tfs = transferfunctions(m, x, d; verbose = true)
    integrate_lineprofile(r -> r^-3, tfs, bins)
end

angles = range(10, 80, 7)
lineprofs2 = map(angles) do ang
    m = KerrMetric(1.0, 0.998)
    tfs = transferfunctions(m, SVector(0.0, 1e4, deg2rad(ang), 0.0), d; verbose = true, numrₑ = 200)
    integrate_lineprofile(r -> r^-3, tfs, bins)
end

begin 
    fig = Figure(size = (400, 600), backgroundcolor = bgcolor)
    ax1 = Axis(fig[1,1], ylabel = "Flux (normalised)", title = "Spins",  backgroundcolor = bgcolor)
    ax2 = Axis(fig[2,1], ylabel = "Flux (normalised)", xlabel = "E / E₀", title = "Inclination",  backgroundcolor = bgcolor)

    xlims!(ax1, 0.1, 1.21)
    xlims!(ax2, 0.1, 1.48)
    ylims!(ax1, 0, nothing)
    ylims!(ax2, 0, nothing)

    for (i, lp) in enumerate(lineprofs)
        lines!(ax1, bins, lp)
    end

    for (i, lp) in enumerate(lineprofs2)
        lines!(ax2, bins, lp)
    end

    save("rawfigs/line-profiles.svg", fig)
    fig
end

m = KerrMetric(1.0, 0.998)
x = SVector(0.0, 1e4, deg2rad(42), 0.0)
d = ThinDisc(0.0, Inf)

bins = collect(range(2.0, 10.0, 300))
tfs = transferfunctions(m, x, d; verbose = true, maxrₑ = 30, numrₑ = 100)
f2 = integrate_lineprofile(profile, tfs, bins ./ 6.4)


begin
    fig = Figure()
    ax = Axis(fig[1,1], xscale = log10, 
        xticks = [2, 5, 10],
        xminorticks = [2, 3, 4, 5, 6, 7, 8, 9, 10],
        xminorgridvisible = true,
        xminorticksvisible = true,
    )
    ylims!(-0.02, 0.05)
    xlims!(2, 10)
    palette = _default_palette()

    hlines!(ax,[0], color = :black, linestyle = :dash)
    lines!(ax, bins, f2, color = popfirst!(palette))
    vlines!(ax,[6.4], color = popfirst!(palette))
    fig
end