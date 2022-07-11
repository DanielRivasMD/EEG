####################################################################################################

using Clustering
using StatsPlots
using Distances

#  functions
utilDir = "src/Utilities/"
include(string(utilDir,  "stateStats.jl"));

outdir = "./" #  output

#  collect stats
csvList = readdir("csv/")
colStats = summarizeStats(string.("csv/", csvList), 19)

#  purge brain death records
colStats = colStats[[1:50; 54:99], :]

#  columns
pwcolAr = pairwise(Euclidean(), colStats, dims = 1)                # calculate pairwise by Euclidean distance
hcl1 = hclust(pwcolAr, linkage = :average, branchorder = :optimal) # hierarchical clustering

#  rows
pwrowAr = pairwise(Euclidean(), colStats, dims = 2)                # calculate pairwise by Euclidean distance
hcl2 = hclust(pwrowAr, linkage = :average, branchorder = :optimal) # hierarchical clustering

#  patch color bar
patchColStats = [colStats 1:size(colStats, 1)]
patchColStats[findall(x -> x <= 20, patchColStats[:, end]), end] .= 0.1
patchColStats[findall(x -> x > 20 && x <= 50, patchColStats[:, end]), end] .= 0.5
patchColStats[findall(x -> x > 50, patchColStats[:, end]), end] .= 0.9

h = heatmap(patchColStats,)
savefig(h, "groundStateUnordered.svg")

#  plot heatmap + dendrograms
ly = grid(2, 2, heights = [0.2, 0.8, 0.2, 0.8], widths = [0.8, 0.2, 0.8, 0.2])
p = plot(
  plot(hcl2, ylims = (0, 1), xticks = false),
  plot(tikcs = nothing, border = :none),
  heatmap(patchColStats[hcl1.order, [hcl2.order; size(patchColStats, 2)]], colorbar = false,),
  plot(hcl1, xlims = (0, 1), yticks = false, xrotation = 90, orientation = :horizontal),
  layout = ly,
)

savefig(p, "groundStateHClust.svg")

####################################################################################################
