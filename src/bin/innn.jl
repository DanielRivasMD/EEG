################################################################################

using MindReader
using HiddenMarkovModelReaders

import Flux: cpu, gpu, flatten, leakyrelu
using DelimitedFiles

################################################################################

import Parameters: @with_kw

################################################################################

# set hyperparameters
@with_kw mutable struct Params
  η::Float64                   = 1e-3             # learning rate
  epochs::Int                  = 10               # number of epochs
  batchsize::Int               = 1000             # batch size for training
  throttle::Int                = 5                # throttle timeout
  device::Function             = gpu              # set as gpu, if gpu available
  σ::Function                  = leakyrelu        # learning function
end;

################################################################################

# hidden Markov model parameters
hmmParams = HMMParams(
  distance = euclDist,
)
# TODO: perhaps pass them together with other Params

################################################################################

shArgs = Dict(
  "indir" => "/Users/drivas/Factorem/EEG/data/patientEEG/",
  "file" => "0001LB.edf",
  "outdir" => "/Users/drivas/Factorem/MindReader/",
  "outsvg" => nothing,
  "outcsv" => nothing,
  "outscreen" => "/Users/drivas/Factorem/MindReader/",
  "outhmm" => "/Users/drivas/Factorem/MindReader/",
  "window-size" => 128,
  "bin-overlap" => 4,
)

# file = "/Users/drivas/Factorem/EEG/data/patientEEG/0001LB.edf"
# winBin = 128
# overlap = 4

# #  argument parser
# include( "Utilities/argParser.jl" );

################################################################################

#  read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals( string(shArgs["indir"], shArgs["file"]) )
  # edfDf, startTime, recordFreq = getSignals(file)

  # read xlsx file
  xDf = xread( string(shArgs["indir"], replace(shArgs["file"], "edf" => "xlsx")) )
  # xfile = replace(file, "edf" => "xlsx")
  # xDf = xread( xfile )

  # labels array
  labelAr = annotationCalibrator(
    xDf,
    startTime = startTime,
    recordFreq = recordFreq,
    signalLength = size(edfDf, 1),
    binSize = shArgs["window-size"],
    binOverlap = shArgs["bin-overlap"],
  )

  # calculate fft
  freqDc = extractChannelFFT(edfDf, binSize = shArgs["window-size"], binOverlap = shArgs["bin-overlap"])
  # freqDc = extractChannelFFT(edfDf, binSize = winBin, binOverlap = overlap)
end;

################################################################################

# build autoencoder & train hidden Markov model
begin
  # for d in [Symbol(i, "Dc") for i = [:err, :post, :comp]]
    # @eval $d = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()
  # end

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

    # # calculate sensitivity & specificity
    # ssDc[k]['E'] = sensspec(errDc[k][1], labelAr)

    ################################################################################

  end

  println()

end;

################################################################################

# scr = sensspec(errDc, labelAr)


# DelimitedFiles.writedlm( string(outscreen, outimg, ".csv"), writePerformance(scr), ", " )

################################################################################

runHeatmap(shArgs, errDc)
# runHeatmap(shArgs, errDc, labelAr)

################################################################################

writeHMM( string(shArgs["outhmm"], replace(shArgs["file"], ".edf" => "_")), errDc)

################################################################################

# end

################################################################################
