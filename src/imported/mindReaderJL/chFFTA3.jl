################################################################################

utilDir = "../utilitiesJL/"
include(string(utilDir, "argParser.jl"))

# parse shell arguments
shArgs = shArgParser(ARGS)

begin
  file = shArgs["file"]
  xfile = shArgs["xlsx"]
  winBin = shArgs["window-size"]
  overlap = shArgs["bin-overlap"]
end

begin
  ftrim = replace(file, r".+/" => "")
  ftrim = replace(ftrim, ".edf" => "")
end

################################################################################

@info ftrim
println()

################################################################################

# load functions
@info("Loading modules...")
include(string(utilDir, "fileReader.jl"));
include(string(utilDir, "signalBin.jl"));
include(string(utilDir, "FFT.jl"));
include(string(utilDir, "shapeShifter.jl"));
include(string(utilDir, "annotationCalibrator.jl"));
include(string(utilDir, "EHMM.jl"));
include(string(utilDir, "architect.jl"));
include(string(utilDir, "autoencoder.jl"));
include(string(utilDir, "screening.jl"));

################################################################################

using Parameters: @with_kw

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
  binOverlap = overlap,
) .+= 1 # adjust labels

# calculate fft
freqDc = extractChannelFFT(edfDf, binSize = winBin, binOverlap = overlap)

################################################################################

# TODO: check errors. Array
postDc = Dict()
errDc = Dict()
compDc = Dict()
ssDc = Dict()
for (k, f) in freqDc
  println()
  @info k
  ssDc[k] = Dict()
  freqAr = shifter(f)
  model = buildAutoencoder(length(freqAr[1]), 100, leakyrelu)
  model = modelTrain(freqAr, model, Params)

  ################################################################################

  # post
  postAr = cpu(model).(freqAr)
  aPos = reshifter(postAr) |> p -> Flux.flatten(p)

  # setup
  mPen, hmm = setup(aPos)
  # process
  for i in 1:5
    postDc[k] = process(hmm, aPos, mPen)
  end

  # calculate sensitivity & specificity
  ssDc[k]['P'] = sensspec(postDc[k][1], labelAr)

  ################################################################################

  # error
  aErr = reshifter(postAr - freqAr) |> p -> Flux.flatten(p)

  # setup
  mPen, hmm = setup(aErr)
  # process
  for i in 1:5
    errDc[k] = process(hmm, aErr, mPen)
  end

  # calculate sensitivity & specificity
  ssDc[k]['E'] = sensspec(errDc[k][1], labelAr)

  ################################################################################

  # compressed
  compAr = cpu(model[1]).(freqAr)
  aComp = reshifter(compAr, length(compAr[1])) |> p -> Flux.flatten(p)

  # setup
  mPen, hmm = setup(aComp)
  # process
  for i in 1:5
    compDc[k] = process(hmm, aComp, mPen)
  end

  # calculate sensitivity & specificity
  ssDc[k]['C'] = sensspec(compDc[k][1], labelAr)

  ################################################################################

end

################################################################################

using JLD2

################################################################################

outDir = "outDir/"

@save string(outDir, ftrim, "_postDcChFFTA3.jld2") postDc
@save string(outDir, ftrim, "_errDcChFFTA3.jld2") errDc
@save string(outDir, ftrim, "_compDcChFFTA3.jld2") compDc
@save string(outDir, ftrim, "_ssDcChFFTA3.jld2") ssDc

################################################################################

# overall performance
for k in ['P', 'E', 'C']
  sn = 0
  sp = 0
  for (_, v) in ssDc
    sn += v[k].sensitivity
    sp += v[k].specificity
  end
  @info "$k sensitivity = $(sn / length(ssDc))"
  @info "$k specificity = $(sp / length(ssDc))"
end

################################################################################
