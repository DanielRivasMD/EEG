################################################################################

# load modules
using CairoMakie
using Makie.FileIO
using Images

################################################################################

# declare canvas
φ = Figure(backgroundcolor = RGB(0.98, 0.98, 0.98), resolution = (1000, 700))

# declare general layout
ga = φ[1, 1] = GridLayout()
gb = φ[2, 1] = GridLayout()
g_cd = φ[1:2, 2] = GridLayout()
gc = g_cd[1, 1] = GridLayout()
gd = g_cd[2, 1] = GridLayout()

################################################################################

# create random data
data = randn(3, 100, 2) .+ [1, 3, 5]

# declare panel A layout
axtop = MakieLayout.Axis(ga[1, 1])
axmain = MakieLayout.Axis(ga[2, 1], xlabel = "before", ylabel = "after")
axright = MakieLayout.Axis(ga[2, 2])

# panel title
Label(ga[1, 1:2, Top()], "Stimulus ratings", valign = :bottom, padding = (0, 0, 5, 0))

# link axes
linkyaxes!(axmain, axright)
linkxaxes!(axmain, axtop)

# declare labels
labels = ["treatment", "placebo", "control"]

# render plot
for (label, col) ∈ zip(labels, eachslice(data, dims = 1))
  scatter!(axmain, col, label = label)
  density!(axtop, col[:, 1])
  density!(axright, col[:, 2], direction = :y)
end

# axes limitis
ylims!(axtop, low = 0)
xlims!(axright, low = 0)

# explitic ticks
axmain.xticks = 0:3:9
axtop.xticks = 0:3:9

# figure legend
leg = Legend(ga[1, 2], axmain)
leg.tellheight = true

# hide decorations
hidedecorations!(axtop, grid = false)
hidedecorations!(axright, grid = false)

# spacing
colgap!(ga, 10)
rowgap!(ga, 10)

################################################################################

# declare panel B ranges
xs = LinRange(0.5, 6, 50)
ys = LinRange(0.5, 6, 50)

# create random data
data1 = [sin(x ^ 1.5) * cos(y ^ 0.5) for x ∈ xs, y ∈ ys] .+ 0.1 .* randn.()
data2 = [sin(x ^ 0.8) * cos(y ^ 1.5) for x ∈ xs, y ∈ ys] .+ 0.1 .* randn.()

# declare upper layout
ax1, hm = contourf(gb[1, 1], xs, ys, data1, levels = 6)

# title
ax1.title = "Histological analysis"

# render heatmap
contour!(ax1, xs, ys, data1, levels = 5, color = :black)

# hide decorations
hidexdecorations!(ax1)

# declare lower layout
ax2, hm2 = contourf(gb[2, 1], xs, ys, data2, levels = 6)

# render heatmap
contour!(ax2, xs, ys, data2, levels = 5, color = :black)

# color annotations
cb = Colorbar(gb[1:2, 2], hm, label = "cell group")
low, high = extrema(data1)
edges = range(low, high, length = 7)
centers = (edges[1:6] .+ edges[2:7]) .* 0.5
cb.ticks = (centers, string.(1:6))

# annotation alignment
cb.alignmode = Mixed(right = 0)

# spacing
colgap!(gb, 10)
rowgap!(gb, 10)

################################################################################

# load data
brain = load(assetpath("brain.stl"))

# panel C layout & title
ax3d = Axis3(gc[1, 1], title = "Brain activation")

# render mesh
m = mesh!(
  ax3d,
  brain,
  color = [tri[1][2] for tri ∈ brain for i ∈ 1:3],
  colormap = Reverse(:magma),
)

# annotation
Colorbar(gc[1, 2], m, label = "BOLD level")

################################################################################

# panel D layout
axs = [MakieLayout.Axis(gd[row, col]) for row ∈ 1:3, col ∈ 1:2]

# panel title
Label(gd[1, :, Top()], "EEG traces", valign = :bottom, padding = (0, 0, 5, 0))

# hide decorations
hidedecorations!.(axs, grid = false, label = false)

# render line plots
for row ∈ 1:3, col ∈ 1:2
  xrange = col == 1 ? (0:0.1:6pi) : (0:0.1:10pi)
  eeg = [sum(sin(pi * rand() + k * x) / k for k ∈ 1:10) for x ∈ xrange] .+ 0.1 .* randn.()
  lines!(axs[row, col], eeg, color = (:black, 0.5))
end

# axes labels
axs[3, 1].xlabel = "Day 1"
axs[3, 2].xlabel = "Day 2"

# spacing
rowgap!(gd, 10)
colgap!(gd, 10)

# axes labels
for (i, label) ∈ enumerate(["sleep", "awake", "test"])
  Box(gd[i, 3], color = :gray90)
  Label(gd[i, 3], label, rotation = pi/2, tellheight = false)
end

# spacing
colgap!(gd, 2, 0)

# plot size
n_day_1 = length(0:0.1:6pi)
n_day_2 = length(0:0.1:10pi)

# layout size
colsize!(gd, 1, Auto(n_day_1))
colsize!(gd, 2, Auto(n_day_2))

################################################################################

# overall layout
for (label, layout) ∈ zip(["A", "B", "C", "D"], [ga, gb, gc, gd])
  Label(layout[1, 1, TopLeft()], label, textsize = 26, padding = (0, 5, 5, 0), halign = :right)
end

# layout size
colsize!(φ.layout, 1, Auto(0.5))
rowsize!(g_cd, 1, Auto(1.5))

# save plot
save("data/layoutTutorial.svg", φ)

################################################################################
