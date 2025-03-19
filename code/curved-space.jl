using Makie, CairoMakie

dim = 9

x_grid = range(-dim, dim, step=2)
y_grid = range(-dim, dim, step=2)

function gaussian_deform(x, y; σ = 1.5)
    θ = atan(y, x)
    r = sqrt(x^2 + y^2)
    new_r = r * (1 - sqrt(exp(-r / σ)))
    cos(θ) * new_r, sin(θ) * new_r
end

function plot_grid!(ax, grid)
    for i in 1:size(grid, 1)
        scatter!(ax, first.(grid[i, :]), last.(grid[i, :]), color = :black, markersize = 7)
        lines!(ax, first.(grid[i, :]), last.(grid[i, :]) .* 1.1, color = :black)
    end
    for j in 1:size(grid, 2)
        lines!(ax, first.(grid[:, j]) .* 1.1, last.(grid[:, j]), color = :black)
    end
end

function new_axis(fig; kwargs...)
    ax = Axis(fig; aspect=DataAspect(), topspinevisible = false, leftspinevisible = false, rightspinevisible = false, bottomspinevisible = false, kwargs...)
    hidedecorations!(ax)
    ax
end

grid = [(x, y) for x in x_grid, y in y_grid]
def_grid = [gaussian_deform(x, y) for x in x_grid, y in y_grid]

begin
    fig = Figure(;size = (500, 300))
    ax1 = new_axis(fig[1,1], title = "Flat")
    plot_grid!(ax1, grid)

    ax2 = new_axis(fig[1,2], title = "Curved")
    plot_grid!(ax2, def_grid)

    save("rawfigs/curved-space.svg", fig)
    fig
end

function embedding(x, y)
    r = sqrt(x^2 + y^2)

    -0.09/(r)
end

begin
    import Plots
    xs = LinRange(-dim, dim, 30)
    ys = LinRange(-dim, dim, 30)
    zs = [embedding(x, y) for x in xs, y in ys]

    hide_attr = (;grid=false, backgroundcolor = RGBAf(0.0,0.0,0.0,0.0), showaxis=false)
    Plots.wireframe(xs, ys, zs; camera = (20, 20), zlims = (-0.3, 0.1), size = (500, 500), hide_attr...)
    Plots.savefig("rawfigs/embedding.svg")
end