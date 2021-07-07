################################################################################

using MindReader
using HiddenMarkovModelReaders

################################################################################

import Flux: cpu, gpu, flatten, leakyrelu
using DelimitedFiles

################################################################################

import Parameters: @with_kw

################################################################################

include("/Users/drivas/Factorem/EEG/src/annotationFunctions/annotationCalibrator.jl")
include("/Users/drivas/Factorem/EEG/src/annotationFunctions/fileReaderXLSX.jl")

################################################################################

# set hyperparameters
@with_kw mutable struct Params
  η::Float64                   = 1e-3             # learning rate
  epochs::Int                  = 25               # number of epochs
  batchsize::Int               = 1000             # batch size for training
  throttle::Int                = 5                # throttle timeout
  device::Function             = gpu              # set as gpu, if gpu available
  σ::Function                  = leakyrelu        # learning function
end;

################################################################################

# hidden Markov model parameters
hmmParams = HMMParams(
  distance = euclDist,
  verbosity = true,
)

################################################################################

# TODO: modify by command line arguments
shArgs = Dict(
  "indir" => "/Users/drivas/Factorem/EEG/data/patientEEG/",
  "file" => "0100MM.edf",
  # "file" => "0001LB.edf",
  "outdir" => "/Users/drivas/Factorem/MindReader/tmp/",
  "outsvg" => nothing,
  "outcsv" => nothing,
  "outscreen" => "/Users/drivas/Factorem/MindReader/tmp/",
  "outhmm" => "/Users/drivas/Factorem/MindReader/tmp/",
  "window-size" => 128,
  "bin-overlap" => 4,
)

################################################################################

# #  argument parser
# include( "Utilities/argParser.jl" );

################################################################################

# read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # read xlsx file
  xDf = xread(shArgs)

  # labels array
  labelAr = annotationCalibrator(
    xDf,
    startTime = startTime,
    recordFreq = recordFreq,
    signalLength = size(edfDf, 1),
    shParams = shArgs,
  )

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)
end;

################################################################################

# build autoencoder & train hidden Markov model
begin

  # create empty dictionary
  errDc = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()

  for (k, f) in freqDc
    println()
    @info k

    #  build & train autoencoder
    freqAr = shifter(f)
    model = buildAutoencoder(length(freqAr[1]), 100, Params)
    model = modelTrain(freqAr, model, Params)

    ################################################################################

    postAr = cpu(model).(freqAr)

    ################################################################################

    begin
      @info "Creating Hidden Markov Model..."
      # error
      aErr = reshifter(postAr - freqAr) |> p -> flatten(p) |> permutedims

      # setup
      hmm = setup(aErr)

      # process
      for i in 1:4
        errDc[k] = process!(hmm, aErr, true, params = hmmParams)
      end

      # final
      for i in 1:2
        errDc[k] = process!(hmm, aErr, false, params = hmmParams)
      end
    end;

    ################################################################################

  end

  println()

end;

################################################################################

scr = sensitivitySpecificity(errDc, labelAr)

DelimitedFiles.writedlm( string(shArgs["outscreen"], replace(shArgs["file"], "edf" => "csv")), writePerformance(scr), ", " )

################################################################################

runHeatmap(shArgs, errDc)
runHeatmap(shArgs, errDc, labelAr)

################################################################################

writeHMM( string(shArgs["outhmm"], replace(shArgs["file"], ".edf" => "_")), errDc)

################################################################################
