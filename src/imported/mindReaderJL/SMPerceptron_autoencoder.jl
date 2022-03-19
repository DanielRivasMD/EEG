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
  fftBin = shArgs["fft"]
  winBin = shArgs["window-size"]
  overlap = shArgs["bin-overlap"]
end

################################################################################

# load functions
@info("Loading modules...")
include(string(utilDir, "fileReader.jl"));
include(string(utilDir, "signalBin.jl"));
include(string(utilDir, "FFT.jl"));
include(string(utilDir, "shapeShifter.jl"));
include(string(utilDir, "annotationCalibrator.jl"));
include(string(utilDir, "architect.jl"));
include(string(utilDir, "autoencoder.jl"));
include(string(utilDir, "SMPerceptron.jl"));
include(string(utilDir, "screening.jl"));

################################################################################

# set parameters
@with_kw mutable struct Params
  η::Float64 = 1e-4                               # learning rate
  epochs::Int = 10                                # number of epochs
  batchsize::Int = 1000                           # batch size for training
  throttle::Int = 5                               # throttle timeout
  labels::Array{Int64, 1} = 0:1                   # training labels
  device::Function = gpu                          # set as gpu, if gpu available
end

################################################################################

# read edf file
edfDf, startTime, recordFreq = getSignals(file)

# read xlsx file
xDf = xread(xfile)

# calculate fft
freqAr = extractFFT(edfDf, binSize = winBin, binOverlap = overlap)

# reshape based on time frames
freqAr = shifter(freqAr)

################################################################################

# autoencoder
autoencoderModel = buildAutoencoder(length(freqAr[1]), 50, leakyrelu)
autoencoderModel = modelTrain(freqAr, autoencoderModel, Params)

################################################################################

postAr = copy(freqAr)
for i in 1:length(freqAr)
  postAr[i] = cpu(autoencoderModel)(freqAr[i])
end

################################################################################

# reshape post autoencoder
postAr = reshifter(postAr)

# flatten array
postAr = Flux.flatten(postAr)

################################################################################

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
SMPerceptronModel = buildPerceptron(size(postAr, 1), Params, relu)
SMPerceptronModel = modelTrain(postAr, labelAr, SMPerceptronModel, Params)

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
modelTest(TsignalAr, TlabelAr, SMPerceptronModel, Params)
modelSS(TsignalAr, TlabelAr, SMPerceptronModel, Params)

################################################################################
