using Makie,CairoMakie,Gradus
using StatsBase

function trace(m, x; blims = (-7, 14))
    d = ThinDisc(Gradus.isco(m), 20.0)
    pf = ConstPointFunctions.redshift(m, x) ∘ ConstPointFunctions.filter_intersected()
    α, β, img = @time rendergeodesics(
        m,
        x,
        d,
        # maximum integration time
        2000.0,
        βlims = blims,
        αlims = (-23, 23),
        image_width = 1080,
        image_height = 720,
        verbose = true,
        callback = domain_upper_hemisphere(),
        pf = pf,
    )
end

# metric and metric parameters
m = KerrMetric(M=1.0, a=0.0)
# observer position
x = SVector(0.0, 1000.0, deg2rad(78), 0.0)

α1, β1, img1 = trace(m, x)
m = KerrMetric(M=1.0, a=0.998)
α2, β2, img2 = trace(m, x)


begin
    fig = Figure(size = (400, 350), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))

    ga = fig[1,1] = GridLayout()

    colorrange = (0.4, 1.6)

    ax1 = Axis(ga[1,1], aspect = DataAspect(), title = "Schwarzschild", ylabel = "β", xlabel = "α", backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))
    ax2 = Axis(ga[2,1], aspect = DataAspect(), title = "Kerr", ylabel = "β", xlabel = "α", backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))
    _ = heatmap!(ax1, α1, β1, img1', colormap = Reverse(:seismic), colorrange = colorrange)
    hm = heatmap!(ax2, α2, β2, img2', colormap = Reverse(:seismic), colorrange = colorrange)

    hidexdecorations!(ax1, grid = false)

    contour!(ax1, α1, β1, img1', color = :black, levels = 10)
    contour!(ax2, α2, β2, img2', color = :black, levels = 10)
    Colorbar(ga[1:2,2], hm, colorrange = colorrange, label = "Redshift")

    rowgap!(ga, 0)

    save("rawfigs/redshift.png", fig, px_per_point = 2)
    fig
end

rs_schwarz = filter(!isnan, img1)
rs_kerr = filter(!isnan, img2)

x_bins = range(0.0, 1.5, 50) 
rs_hist = StatsBase.fit(Histogram, rs_schwarz, x_bins)
rk_hist = StatsBase.fit(Histogram, rs_kerr, x_bins)

begin
    bgcolor = RGBAf(1.0,1.0,1.0,0.0)
    fig = Figure(size=(350, 210), backgroundcolor = bgcolor)
    ax = Axis(fig[1,1], title = "Redshift Profile", xlabel = "g", ylabel = "Fraction", backgroundcolor = bgcolor)
    xlims!(ax, 0, 1.5)
    stairs!(ax, x_bins[1:end-1] .+ diff(x_bins) ./ 2, rs_hist.weights ./ sum(rs_hist.weights), linewidth = 2.0)
    stairs!(ax, x_bins[1:end-1]  .+ diff(x_bins) ./ 2, rk_hist.weights ./ sum(rk_hist.weights), linewidth = 2.0)
    save("rawfigs/redshift-profiles.svg", fig)
    fig
end