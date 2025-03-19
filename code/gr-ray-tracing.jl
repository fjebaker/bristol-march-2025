using Gradus
using CoordinateTransformations, Rotations, LinearAlgebra

function bounding_sphere!(ax; R = 1.005, kwargs...)
    phi_circ = 0.0:0.001:2π
    x = @. R * cos(phi_circ)
    y = @. R * sin(phi_circ)
    z = zeros(length(y))

    t = LinearMap(RotZ(ax.azimuth.val - π)) ∘ LinearMap(RotY(ax.elevation.val - π / 2))
    points = reduce(hcat, [x, y, z])'
    translated = reduce(hcat, map(t, eachcol(points)))

    lines!(
        ax,
        translated[1, :],
        translated[2, :],
        translated[3, :];
        linewidth = 1.9,
        kwargs...,
    )
    #translated
end


function plot_solutions!(ax, sols)
    for sol in sols.u
        path = Gradus._extract_path(sol, 1024, t_span = 50.0)  
        x = path[1]
        y = path[2]
        
        lines!(ax, x, y)
    end
end

function plot_3d_solutions!(ax, sols; kwargs...)
    for sol in sols.u
        path = Gradus._extract_path(sol, 1024, t_span = 50.0)  
        x = path[1]
        y = path[2]
        z = path[3]
        
        lines!(ax, x, y, z; kwargs...)
    end
end

function calculate_geodesics(m; β = 0.0, N = 20)
    # observer position
    x = SVector(0.0, 10000.0, π/2, 0.0)
    # set up impact parameter space
    α = collect(range(-10.0, 10.0, N))
    β = fill(β, size(α))

    # build initial velocity and position vectors
    vs = map_impact_parameters(m, x, α, β)
    xs = fill(x, size(vs))

    tracegeodesics(m, xs, vs, 20000.0, chart = Gradus.chart_for_metric(m, closest_approach = 1.10))
end

flat = Gradus.SphericalMetric()
schwarzschild = KerrMetric(M=1.0, a=0.0)
kerr = KerrMetric(M=1.0, a=-1.0)


begin
    bgcolor = RGBAf(1.0, 1.0, 1.0, 0.0)
    fig = Figure(size = (500,500), backgroundcolor = bgcolor)
    dim = 17

    ga = fig[1,1] = GridLayout()

    for (title, pos, m) in zip(
        ("Flat", "Schwarzschild", "Kerr"),
        ((1, 1), (1, 2), (2, 2)),
        (flat, schwarzschild, kerr)
    )
        ax = Axis(ga[pos[1], pos[2]], aspect = DataAspect(), title = title, backgroundcolor = bgcolor, yaxisposition = pos[2] == 2 ? :right : :left)
        
        sols = calculate_geodesics(m)
        plot_solutions!(ax, sols)

        if pos == (1, 2)
            hidexdecorations!(ax, grid=false)
        end

        Makie.xlims!(ax, -dim,dim)
        Makie.ylims!(ax, -dim,dim)

        if title != "Flat"
            R = Gradus.inner_radius(m)
            ϕ = collect(range(0.0, 2π, 100))
            r = fill(R, size(ϕ))
            x = @. r * cos(ϕ)
            y = @. r * sin(ϕ)
            lines!(ax, x, y, color = :black, linewidth = 3.0)
        end
    end

    dim = 16
    ax3d = Axis3(ga[2,1], azimuth = deg2rad(-50), elevation = deg2rad(5), limits = ((-dim, dim), (-dim, dim), (-dim, dim)), aspect = (1, 1, 1), xspinesvisible = false, yspinesvisible = false, zspinesvisible = false)
    hidedecorations!(ax3d)


    bounding_sphere!(ax3d, R = Gradus.inner_radius(schwarzschild), color = :black)
    for b in range(-10.0, 10.0, 6)
        geods = calculate_geodesics(schwarzschild; β = b, N = 10)
        plot_3d_solutions!(ax3d, geods, linewidth = 1.0)
    end

    colgap!(ga, 0)
    rowgap!(ga, 0)

    save("rawfigs/gr-ray-tracing.svg", fig)
    fig
end
