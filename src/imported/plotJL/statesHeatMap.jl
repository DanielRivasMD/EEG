################################################################################

import JLD2                         # julia object
import AbstractPlotting, CairoMakie # plotting libraries

################################################################################

# import julia file
JLD2.@load "/Users/drivas/Factorem/EEG/data/objJL/0081MB_errDcChFFTA3.jld2"

file = "/Users/drivas/Factorem/EEG/Data/patientEEG/0081MB.edf"
xfile = "/Users/drivas/Factorem/EEG/Data/patientEEG/0081MB.xlsx"
winBin = 256
overlap = 2

utilDir = "utilitiesJL/"

################################################################################

# load functions
@info("Loading modules...")
include(string(utilDir, "electrodeID.jl")); # load electrodes
include(string(utilDir, "fileReader.jl"));
include(string(utilDir, "annotationCalibrator.jl"));
include(string(utilDir, "signalBin.jl"));

################################################################################

# read edf file
edfDf, startTime, recordFreq = getSignals(file)

# read xlsx file
xDf = xread(xfile)

# labels array
labelAr = annotationCalibrator(
  xDf,
  startTime = startTime,
  recordFreq = recordFreq,
  signalLength = size(edfDf, 1),
  binSize = winBin,
  binOverlap = overlap,
) .+= 1 # adjust labels

################################################################################

# create array to plot
toHeat = zeros(length(errDc) + 3, length(errDc[convert.(String, keys(errDc))[1]][1]))
c = size(toHeat, 1)
for k in elecID
  if haskey(errDc, k)
    toHeat[c, :] = errDc[k][1]
    global c -= 1
  else
    @info k
  end
end

# add label tracks
for ix in 1:size(labelAr, 2)
  toHeat[ix, :] .= labelAr[1:size(toHeat, 2), ix]
end

################################################################################

# rendering
sc = AbstractPlotting.Scene()
sc = AbstractPlotting.heatmap(toHeat', show_axis = false)
CairoMakie.save("hm.svg", sc, pt_per_unit = 0.5)

################################################################################
