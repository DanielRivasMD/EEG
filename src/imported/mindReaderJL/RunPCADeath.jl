################################################################################

# load packages
using JLD2
using RCall
using MultivariateStats

# ################################################################################
#
# # declare relative paths
# utilDir = "../utilitiesJL/"
# mindDir = "../mindReaderJL"
# eegDir = "../../EEG/Data/patientEEG/"
#
# ################################################################################
#
# # read files
# fls = cd(readdir, eegDir)
#
# # select healthy
# lsedf = fls[match.(r"\S+edf", fls) .|> !isnothing][1:20]
# ftrim = replace.(lsedf, ".edf" => "")
#
# ################################################################################

# load manually
loadDc = Dict()
@load "outDir/0051ED_errDcChFFTA3.jld2"
loadDc["0051ED"] = deepcopy(errDc)
@load "outDir/0052MR_errDcChFFTA3.jld2"
loadDc["0052MR"] = deepcopy(errDc)
@load "outDir/0053MT_errDcChFFTA3.jld2"
loadDc["0053MT"] = deepcopy(errDc)

ftrim = convert.(String, keys(loadDc)) |> sort

################################################################################

# PCA
R"
pacman::p_load(ggplot2)
source(file = 'utilitiesJL/multiplot.R')
pdf('pcaDeath.pdf', width = 48, height = 9)
gls <- list()
"

pcaDc = Dict()
for ko in ftrim
  vo = loadDc[ko]

  # capture variables
  electrodeID = convert.(String, keys(vo))
  sts = length(vo[electrodeID[1]][2])
  binSize = length(vo[electrodeID[1]][2][1])

  dimension = sts * length(electrodeID)
  states = 1:sts

  ################################################################################

  # construct matrix
  pcaMt = zeros(binSize, dimension)
  c = 0
  for (ki, vi) in vo
    for s in states
      c += 1
      pcaMt[:, c] = vi[2][s]
    end
  end

  ################################################################################

  # calculate PCA
  pcaDc[ko] = fit(PCA, pcaMt', maxoutdim = 2)

  ################################################################################

  # construct plot
  xr = [ pcaDc[ko].proj repeat(electrodeID, inner = length(states)) repeat(states, outer = length(electrodeID)) ]
  @rput xr
  @rput ko

  R"
  source('utilitiesJL/PCA.R')
  "

end

################################################################################

# plot multiplot
R"
multiplot(plotlist = gls, cols = 5)
dev.off()
"

################################################################################
