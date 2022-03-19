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
# lsedf = fls[match.(r"\S+edf", fls) .|> !isnothing][21:50]
# ftrim = replace.(lsedf, ".edf" => "")
#
# # # manually exclude
# # filter!(e -> e ∉ ["0032AM","0037SC", "0041DV"], ftrim)
#
# ################################################################################

# load manually
loadDc = Dict()
@load "outDir/0021MA_errDcChFFTA3.jld2"
loadDc["0021MA"] = deepcopy(errDc)
@load "outDir/0022MD_errDcChFFTA3.jld2"
loadDc["0022MD"] = deepcopy(errDc)
@load "outDir/0023BA_errDcChFFTA3.jld2"
loadDc["0023BA"] = deepcopy(errDc)
@load "outDir/0024EZ_errDcChFFTA3.jld2"
loadDc["0024EZ"] = deepcopy(errDc)
@load "outDir/0025MF_errDcChFFTA3.jld2"
loadDc["0025MF"] = deepcopy(errDc)
@load "outDir/0026TS2015_errDcChFFTA3.jld2"
loadDc["0026TS2015"] = deepcopy(errDc)
@load "outDir/0027TS2017_errDcChFFTA3.jld2"
loadDc["0027TS2017"] = deepcopy(errDc)
@load "outDir/0028TS2019_errDcChFFTA3.jld2"
loadDc["0028TS2019"] = deepcopy(errDc)
@load "outDir/0029AA_errDcChFFTA3.jld2"
loadDc["0029AA"] = deepcopy(errDc)
@load "outDir/0030GJ_errDcChFFTA3.jld2"
loadDc["0030GJ"] = deepcopy(errDc)
@load "outDir/0031GJ_errDcChFFTA3.jld2"
loadDc["0031GJ"] = deepcopy(errDc)
@load "outDir/0032AM_errDcChFFTA3.jld2"
loadDc["0032AM"] = deepcopy(errDc)
@load "outDir/0033GC_errDcChFFTA3.jld2"
loadDc["0033GC"] = deepcopy(errDc)
@load "outDir/0034MI2018_errDcChFFTA3.jld2"
loadDc["0034MI2018"] = deepcopy(errDc)
@load "outDir/0035MI2019_errDcChFFTA3.jld2"
loadDc["0035MI2019"] = deepcopy(errDc)
@load "outDir/0036LR_errDcChFFTA3.jld2"
loadDc["0036LR"] = deepcopy(errDc)
@load "outDir/0037SC_errDcChFFTA3.jld2"
loadDc["0037SC"] = deepcopy(errDc)
@load "outDir/0038AR_errDcChFFTA3.jld2"
loadDc["0038AR"] = deepcopy(errDc)
@load "outDir/0039LH_errDcChFFTA3.jld2"
loadDc["0039LH"] = deepcopy(errDc)
@load "outDir/0040AE_errDcChFFTA3.jld2"
loadDc["0040AE"] = deepcopy(errDc)
@load "outDir/0041DV_errDcChFFTA3.jld2"
loadDc["0041DV"] = deepcopy(errDc)
@load "outDir/0042EG_errDcChFFTA3.jld2"
loadDc["0042EG"] = deepcopy(errDc)
@load "outDir/0043AD_errDcChFFTA3.jld2"
loadDc["0043AD"] = deepcopy(errDc)
@load "outDir/0044JV_errDcChFFTA3.jld2"
loadDc["0044JV"] = deepcopy(errDc)
@load "outDir/0045KG_errDcChFFTA3.jld2"
loadDc["0045KG"] = deepcopy(errDc)
@load "outDir/0046MC_errDcChFFTA3.jld2"
loadDc["0046MC"] = deepcopy(errDc)
@load "outDir/0047PR_errDcChFFTA3.jld2"
loadDc["0047PR"] = deepcopy(errDc)
@load "outDir/0048JG_errDcChFFTA3.jld2"
loadDc["0048JG"] = deepcopy(errDc)
@load "outDir/0049LB_errDcChFFTA3.jld2"
loadDc["0049LB"] = deepcopy(errDc)
@load "outDir/0050DT_errDcChFFTA3.jld2"
loadDc["0050DT"] = deepcopy(errDc)

ftrim = convert.(String, keys(loadDc)) |> sort

################################################################################

# PCA
R"
pacman::p_load(ggplot2)
source(file = 'utilitiesJL/multiplot.R')
pdf('pcaGeneralized.pdf', width = 48, height = 54)
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
