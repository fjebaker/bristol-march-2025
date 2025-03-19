include("common.jl")

m = KerrMetric(1.0, 0.5)
d = ThinDisc(0.0, Inf)
dim = 30

begin
    bgcolor = RGBAf(1.0,1.0,1.0,0.0)
    fig = Figure(size = (800, 600), backgroundcolor = bgcolor)
    ax = Axis3(
        fig[1, 1],
        aspect = (1, 1, 1),
        limits = (-dim, dim, -dim, dim, -dim, dim),
        elevation = π / 23, #π / 12,
        azimuth = -deg2rad(65),
        viewmode = :fitzoom,
        xgridvisible = false,
        ygridvisible = false,
        zgridvisible = false,
        xlabelvisible = false,
        ylabelvisible = false,
        xspinewidth = 0,
        yspinewidth = 0,
        zspinewidth = 0,
        backgroundcolor = bgcolor,
    )
    hidedecorations!(ax)

    R = Gradus.inner_radius(m)
    bounding_sphere!(ax; R = R, color = :black)

    outer = 29.0
    
    last_r = 0.0
    for r in range(Gradus.isco(m), outer, step = 2)
        plotring(ax, r; height = 0,  horizon_r = R, color = :black, dim = dim)
        last_r = r
    end

    N = 20
    for θ in range(0, 2π * (1 - 1/N), N)
        plot_obscured_line!(ax, 
            SVector(Gradus.isco(m) * cos(θ), Gradus.isco(m) * sin(θ), 0),
            SVector(last_r * cos(θ), last_r * sin(θ), 0)
            ;
            color = :black,
            horizon_r = R,
        )
    end

    Makie.save("rawfigs/toy-accretion.svg", fig)
    fig
end


x = SVector(0.0, 1e4, π/2 - π/23, 0.0)

begin
    radii = range(Gradus.isco(m), outer, step = 2) |> collect
    r_impacts = map(radii) do r
        α, β = impact_parameters_for_radius(m, x, d, r, N=300)
    end

    radii = range(Gradus.isco(m), last(radii), 100)

    progress_bar = Gradus.init_progress_bar("Progress:", 100, true)
    impacts = Gradus._threaded_map(radii) do r
        res = impact_parameters_for_radius(m, x, d, r, N=2000)
        Gradus.ProgressMeter.next!(progress_bar)
        res
    end

    all_ps = map(impacts) do dat
        a, b = dat
        vs = map_impact_parameters(m, x, a, b)
        xs = fill(x, size(vs))
        gps = tracegeodesics(m, xs, vs, d, 2x[2], ensemble = Gradus.EnsembleEndpointThreads())
    end

    ang_diff = Gradus.ang_diff

    line_p = map(range(0, 2π * (1 - 1/N), N)) do ang
        map(enumerate(all_ps)) do dat
            i, gps = dat
            v, index = findmin(i -> abs(mod2pi(i.x[4]) - mod2pi(ang - deg2rad(65))), gps)
            aa, bb = impacts[i]
            aa[index], bb[index]
        end
    end ; 

    "Done"
end

aa, bb, img = rendergeodesics(
    m, x, ThinDisc(Gradus.isco(m), Inf), 2e4,
    image_width = 500,
    image_height = 500,
    pf = PointFunction((m, gp, t) -> gp.x[1]) ∘ FilterPointFunction((m, gp, t) -> gp.status == Gradus.StatusCodes.WithinInnerBoundary, NaN),
    αlims = (-8, 8),
    βlims = (-8, 8),
    verbose = true,
)

begin
    fig = Figure(backgroundcolor=bgcolor)
    ax = Axis(fig[1,1], aspect = DataAspect(), backgroundcolor=bgcolor, topspinevisible = false, bottomspinevisible = false, leftspinevisible = false, rightspinevisible = false)
    hidedecorations!(ax)

    contour!(ax, aa, bb, img', color = :black, levels = 3, linewidth = 5.0)

    for (a, b) in r_impacts
        lines!(ax, a, b, color = :black)
    end

    for line in line_p
        lines!(ax, first.(line), last.(line), color = :black)
    end

    Makie.save("rawfigs/toy-accretion-projected.svg", fig)
    fig
end


aa, bb, img = rendergeodesics(
    m, x, ThinDisc(Gradus.isco(m), last_r), 2e4,
    image_width = 1080,
    image_height = 720,
    αlims = (-30, 30),
    βlims = (-12, 15),
    pf = PointFunction((m, gp, t) -> gp.v[3]) ∘ ConstPointFunctions.filter_intersected(),
    verbose = true,
)

extrema(filter(!isnan, img))

begin
    fig = Figure(backgroundcolor=bgcolor)
    ax = Axis(fig[1,1], aspect = DataAspect(), backgroundcolor=bgcolor, topspinevisible = false, bottomspinevisible = false, leftspinevisible = false, rightspinevisible = false)
    hidedecorations!(ax)
    heatmap!(ax, aa, bb, img', colormap = :binary)
    save("rawfigs/toy-accretion-render.png", fig, px_per_point = 2)
    fig
end