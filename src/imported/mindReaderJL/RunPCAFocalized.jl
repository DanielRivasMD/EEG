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
# lsedf = fls[match.(r"\S+edf", fls) .|> !isnothing][51:95]
# ftrim = replace.(lsedf, ".edf" => "")
#
# ################################################################################

# load manually
loadDc = Dict()
@load "outDir/0061JZ_errDcChFFTA3.jld2"
loadDc["0061JZ"] = deepcopy(errDc);
@load "outDir/0062AC_errDcChFFTA3.jld2"
loadDc["0062AC"] = deepcopy(errDc);
@load "outDir/0063RR_errDcChFFTA3.jld2"
loadDc["0063RR"] = deepcopy(errDc);
@load "outDir/0064CR_errDcChFFTA3.jld2"
loadDc["0064CR"] = deepcopy(errDc);
@load "outDir/0065LC_errDcChFFTA3.jld2"
loadDc["0065LC"] = deepcopy(errDc);
@load "outDir/0066MM_errDcChFFTA3.jld2"
loadDc["0066MM"] = deepcopy(errDc);
@load "outDir/0067GM_errDcChFFTA3.jld2"
loadDc["0067GM"] = deepcopy(errDc);
@load "outDir/0068MR_errDcChFFTA3.jld2"
loadDc["0068MR"] = deepcopy(errDc);
@load "outDir/0069AG_errDcChFFTA3.jld2"
loadDc["0069AG"] = deepcopy(errDc);
@load "outDir/0070RP_errDcChFFTA3.jld2"
loadDc["0070RP"] = deepcopy(errDc);
@load "outDir/0071AC_errDcChFFTA3.jld2"
loadDc["0071AC"] = deepcopy(errDc);
@load "outDir/0072LJ_errDcChFFTA3.jld2"
loadDc["0072LJ"] = deepcopy(errDc);
@load "outDir/0073FM_errDcChFFTA3.jld2"
loadDc["0073FM"] = deepcopy(errDc);
@load "outDir/0074JR_errDcChFFTA3.jld2"
loadDc["0074JR"] = deepcopy(errDc);
@load "outDir/0075PC_errDcChFFTA3.jld2"
loadDc["0075PC"] = deepcopy(errDc);
@load "outDir/0076FV_errDcChFFTA3.jld2"
loadDc["0076FV"] = deepcopy(errDc);
@load "outDir/0077MC_errDcChFFTA3.jld2"
loadDc["0077MC"] = deepcopy(errDc);
@load "outDir/0078BR_errDcChFFTA3.jld2"
loadDc["0078BR"] = deepcopy(errDc);
@load "outDir/0079GM_errDcChFFTA3.jld2"
loadDc["0079GM"] = deepcopy(errDc);
@load "outDir/0080JC_errDcChFFTA3.jld2"
loadDc["0080JC"] = deepcopy(errDc);
@load "outDir/0081MB_errDcChFFTA3.jld2"
loadDc["0081MB"] = deepcopy(errDc);
@load "outDir/0082KC_errDcChFFTA3.jld2"
loadDc["0082KC"] = deepcopy(errDc);
@load "outDir/0083EA_errDcChFFTA3.jld2"
loadDc["0083EA"] = deepcopy(errDc);
@load "outDir/0084CR_errDcChFFTA3.jld2"
loadDc["0084CR"] = deepcopy(errDc);
@load "outDir/0085OA_errDcChFFTA3.jld2"
loadDc["0085OA"] = deepcopy(errDc);
@load "outDir/0086AO_errDcChFFTA3.jld2"
loadDc["0086AO"] = deepcopy(errDc);
@load "outDir/0087UO_errDcChFFTA3.jld2"
loadDc["0087UO"] = deepcopy(errDc);
@load "outDir/0088MO_errDcChFFTA3.jld2"
loadDc["0088MO"] = deepcopy(errDc);
@load "outDir/0089JC_errDcChFFTA3.jld2"
loadDc["0089JC"] = deepcopy(errDc);
@load "outDir/0090RR_errDcChFFTA3.jld2"
loadDc["0090RR"] = deepcopy(errDc);
@load "outDir/0091OD_errDcChFFTA3.jld2"
loadDc["0091OD"] = deepcopy(errDc);
@load "outDir/0092MT_errDcChFFTA3.jld2"
loadDc["0092MT"] = deepcopy(errDc);
@load "outDir/0093CC_errDcChFFTA3.jld2"
loadDc["0093CC"] = deepcopy(errDc);
@load "outDir/0094JT_errDcChFFTA3.jld2"
loadDc["0094JT"] = deepcopy(errDc);
@load "outDir/0095JV_errDcChFFTA3.jld2"
loadDc["0095JV"] = deepcopy(errDc);
@load "outDir/0096JC_errDcChFFTA3.jld2"
loadDc["0096JC"] = deepcopy(errDc);
@load "outDir/0097LH_errDcChFFTA3.jld2"
loadDc["0097LH"] = deepcopy(errDc);
@load "outDir/0098NP_errDcChFFTA3.jld2"
loadDc["0098NP"] = deepcopy(errDc);
@load "outDir/0099NM_errDcChFFTA3.jld2"
loadDc["0099NM"] = deepcopy(errDc);
@load "outDir/0100MM_errDcChFFTA3.jld2"
loadDc["0100MM"] = deepcopy(errDc);
@load "outDir/0101SC_errDcChFFTA3.jld2"
loadDc["0101SC"] = deepcopy(errDc);
@load "outDir/0102JA_errDcChFFTA3.jld2"
loadDc["0102JA"] = deepcopy(errDc);
@load "outDir/0103AB_errDcChFFTA3.jld2"
loadDc["0103AB"] = deepcopy(errDc);
@load "outDir/0104JA_errDcChFFTA3.jld2"
loadDc["0104JA"] = deepcopy(errDc);
@load "outDir/0105IF_errDcChFFTA3.jld2"
loadDc["0105IF"] = deepcopy(errDc);

ftrim = convert.(String, keys(loadDc)) |> sort

################################################################################

# PCA
R"
pacman::p_load(ggplot2)
source(file = 'utilitiesJL/multiplot.R')
pdf('pcaFocalized.pdf', width = 48, height = 81)
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
