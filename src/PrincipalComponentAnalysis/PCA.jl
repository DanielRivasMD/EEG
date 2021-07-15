# ################################################################################
#
# utilDir = "../utilitiesJL/"
# include(string(utilDir, "argParser.jl"))
#
# # parse shell arguments
# shArgs = shArgParser(ARGS)
#
# begin
#   file = shArgs["file"]
# end
#
# begin
#   ftrim = replace(file, r".+/" => "")
#   ftrim = replace(ftrim, ".jld2" => "")
# end
#
# ################################################################################

# load modules
using MultivariateStats
# using JLD2

# ################################################################################
#
# # toLoad = string("outDir/", file)
# # @load toLoad
#
# ################################################################################

electrodeID = convert.(String, keys(errDc))
sts = length(errDc[electrodeID[1][2])
binSize = length(errDc[electrodeID[1][2][1])

dimension = sts * length(kys)
states = 1:sts

pcaMt = zeros(binSize, dimension)

################################################################################

c = 0
for (k, v) in errDc
  for s in states
    global c += 1
    pcaMt[:, c] = v[2][s]
  end
end

################################################################################

M = fit(PCA, pcaMt', maxoutdim = 2)

################################################################################

using RCall

xr = [ M.proj repeat(electrodeID, inner = length(states)) repeat(states, outer = length(electrodeID)) ]



@rput xr
# @rput electrodeID
# @rput states

R"
source('utilitiesJL/PCA.R')
"



################################################################################

# using UnicodePlots
#
# points = [M.proj[t, :] for t in 1:(size(M.proj, 1))]
# scatterplot(M.proj[:, 1], M.proj[:, 2], xlim = (-1, 1), ylim = (-1, 1), width = 175, height = 40)

################################################################################

# using GLMakie, AbstractPlotting
#
# scene = Scene()
# points = [Point2f0(M.proj[t, 1], M.proj[t, 2]) for t in 1:(size(M.proj, 1))]
# scatter!(scene, points)
# lines!()

################################################################################
