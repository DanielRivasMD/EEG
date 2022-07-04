################################################################################

using MindReader
using HiddenMarkovModelReaders

################################################################################

import Flux: cpu, gpu, flatten, leakyrelu

################################################################################

import Parameters: @with_kw

################################################################################

# read parameters
include("Parameters.jl");

################################################################################

include("/Users/drivas/Factorem/EEG/src/annotation/functions/annotationCalibrator.jl")
include("/Users/drivas/Factorem/EEG/src/annotation/functions/fileReaderXLSX.jl")

################################################################################

# # argument parser
# include("runDataset/argParser.jl");

################################################################################

# TODO: modify by command line arguments
shArgs = Dict(
  "indir" => "/Users/drivas/Factorem/EEG/data/patientEEG/",
  "file" => "0104JA.edf",
  # "file" => "0100MM.edf",
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

# read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)

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
end;

################################################################################

# build autoencoder & train hidden Markov model
begin

  # create empty dictionary
  errDc = Dict{String, Tuple{Array{Int64, 1}, Array{Array{Float64, 1}, 1}}}()

  for (κ, υ) ∈ freqDc
    println()
    @info κ

    #  build & train autoencoder
    freqAr = shifter(υ)
    model = buildAutoencoder(length(freqAr[1]), nnParams = NNParams)
    model = modelTrain!(model, freqAr, nnParams = NNParams)

    ################################################################################

    # calculate post autoencoder
    postAr = cpu(model).(freqAr)

    ################################################################################

    begin
      @info "Creating Hidden Markov Model..."
      # error
      aErr = reshifter(postAr - freqAr) |> π -> flatten(π) |> permutedims

      # setup
      hmm = setup(aErr)

      # process
      for _ ∈ 1:4
        errDc[κ] = process!(hmm, aErr, true, params = hmmParams)
      end

      # final
      for _ ∈ 1:2
        errDc[κ] = process!(hmm, aErr, false, params = hmmParams)
      end
    end;

    ################################################################################

  end

  println()

end;

################################################################################

# write traceback & states
writeHMM(errDc, shArgs)

################################################################################

# graphic rendering
mindGraphics(errDc, shArgs, labelAr)

################################################################################

# measure sensitivity & specificity
scr = sensitivitySpecificity(errDc, labelAr)
writedlm(string(shArgs["outscreen"], replace(shArgs["file"], "edf" => "csv")), writePerformance(scr), ", ")

################################################################################
