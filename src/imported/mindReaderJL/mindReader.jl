################################################################################

using UnicodePlots

################################################################################

file = "/Users/drivas/Factorem/EEG/Data/patientEEG/0021MA.edf"
xfile = "/Users/drivas/Factorem/EEG/Data/patientEEG/0021MA.xlsx"
utilDir = "utilitiesJL/"
winBin = 256
overlap = 2

################################################################################

using Parameters: @with_kw

################################################################################

utilDir = "../utilitiesJL/"
include(string(utilDir, "argParser.jl"))

# parse shell arguments
shArgs = shArgParser(ARGS)

begin
  file = shArgs["file"]
  # xfile = shArgs["xlsx"]
  # tfile = shArgs["test-file"]
  # xtfile = shArgs["test-xlsx"]
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
include(string(utilDir, "EHMM.jl"));
include(string(utilDir, "architect.jl"));
include(string(utilDir, "annotationCalibrator.jl"));

################################################################################

# set parameters
@with_kw mutable struct Params
  η::Float64 = 1e-3                               # learning rate
  epochs::Int = 10                                # number of epochs
  batchsize::Int = 1000                           # batch size for training
  throttle::Int = 5                               # throttle timeout
  device::Function = gpu                          # set as gpu, if gpu available
end

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
  binOverlap = overlap
)

# calculate fft
freqDc = extractChannelFFT(edfDf, binSize = winBin, binOverlap = overlap)

# # iterate through dictionary
# modelDc = Dict()
# timeDc = Dict()


tbDc = Dict()
for (k, f) in freqDc
  @info k
  v = binChannelFFT(f)
  # setup
  mPen, hmm = setup(v)
  # process
  for i in 1:5
    tbDc[k] = process(hmm, v, mPen)
  end
  # println(lineplot(tbDc[k], width = 180))
end



  # # reshape based on time frames
  # timeDc[k] = gpu.(vec.(shifter(v)))
  #
  # ################################################################################
  #
  # # multilayer perceptron
  # modelDc[k] = buildPerceptron(size(timeDc[k], 1), Params, relu)
  # modelDc[k] = modelTrain(timeDc[k], labelAr, modelDc[k], Params)
  #
  # ################################################################################
