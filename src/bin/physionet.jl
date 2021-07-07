################################################################################

using MindReader
using HiddenMarkovModelReaders

################################################################################

import Flux: cpu, gpu, flatten, leakyrelu
using DelimitedFiles

################################################################################

import Parameters: @with_kw

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
  "indir" => "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/",
  "file" => "chb04_28.edf",
  "outdir" => "/Users/drivas/Factorem/MindReader/data/",
  "outsvg" => "/Users/drivas/Factorem/MindReader/data/svg/",
  "outcsv" => "/Users/drivas/Factorem/MindReader/data/csv/",
  "outscreen" => "/Users/drivas/Factorem/MindReader/data/screen/",
  "outhmm" => "/Users/drivas/Factorem/MindReader/data/hmm/",
  "window-size" => 256,
  "bin-overlap" => 4,
)

dir = "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/"
xfile = "chb04-summary.txt"
file = "chb04_28.edf"

annotFile = annotationReader( string(dir, xfile) )

################################################################################

# #  argument parser
# include( "Utilities/argParser.jl" );

################################################################################

dirRead = readdir(dir)
fileList = contains.(dirRead, r"edf$") |> p -> getindex(dirRead, p)

# for file in fileList

  @info file

  #  read data
  begin
    # read edf file
    edfDf, startTime, recordFreq = getSignals(shArgs)

    if haskey(annotFile, replace(shArgs["file"], ".edf" => ""))

      labelAr = annotationCalibrator(
        annotFile[replace(shArgs["file"], ".edf" => "")],
        startTime = startTime,
        recordFreq = recordFreq,
        signalLength = size(edfDf, 1),
        binSize = shArgs["window-size"],
        binOverlap = shArgs["bin-overlap"],
      )

    end

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
      model = buildAutoencoder(length(freqAr[1]), convert(Int64, length(freqAr[1] / 4)), Params)
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

  writeHMM( string(shArgs["outhmm"], replace(shArgs["file"], ".edf" => "_")), errDc)

  ################################################################################

  if haskey(annotFile, replace(shArgs["file"], ".edf" => ""))

    scr = sensitivitySpecificity(errDc, labelAr)

    DelimitedFiles.writedlm( string(shArgs["outscreen"], replace(shArgs["file"], "edf" => "csv")), writePerformance(scr), ", " )

    ################################################################################

    runHeatmap(shArgs, errDc, labelAr)

  else

    runHeatmap(shArgs, errDc)

  end

  ################################################################################

# end

################################################################################
