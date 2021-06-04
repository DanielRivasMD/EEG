################################################################################

using MindReader
using HiddenMarkovModelReaders

################################################################################

import Parameters: @with_kw

################################################################################

# set hyperparameters
@with_kw mutable struct Params
  η::Float64                   = 1e-3             # learning rate
  epochs::Int                  = 10               # number of epochs
  batchsize::Int               = 1000             # batch size for training
  throttle::Int                = 5                # throttle timeout
  device::Function             = Flux.gpu         # set as gpu, if gpu available
  σ::Function                  = Flux.leakyrelu   # learning functionend;
end;

################################################################################

# hidden Markov model parameters
hmmParams = HMMParams(
  pen = 200.,
  distance = euclDist,
)
# TODO: perhaps pass them together with other Params

################################################################################

#  argument parser
include( "Utilities/argParser.jl" );

################################################################################

#  read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(file)

  # read xlsx file
  xfile = replace(file, "edf" => "xlsx")
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
    model = buildAutoencoder(length(freqAr[1]), 100, leakyrelu)
    model = modelTrain(freqAr, model, Params)

    ################################################################################

    postAr = cpu(model).(freqAr)

    ################################################################################

    begin
      @info "Creating Hidden Markov Model..."
      # error
      aErr = reshifter(postAr - freqAr) |> p -> Flux.flatten(p) |> permutedims

      # setup
      hmm = setup!(aErr)

      # process
      for i in 1:4
        errDc[k] = process(hmm, aErr, true, args = hmmParams)
      end

      # final
      for i in 1:2
        errDc[k] = process(hmm, aErr, false, args = hmmParams)
      end
    end;

    # # calculate sensitivity & specificity
    # ssDc[k]['E'] = sensspec(errDc[k][1], labelAr)

    ################################################################################

  end
end;

################################################################################

scr = sensspec(errDc, labelAr)

DelimitedFiles.writedlm( string(outscreen, outimg, ".csv"), writePerformance(scr), ", " )

################################################################################

runHeatmap(outimg, outsvg, outcsv, errDc)

################################################################################

writeHMM( string(outhmm, replace(file, ".edf" => "_")), errDc)

################################################################################

end

################################################################################
