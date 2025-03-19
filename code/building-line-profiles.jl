include("common.jl")
using StatsBase

m = KerrMetric(a = 0.99)
x = SVector(0.0, 1000.0, deg2rad(60), 0.0)
d1 = ThinDisc(0.0, 100.0)

pf = ConstPointFunctions.redshift(m, x) ∘
    # filter only those geodesics that intersected with
    # geometry
    ConstPointFunctions.filter_intersected()

α, β, cache = prerendergeodesics(
  m, x, d1, 2x[2]; 
  verbose = true,
  αlims = (-100, 100),
  βlims = (-50, 50),
  image_width = 1080,
  image_height = 720,
  callback = domain_upper_hemisphere(),
)

img = apply(pf, cache)
radii_img = apply(PointFunction((m, gp, tau) -> Gradus._equatorial_project(gp.x)) ∘ ConstPointFunctions.filter_intersected(), cache)

# make redshift histogram
redshift_data = filter(!isnan, vec(img))

x_bins = range(0.0, 1.4, 28) 
lineprof = StatsBase.fit(Histogram, redshift_data, x_bins)
r_bins = range(1.0, 100.0, 30)
radii_hist = StatsBase.fit(Histogram, filter(!isnan, vec(radii_img)), r_bins)

d2 = ThinDisc(0.0, Inf)

gs = range(0.0, 1.4, 180)
# the transfer functions can be computed once and reused for each but i am lazy
_, flux1 = lineprofile(m, x, d2; bins = gs, maxrₑ = 100.0, verbose = true)

begin
    bgcolor = RGBAf(1.0,1.0,1.0,0.0)
    fig = Figure(size = (600, 250), backgroundcolor=bgcolor)
    ga = fig[1,1] = GridLayout()

    xlims!(ax1, -26, 26)
    ylims!(ax1, -15, 19)

    ax2 = Axis(ga[1,1], title = "Redshift Profile", xlabel = "g", ylabel = "Fraction", backgroundcolor=bgcolor)
    barplot!(ax2, x_bins[1:end-1], lineprof.weights ./ sum(lineprof.weights), color = x_bins[1:end-1], colormap = :batlow)
    
    ga_sub = ga[1,2] = GridLayout()
    ax_mini = Axis(ga_sub[1,1], xscale = log10, yscale = log10, title = "Em. Prof.", backgroundcolor=bgcolor)    
    hidedecorations!(ax_mini, grid=false)
    space = Axis(ga_sub[2,1], 
        # topspinecolor = RGBAf(0.0,0.0,0.0,0.0),
        # bottomspinecolor = RGBAf(0.0,0.0,0.0,0.0),
        # leftspinecolor = RGBAf(0.0,0.0,0.0,0.0),
        # rightspinecolor = RGBAf(0.0,0.0,0.0,0.0),
        title = "Radial Dist.",
        yscale = log10,
        xscale = log10,
        backgroundcolor = bgcolor,
    )    
    hidedecorations!(space, grid=false)
    rowsize!(ga_sub, 1, Relative(1/3))
    rowsize!(ga_sub, 2, Relative(1/3))

    lines!(space, r_bins[1:end-1], radii_hist.weights ./ sum(radii_hist.weights))
    xlims!(space, 1, 90)
    
    _palette = _default_palette()
    radii = collect(range(Gradus.isco(m), 1000.0, 100))
    lines!(ax_mini, radii, radii.^(-3), color = popfirst!(_palette))

    
    ax3 = Axis(ga[1,3], title = "Line Profile", xlabel = "E / E₀", ylabel = "Flux (arb.)", yaxisposition=:right, backgroundcolor=bgcolor)
    
    _palette = _default_palette()
    for flux in (flux1,)
        lines!(ax3, gs, flux, color = popfirst!(_palette))
    end

    colsize!(ga, 1, Relative(0.40))
    colsize!(ga, 2, Relative(1/8))
    colgap!(ga, 50)
    
    save("rawfigs/building-line-profiles.svg", fig)
    fig
end
