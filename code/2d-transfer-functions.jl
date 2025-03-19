include("common.jl")

m = KerrMetric(M = 1.0, a = 0.998)
x = SVector(0.0, 10_000.0, deg2rad(80), 0.0)
x2 = SVector(0.0, 10_000.0, deg2rad(40), 0.0)
d = ThinDisc(0.0, 30.0)

function flux_profile(m, x, d, model, radii, gbins, tbins; n_samples = 10_000)
    itb = @time Gradus.interpolated_transfer_branches(m, x, d, radii; verbose = true)
    prof = @time emissivity_profile(m, d, model; n_samples = n_samples)
    flux = Gradus.integrate_lagtransfer(
        prof,
        itb,
        gbins,
        tbins;
        t0 = Gradus.continuum_time(m, x, model),
        n_radii = 8000,
        rmin = minimum(radii),
        rmax = maximum(radii),
        g_grid_upscale = 10,
    )
    replace!(flux, 0.0 => NaN)
end

d = ThinDisc(0.0, Inf)
radii = Gradus.Grids._inverse_grid(Gradus.isco(m), 300.0, 400)

gbins = collect(range(0.0, 1.6, 500))
tbins = collect(range(0, 160.0, 800))
model = LampPostModel(h = 5.0)

ff1 = flux_profile(m, x, ThinDisc(0.0, Inf), model, radii, gbins, tbins)
ff2 = flux_profile(m, x2, ThinDisc(0.0, Inf), model, radii, gbins, tbins)

begin
    fig = Figure(size = (400, 350), backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0))
    ax = Axis(
        fig[1, 1],
        ylabel = "E / E₀",
        xlabel = "Time after continuum (GM / c³)",
        yticks = [0.2, 0.6, 1.0, 1.4],
        xticks = [0, 25, 50, 75, 100],
        title = "2D Transfer Function",
        backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0),
    )

    xlims!(ax, nothing, 100)
    heatmap!(ax, tbins, gbins, log10.(ff1)', colormap = :greys)
    heatmap!(ax, tbins, gbins, log10.(ff2)', colormap = :batlow)

    Legend(
        fig[1, 1],
        tellheight = false,
        tellwidth = false,
        halign = 0.9,
        valign = 0.1,
        backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0),
        [PolyElement(color = :grey), PolyElement(color = "#DF964F")],
        ["θ = 80°", "θ = 40°"],
    )

    save("rawfigs/2d-transfer-functions.png", fig, px_per_point = 2)
    fig
end

function calculate_2d_transfer_function(m, x, model, itb, prof, radii)
    bins = collect(range(0.0, 1.5, 300))
    tbins = collect(range(0, 2000.0, 3000))

    t0 = continuum_time(m, x, model)
    @show t0

    flux = @time Gradus.integrate_lagtransfer(
        prof,
        itb,
        bins,
        tbins;
        t0 = t0,
        n_radii = 8000,
        rmin = minimum(radii),
        rmax = maximum(radii),
        h = 1e-8,
        g_grid_upscale = 10,
    )

    flux[flux.==0] .= NaN
    bins, tbins, flux
end

function calculate_lag_transfer(m, x, d, model, radii, itb)
    prof = @time emissivity_profile(m, d, model; n_samples = 100_000)
    E, t, f = @time calculate_2d_transfer_function(m, x, model, itb, prof, radii)
    ψ = Gradus.sum_impulse_response(f)
    freq, τ = @time lag_frequency(t, f)
    freq, τ, ψ, t
end

# thin disc
d = ThinDisc(0.0, Inf)

itb1 = Gradus.interpolated_transfer_branches(m, x, d, radii; verbose = true)
itb2 = Gradus.interpolated_transfer_branches(m, x2, d, radii; verbose = true)

freq1, τ1, impulse1, time1 = calculate_lag_transfer(m, x, d, model, radii, itb1)
freq2, τ2, impulse2, time2 = calculate_lag_transfer(m, x2, d, model, radii, itb2)

begin
    fig = Figure(size = (380, 220), backgroundcolor = bgcolor)
    ax = Axis(fig[1,1], yscale = log10, xlabel = "Time after continuum", ylabel = "Impulse Flux", backgroundcolor = bgcolor,
        xticks = [0, 25, 50, 75, 100],
    )
    min_y = 1e-5
    ylims!(ax, min_y, nothing)
    xlims!(ax, 0.0, 100)

    lines!(ax, time1, replace(impulse1, 0.0 => min_y))
    lines!(ax, time2, replace(impulse2, 0.0 => min_y))

    save("rawfigs/2d-impulse-response.svg", fig)
    fig
end