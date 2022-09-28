####################################################################################################

function new_cycle_theme()
  # https://nanx.me/ggsci/reference/pal_locuszoom.html
  my_colors = ["#D43F3AFF", "#EEA236FF", "#5CB85CFF", "#46B8DAFF", "#357EBDFF", "#9632B8FF", "#B8B8B8FF"]
  cycle = Cycle([:color, :linestyle, :marker], covary = true) # alltogether
  my_markers = [:circle, :rect, :utriangle, :dtriangle, :diamond, :pentagon, :cross, :xcross]
  my_linestyle = [nothing, :dash, :dot, :dashdot, :dashdotdot]
  Theme(
    fontsize = 16,
    colormap = :linear_bmy_10_95_c78_n256,
    palette = (color = my_colors, marker = my_markers, linestyle = my_linestyle),
    Lines = (cycle = cycle,), Scatter = (cycle = cycle,),
    Axis = (xlabelsize = 20, xgridstyle = :dash, ygridstyle = :dash,
      xtickalign = 1, ytickalign = 1, yticksize = 10, xticksize = 10,
      xlabelpadding = -5, xlabel = "x", ylabel = "y"),
    Legend = (framecolor = (:black, 0.5), bgcolor = (:white, 0.5)),
    Colorbar = (ticksize = 16, tickalign = 1, spinewidth = 0.5),
  )
end

####################################################################################################

function scatters_and_lines()
  x = collect(0:10)
  xh = LinRange(4, 6, 25)
  yh = LinRange(70, 95, 25)
  h = randn(25, 25)
  fig = Figure(resolution = (600, 400))
  ax = CairoMakie.Axis(fig[1, 1], xlabel = L"x", ylabel = L"f(x,a)")
  for i in x
    lines!(ax, x, i .* x; label = "$(i)x")
    scatter!(ax, x, i .* x; markersize = 13, strokewidth = 0.25, label = "$(i)x")
  end
  hm = heatmap!(xh, yh, h)
  axislegend(L"f(x)"; merge = true, position = :lt, nbanks = 2, labelsize = 14)
  Colorbar(fig[1, 2], hm, label = "new default colormap")
  limits!(ax, -0.5, 10.5, -5, 105)
  colgap!(fig.layout, 5)
  fig
end

####################################################################################################
