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
edfDf, startTime, recordFreq = getSignals(file)

# read xlsx file
xDf = xread(xfile)

# extract signal bins
signalAr = extractSignalBin(edfDf, binSize = winBin, binOverlap = overlap)

# flatten array
signalAr = Flux.flatten(signalAr)

# labels array
labelAr = annotationCalibrator(
  xDf,
  startTime = startTime,
  recordFreq = recordFreq,
  signalLength = size(edfDf, 1),
  binSize = winBin,
  binOverlap = overlap
)

################################################################################

# multilayer perceptron
model = buildPerceptron(size(signalAr, 1), Params, relu)
model = modelTrain(signalAr, labelAr, model, Params)

################################################################################

# read edf file
TedfDf, TstartTime, TrecordFreq = getSignals(tfile)

# read xlsx file
TxDf = xread(xtfile)

# extract signal bins
TsignalAr = extractSignalBin(TedfDf, binSize = winBin, binOverlap = overlap)

# flatten array
TsignalAr = Flux.flatten(TsignalAr)

# labels array
TlabelAr = annotationCalibrator(
  TxDf,
  startTime = TstartTime,
  recordFreq = TrecordFreq,
  signalLength = size(TedfDf, 1),
  binSize = winBin,
  binOverlap = overlap
)

################################################################################

# test model
modelTest(TsignalAr, TlabelAr, model, Params)
modelSS(TsignalAr, TlabelAr, model, Params)

################################################################################
