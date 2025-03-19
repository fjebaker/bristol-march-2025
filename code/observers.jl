using Gradus, Makie, CairoMakie

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

angles = [2, 30, 60, 88]
data = map(angles) do angle
    @info angle
    x = SVector(0.0, 1000.0, deg2rad(angle), 0.0)
    m = KerrMetric(M=1.0, a=0.0)
    d1 = trace(m, x, blims = (-23, 23))
    m = KerrMetric(M=1.0, a=0.998)
    d2 = trace(m, x, blims = (-23, 23))
    (d1, d2)
end

begin
    fig = Figure(size = (800, 2 * 220), backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))

    ga = fig[1,1] = GridLayout()

    colorrange = (0.4, 1.6)

    for (i, row) in enumerate(data)
        ax1 = Axis(ga[1, i], aspect = DataAspect(), title = "θ = $(angles[i])", ylabel = "β", xlabel = "α", backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))
        ax2 = Axis(ga[2, i], aspect = DataAspect(), xlabel = "α", ylabel = "β", backgroundcolor = RGBAf(0.0,0.0,0.0,0.0))
        heatmap!(ax1, row[1][1], row[1][2], row[1][3]', colormap = Reverse(:seismic), colorrange = colorrange)
        heatmap!(ax2, row[2][1], row[2][2], row[2][3]', colormap = Reverse(:seismic), colorrange = colorrange)

        # contour!(ax1, row[1][1], row[1][2], row[1][3]', color = :black, levels = 10)
        # contour!(ax2, row[2][1], row[2][2], row[2][3]', color = :black, levels = 10)

        hidexdecorations!(ax1, grid = false)
        if i > 1
            hideydecorations!(ax1, grid = false)
            hideydecorations!(ax2, grid = false)
        end
    end

    colgap!(ga, 2)
    colgap!(ga, 2)

    save("rawfigs/redshift-observer.png", fig, px_per_point = 2)
    fig
end
