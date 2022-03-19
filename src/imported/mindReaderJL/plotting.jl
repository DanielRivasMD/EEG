################################################################################

using CairoMakie
using MakieLayout

################################################################################

# plotting
scene, layout = layoutscene(resolution = (1200, 900))

ax1 = layout[1, 1] = LAxis(scene, title = "Raw signal")
l1 = lines!(ax1, edfDf[1:100, 1], color = :red, linewidth = 3)
hidedecorations!(ax1)

ax2 = layout[1, 2] = LAxis(scene, title = "Montage")
heatmap!(ax2, rand(50, 50), show_axis = false)
hidedecorations!(ax2)

ax3 = layout[1, 3] = LAxis(scene, title = "Image")
image!(ax3, img)
hidedecorations!(ax3)

save("plot.svg", scene, pt_per_unit = 0.5)

################################################################################
