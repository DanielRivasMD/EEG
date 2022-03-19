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
@load "outDir/0001LB_errDcChFFTA3.jld2"
loadDc["0001LB"] = deepcopy(errDc)
@load "outDir/0002AC_errDcChFFTA3.jld2"
loadDc["0002AC"] = deepcopy(errDc)
@load "outDir/0003DC_errDcChFFTA3.jld2"
loadDc["0003DC"] = deepcopy(errDc)
@load "outDir/0004AD_errDcChFFTA3.jld2"
loadDc["0004AD"] = deepcopy(errDc)
@load "outDir/0005RD_errDcChFFTA3.jld2"
loadDc["0005RD"] = deepcopy(errDc)
@load "outDir/0006AH_errDcChFFTA3.jld2"
loadDc["0006AH"] = deepcopy(errDc)
@load "outDir/0007DH_errDcChFFTA3.jld2"
loadDc["0007DH"] = deepcopy(errDc)
@load "outDir/0008AH_errDcChFFTA3.jld2"
loadDc["0008AH"] = deepcopy(errDc)
@load "outDir/0009EH_errDcChFFTA3.jld2"
loadDc["0009EH"] = deepcopy(errDc)
@load "outDir/0010LL_errDcChFFTA3.jld2"
loadDc["0010LL"] = deepcopy(errDc)
@load "outDir/0011DM_errDcChFFTA3.jld2"
loadDc["0011DM"] = deepcopy(errDc)
@load "outDir/0012MN_errDcChFFTA3.jld2"
loadDc["0012MN"] = deepcopy(errDc)
@load "outDir/0013JP_errDcChFFTA3.jld2"
loadDc["0013JP"] = deepcopy(errDc)
@load "outDir/0014SP_errDcChFFTA3.jld2"
loadDc["0014SP"] = deepcopy(errDc)
@load "outDir/0015LR_errDcChFFTA3.jld2"
loadDc["0015LR"] = deepcopy(errDc)
@load "outDir/0016GR_errDcChFFTA3.jld2"
loadDc["0016GR"] = deepcopy(errDc)
@load "outDir/0017DR_errDcChFFTA3.jld2"
loadDc["0017DR"] = deepcopy(errDc)
@load "outDir/0018KR_errDcChFFTA3.jld2"
loadDc["0018KR"] = deepcopy(errDc)
@load "outDir/0019GS_errDcChFFTA3.jld2"
loadDc["0019GS"] = deepcopy(errDc)
@load "outDir/0020WT_errDcChFFTA3.jld2"
loadDc["0020WT"] = deepcopy(errDc)

ftrim = convert.(String, keys(loadDc)) |> sort

################################################################################

# PCA
R"
pacman::p_load(ggplot2)
source(file = 'utilitiesJL/multiplot.R')
pdf('pcaHealthy.pdf', width = 48, height = 36)
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
