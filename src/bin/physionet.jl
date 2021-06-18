################################################################################

using MindReader
using HiddenMarkovModelReaders

################################################################################

import Parameters: @with_kw

# set hyperparameters
@with_kw mutable struct Params
  η::Float64                   = 1e-3             # learning rate
  epochs::Int                  = 30               # number of epochs
  batchsize::Int               = 1000             # batch size for training
  throttle::Int                = 5                # throttle timeout
  device::Function             = Flux.gpu         # set as gpu, if gpu available
  σ::Function                  = Flux.leakyrelu   # learning function
end;

################################################################################

# hidden Markov model parameters
hmmParams = HMMParams(pen = 200., distance = euclDist)

################################################################################

# #  argument parser
# include( "Utilities/argParser.jl" );

################################################################################

outsvg = "/Users/drivas/Factorem/MindReader/data/svg/"
outcsv = "/Users/drivas/Factorem/MindReader/data/csv/"
outscreen = "/Users/drivas/Factorem/MindReader/data/screen/"
outhmm = "/Users/drivas/Factorem/MindReader/data/hmm/"

shArgs = Dict(
  "indir" => "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/",
  "file" => "chb04_28.edf",
  "outdir" => "/Users/drivas/Factorem/MindReader/data/",
  "outsvg" => nothing,
  "outcsv" => nothing,
  "outscreen" => "/Users/drivas/Factorem/MindReader/data/screen/",
  "outhmm" => "/Users/drivas/Factorem/MindReader/data/hmm/",
  "window-size" => 256,
  "bin-overlap" => 4,
)

dir = "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/"
xfile = "chb04-summary.txt"
file = "chb04_28.edf"

winBin = 256
overlap = 4

annotFile = annotationReader( string(dir, xfile) )

################################################################################

dirRead = readdir(dir)
fileList = contains.(dirRead, r"edf$") |> p -> getindex(dirRead, p)

# for file in fileList

  @info file
  outimg = replace(file, ".edf" => "")

  #  read data
  begin
    # read edf file
    edfDf, startTime, recordFreq = getSignals( string(dir, file) )

    if haskey(annotFile, outimg)

      labelAr = annotationCalibrator(
        annotFile[outimg],
        startTime = startTime,
        recordFreq = recordFreq,
        signalLength = size(edfDf, 1),
        binSize = winBin,
        binOverlap = overlap
      )

    end

    # calculate fft
    freqDc = extractChannelFFT(edfDf, binSize = winBin, binOverlap = overlap)
  end;

  ################################################################################

  # build autoencoder & train hidden Markov model
  begin
    for d in [Symbol(i, "Dc") for i = [:err, :post, :comp]]
      @eval $d = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()
    end

    for (k, f) in freqDc
      println()
      @info k

      #  build & train autoencoder
      freqAr = shifter(f)
      model = buildAutoencoder(length(freqAr[1]), convert(Int64, length(freqAr[1] / 4)), Params)
      model = modelTrain(freqAr, model, Params)

      ################################################################################

      postAr = Flux.cpu(model).(freqAr)

      ################################################################################

      begin
        @info "Creating Hidden Markov Model..."
        # error
        aErr = reshifter(postAr - freqAr) |> p -> Flux.flatten(p) |> permutedims

        # setup
        hmm = setup!(aErr)

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
  end;

  ################################################################################

  writeHMM( string(shArgs["outhmm"], replace(shArgs["file"], ".edf" => "_")), errDc)

  ################################################################################

  if haskey(annotFile, outimg)

    scr = sensspec(errDc, labelAr)

    DelimitedFiles.writedlm( string(outscreen, outimg, ".csv"), writePerformance(scr), ", " )

    ################################################################################

    runHeatmap(shArgs, errDc, labelAr)

  else

    runHeatmap(shArgs, errDc)

  end

  ################################################################################

# end

################################################################################
