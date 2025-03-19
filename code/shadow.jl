using Gradus, Makie, CairoMakie

_default_palette() = Iterators.Stateful(Iterators.Cycle(Makie.wong_colors()))

x = SVector(0.0, 10000.0, π / 2, 0.0)

α1, β1, img1 = rendergeodesics(
    KerrMetric(1.0, 0.0),
    x,
    # max integration time
    20_000.0,
    image_width = 1000,
    image_height = 1000,
    αlims = (-6, 6),
    βlims = (-6, 6),
    verbose = true,
    ensemble = Gradus.EnsembleEndpointThreads(),
)

begin
    bgcolor = RGBAf(1.0,1.0,1.0,0.0)
    fig = Figure(size = (800, 800), backgroundcolor = bgcolor)
    ax = Axis(fig[1,1], aspect = DataAspect(), topspinevisible = false, leftspinevisible = false, rightspinevisible = false, bottomspinevisible = false, backgroundcolor = bgcolor)
    hidedecorations!(ax)
    heatmap!(ax, α1, β1, img1', colormap = :batlow)

    save("rawfigs/schwarzschild-shadow.png", fig, px_per_point=2)
    fig
end

α2, β2, img2 = rendergeodesics(
    KerrMetric(1.0, 0.998),
    x,
    # max integration time
    20_000.0,
    image_width = 1000,
    image_height = 1000,
    αlims = (-3, 8),
    βlims = (-6, 6),
    verbose = true,
    ensemble = Gradus.EnsembleEndpointThreads(),
)

begin
    fig = Figure(size = (350, 300), backgroundcolor = RGBAf(1.0,1.0,1.0,0.0))

    ga = fig[1,1] = GridLayout()

    ax1 = Axis(ga[1,1], backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0), aspect = DataAspect(), ylabel = "β", xlabel = "α")

    pal = _default_palette()
    c1 = popfirst!(pal)
    _ = popfirst!(pal)
    _ = popfirst!(pal)
    c2 = popfirst!(pal)

    R = Gradus.inner_radius(KerrMetric(1.0, 0.0))
    ϕ = collect(range(0.0, 2π, 100))
    r = fill(R, size(ϕ))
    x = @. r * cos(ϕ)
    y = @. r * sin(ϕ)
    lines!(ax1, x, y, color = c1, linewidth = 1.0, linestyle = :dash)

    R = Gradus.inner_radius(KerrMetric(1.0, 0.998))
    r = fill(R, size(ϕ))
    x = @. r * cos(ϕ)
    y = @. r * sin(ϕ)
    lines!(ax1, x, y, color = c2, linewidth = 1.0, linestyle = :dash)

    contour!(ax1, α1, β1, img1', color = c1, levels = 10)
    contour!(ax1, α2, β2, img2', color = c2, levels = 10)


    colgap!(ga, 0)

    save("rawfigs/shadow.svg", fig)
    fig
end
