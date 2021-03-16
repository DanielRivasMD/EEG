################################################################################

using Clustering
using StatsPlots
using Distances

#  functions
utilDir = "Utilities/"
include( string(utilDir,  "stateStats.jl") );

outdir = "./" #  output

#  collect stats
csvList = readdir("csv/")
colStats = summarizeStats( string.("csv/", csvList) )

#  purge brain death records
colStats = colStats[[1:50; 54:99], :]

#  columns
pwcolAr = pairwise(Euclidean(), colStats, dims = 1)                # calculate pairwise by Euclidean distance
hcl1 = hclust(pwcolAr, linkage = :average, branchorder = :optimal) # hierarchical clustering

#  rows
pwrowAr = pairwise(Euclidean(), colStats, dims = 2)                # calculate pairwise by Euclidean distance
hcl2 = hclust(pwrowAr, linkage = :average, branchorder = :optimal) # hierarchical clustering

#  plot heatmap + dendrograms
ly = grid(2, 2, heights = [0.2, 0.8, 0.2, 0.8], widths = [0.8, 0.2, 0.8, 0.2])
p = plot(
  plot(hcl1, xticks = false),
  plot(tikcs = nothing, border = :none),
  heatmap(colStats[hcl1.order, :], colorbar = false, ),
  plot(hcl2, yticks = false, xrotation = 90, orientation = :horizontal),
  layout = ly,
)

savefig(p, "groundStateHClust.svg")

################################################################################
