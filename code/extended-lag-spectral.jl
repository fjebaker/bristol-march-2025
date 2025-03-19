using Revise
using Gradus
using Plots

function ring_transfer_function(ra, rs, ts)
    img_total = zeros(Float64, (length(ts), length(rs)))

    for bs in ra.branches 
        for branch in bs
            first_i = findfirst(!isnan, branch.r)
            last_i = findlast(!isnan, branch.r)
            (isnothing(first_i) || isnothing(last_i)) && continue

            _t_interp = Gradus._make_interpolation(branch.r, branch.t)
            _e_interp = Gradus._make_interpolation(branch.r, branch.ε)

            for (ri, r) in enumerate(rs)
                if (r >= branch.r[first_i]) && (r <= branch.r[last_i])
                    t = _t_interp(r)
                    ti = searchsortedfirst(ts, t)
                    if ti <= lastindex(ts)
                        img_total[ti, ri] += _e_interp(r)
                    end
                end
            end
        end
    end

    replace!(img_total, 0 => NaN)
    img_total
end

m = KerrMetric(1.0, 0.9982)
d = ThinDisc(0.0, Inf)

model = RingCorona(Gradus.SourceVelocities.co_rotating, 2.0, 2.0)

_, setup = Gradus.EmissivityProfileSetup(
    Float64,
    PowerLawSpectrum(2.0);
    n_samples = 1000,
)

βs = Gradus.DEFAULT_β_ANGLES(;n_regular = 200, n_refined = 2)

slices = Gradus.corona_slices(setup, m, d, model, βs; verbose = true)

ra = @time Gradus.make_approximation(m, slices, PowerLawSpectrum(2.0), βs = collect(range(1e-7, π - 1e-7, 1000)))

rs = collect(Gradus.Grids._geometric_grid(Gradus.isco(m), 1000, 200))
# put the branches in some kind of canonical order
for bs in ra.branches
    sort!(bs; by=branch -> minimum(filter(!isnan, branch.t)))
end

em = @time emissivity_at.((ra,), rs)

r_grid = collect(10 .^ range(log10(max(1, Gradus.isco(m))), 2.5, 1000))
t_grid = range(2, 300.0, 1000) |> collect
tdep = @time ring_transfer_function(ra, r_grid, t_grid)


heatmap(t_grid, r_grid, log10.(tdep'), yscale = :log10, title = "x = $(model.r)", clims = (-3, 3))


prof = Gradus.TimeDependentEmissivityProfile(r_grid, t_grid, tdep)

interp = Gradus.emissivity_interp(prof, 10.0)

using BenchmarkTools

# @btime ring_transfer_function($ra, $r_grid, $t_grid)
# 121 ms

x = SVector(0.0, 1e4, deg2rad(45), 0.0)

d = ThinDisc(0.0, Inf)
radii = Gradus.Grids._inverse_grid(Gradus.isco(m), 1000.0, 100) |> collect
itb = @time Gradus.interpolated_transfer_branches(m, x, d, radii; verbose = true)

gbins = collect(range(0.0, 1.4, 500))
tbins = collect(range(0, 150.0, 500))

flux = @time Gradus.integrate_lagtransfer(
    prof, 
    itb, 
    gbins, 
    tbins; 
    t0 = 1e4,
    n_radii = 6000,
)

replace!(flux, 0.0 => NaN)

heatmap(tbins, gbins, log10.(flux))