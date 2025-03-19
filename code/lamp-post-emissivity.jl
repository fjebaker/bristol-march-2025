include("common.jl")
import Random
bgcolor = RGBAf(1.0,1.0,1.0,0.0)

function trace_corona_trajectories(
    m::AbstractMetric,
    d::AbstractAccretionGeometry,
    model;
    callback = domain_upper_hemisphere(),
    sampler = EvenSampler(BothHemispheres(), GoldenSpiralGenerator()),
    n_samples = 174,
    kwargs...,
)
    xs, vs, _ = Gradus.sample_position_direction_velocity(m, model, sampler, n_samples)
    tracegeodesics(
        m,
        xs,
        vs,
        d,
        1000;
        callback = callback,
        kwargs...,
    )
end

m = KerrMetric(1.0, 0.98)
d = ThinDisc(0.0, Inf)
dim = 26

model1 = LampPostModel(h = 5.0, θ = 0.001)
traj1 = trace_corona_trajectories(m, d, model1)
model2 = LampPostModel(h = 10.0, θ = 0.001)
traj2 = trace_corona_trajectories(m, d, model2)
model3 = LampPostModel(h = 20.0, θ = 0.0001)
traj3 = trace_corona_trajectories(m, d, model3)

function is_intersected(sol) 
    return true
    intersected = (sol.prob.p.status[] == StatusCodes.IntersectedWithGeometry)
    if intersected
        return sol.u[end][2] < 21
    end
    false
end

m = KerrMetric(1.0, 0.998)
m2 = KerrMetric(1.0, 0.0)

heights = [5.0, 10.0, 20.0]
n_samples = 5000

emprofs = map(heights) do h
    model = LampPostModel(h = h)
    emprof = emissivity_profile(m, d, model; n_samples = n_samples)
end

emprofs2 = map(heights) do h
    model = LampPostModel(h = h)
    emprof = emissivity_profile(m2, d, model; n_samples = n_samples)
end

begin
    _norm = 1e4
    scales = [13.0, 3.2, 1.0]
    fig = Figure(size = (700, 350), backgroundcolor = bgcolor)

    ax = Axis(
        fig[2, 1],
        yscale = log10,
        xscale = log10,
        xticks = [1.0, 2.0, 3.0, 5.0, 10.0, 20.0, 30.0, 50.0, 100.0],
        xlabel = "Radius on disc",
        ylabel = "Emissivity (arb.)",
        title = "Emissivity",
        backgroundcolor = bgcolor
    )
    ax2 = Axis(
        fig[2, 2],
        yscale = log10,
        xscale = log10,
        xticks = [1.0, 2.0, 3.0, 5.0, 10.0, 20.0, 30.0, 50.0, 100.0],
        yticks = [5.0, 10.0, 20.0, 50.0, 100.0],
        xlabel = "Radius on disc",
        ylabel = "Time corona-to-disc",
        title = "Light crossing time",
        backgroundcolor = bgcolor
    )

    vlines!(ax, [Gradus.inner_radius(m), Gradus.inner_radius(m2)], color = :black)
    vlines!(ax2, [Gradus.inner_radius(m), Gradus.inner_radius(m2)], color = :black)

    dat = []
    palette = _default_palette()
    for (A, ep) in zip(scales, emprofs2)
        lines!(
            ax,
            ep.radii,
            A .* ep.ε ./ _norm,
            linestyle = :dash,
            color = popfirst!(palette),
        )
    end
    palette = _default_palette()
    for (A, ep) in zip(scales, emprofs)
        push!(dat, lines!(ax, ep.radii, A .* ep.ε ./ _norm, color = popfirst!(palette)))
    end

    palette = _default_palette()
    for (A, ep) in zip(scales, emprofs2)
        lines!(ax2, ep.radii, ep.t, linestyle = :dash, color = popfirst!(palette))
    end
    palette = _default_palette()
    for (A, ep) in zip(scales, emprofs)
        lines!(ax2, ep.radii, ep.t, color = popfirst!(palette))
    end

    Legend(
        fig[1, 1:2],
        dat,
        ["h = $(trunc(Int,i))" for i in heights],
        orientation = :horizontal,
        framewidth = 0,
        backgroundcolor = RGBAf(0.0, 0.0, 0.0, 0.0),
    )

    xlims!(ax, 1.0, 100.0)
    ylims!(ax, 1e-7 / _norm, nothing)
    xlims!(ax2, 1.0, 100.0)
    ylims!(ax2, 5, 200.0)

    save("rawfigs/lamp-post-emissivity-travel-time.svg", fig)
    fig
end

begin
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

    for r in range(Gradus.isco(m), 24.0, step = 3)
        plotring(ax, r; height = 0.0,  horizon_r = R, color = :black, dim = dim)
    end

    _palette = _default_palette()
    for traj in (traj1, traj2, traj3)
        c = popfirst!(_palette)
        for sol in filter(is_intersected, traj.u)
            plot_sol(
                ax,
                sol;
                color = c,
                horizon_r = R,
                dim = dim,
                show_intersect = false,
            ) 
        end
    end
    
    coronae = (model1, model2, model3)
    _palette = _default_palette()
    cs = map(coronae) do i
        scatter!(ax, [0], [0], [i.h], markersize = 15, color = popfirst!(_palette))
    end
    
    Legend(fig[1, 2], [cs...], ["h=5", "h=10", "h=20"], backgroundcolor = bgcolor)
    save("rawfigs/lamp-post-traces.svg", fig)
    fig
end