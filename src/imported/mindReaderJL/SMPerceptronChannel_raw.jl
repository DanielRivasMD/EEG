################################################################################

using Parameters: @with_kw

################################################################################

utilDir = "../utilitiesJL/"
include(string(utilDir, "ArgParser.jl"))

# parse shell arguments
shArgs = shArgParser(ARGS)

begin
  file = shArgs["file"]
  xfile = shArgs["xlsx"]
  tfile = shArgs["test-file"]
  xtfile = shArgs["test-xlsx"]
  winBin = shArgs["window-size"]
  overlap = shArgs["bin-overlap"]
end

################################################################################

# load functions
@info("Loading modules...")
include(string(utilDir, "fileReader.jl"));
include(string(utilDir, "signalBin.jl"));
include(string(utilDir, "annotationCalibrator.jl"));
include(string(utilDir, "architect.jl"));
include(string(utilDir, "SMPerceptron.jl"));
include(string(utilDir, "screening.jl"));

################################################################################

# set parameters
@with_kw mutable struct Params
  η::Float64 = 1e-4                               # learning rate
  epochs::Int = 10                                # number of epochs
  batchsize::Int = 1000                           # batch size for training
  labels::Array{Int64, 1} = 0:1                   # training labels
  device::Function = gpu                          # set as gpu, if gpu available
end

################################################################################

# read edf file
edfDf, startTime, recordFreq, electrodeID = getSignals(file)

# read xlsx file
xDf = xread(xfile)

# labels array
labelAr = annotationCalibrator(
  xDf,
  startTime = startTime,
  recordFreq = recordFreq,
  signalLength = size(edfDf, 1),
  binSize = winBin,
  binOverlap = overlap
)

# extract signal bins
signalDc = extractChannelSignalBin(edfDf, electrodeID, binSize = winBin, binOverlap = overlap)

# iterate through dictionary
modelDc = Dict()
for (k, v) in signalDc

  # flatten array
  signalDc[k] = Flux.flatten(v)

  ################################################################################

  # multilayer perceptron
  modelDc[k] = buildPerceptron(size(signalDc[k], 1), Params, relu)
  modelDc[k] = modelTrain(signalDc[k], labelAr, modelDc[k], Params)

  ################################################################################

end
