################################################################################

using CairoMakie
using MakieLayout
using AbstractPlotting

################################################################################

outer_padding = 30
scene, layout = layoutscene(
  outer_padding,
  resolution = (1200, 700),
  backgroundcolor = RGBf0(0.98, 0.98, 0.98)
)

################################################################################

ax1 = layout[1, 1] = LAxis(scene, title = "Pre Treatment")

data1 = randn(50, 2) * [1 2.5; 2.5 1] .+ [10 10]

line1 = lines!(ax1, 5..15, x -> x, color = :red, linewidth = 2)
scat1 = scatter!(ax1, data1,
  color = (:red, 0.3), markersize = 15px, marker = '■')

################################################################################

ax2 = layout[1, 2] = LAxis(scene, title = "Post Treatment")

data2 = randn(50, 2) * [1 -2.5; -2.5 1] .+ [13 13]

line2 = lines!(ax2, 7..17, x -> -x + 26, color = :blue, linewidth = 2)
scat2 = scatter!(ax2, data2,
  color = (:blue, 0.3), markersize = 15px, marker = '▲')

################################################################################

linkaxes!(ax1, ax2)

hideydecorations!(ax2, grid = false)

ax1.xlabel = "Weight [kg]"
ax2.xlabel = "Weight [kg]"
ax1.ylabel = "Maximum Velocity [m/sec]"

################################################################################

leg = layout[1, end+1] = LLegend(scene,
  [line1, scat1, line2, scat2],
  ["f(x) = x", "Data", "f(x) = -x + 26", "Data"])

layout[2, 1:2] = leg

trim!(layout)

leg.tellheight = true

leg.orientation = :horizontal

################################################################################

hm_axes = layout[1:2, 3] = [LAxis(scene, title = t) for t in ["Cell Assembly Pre", "Cell Assembly Post"]]

heatmaps = [heatmap!(ax, i .+ rand(20, 20)) for (i, ax) in enumerate(hm_axes)]

hm_sublayout = GridLayout()
layout[1:2, 3] = hm_sublayout

hm_sublayout[:v] = hm_axes

hidedecorations!.(hm_axes)

################################################################################

for hm in heatmaps
    hm.colorrange = (1, 3)
end

cbar = hm_sublayout[:, 2] = LColorbar(scene, heatmaps[1], label = "Activity [spikes/sec]")

cbar.width = 30

cbar.height = Relative(2/3)

cbar.ticks = 1:0.5:3

################################################################################

supertitle = layout[0, :] = LText(scene, "Plotting with MakieLayout",
  textsize = 30, font = "Noto Sans Bold", color = (:black, 0.25))

################################################################################

label_a = layout[2, 1, TopLeft()] = LText(scene, "A", textsize = 35,
  font = "Noto Sans Bold", halign = :right)
label_b = layout[2, 3, TopLeft()] = LText(scene, "B", textsize = 35,
  font = "Noto Sans Bold", halign = :right)

  label_a.padding = (0, 6, 16, 0)
  label_b.padding = (0, 6, 16, 0)

colsize!(hm_sublayout, 1, Aspect(1, 1))

################################################################################

save("plot.svg", scene, pt_per_unit = 0.5)

################################################################################
