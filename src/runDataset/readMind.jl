####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  using MindReader
  using HiddenMarkovModelReaders

  using DelimitedFiles

  # flux
  using Flux: cpu, gpu, flatten, leakyrelu

  # parameters
  using Parameters: @with_kw
end;

####################################################################################################

# argument parser
include("/Users/drivas/Factorem/EEG/src/imported/utilitiesJL/argParser.jl");

####################################################################################################

# load parameters
include(
  string(shArgs["paramsDir"], shArgs["params"]),
)

####################################################################################################

# include additional protocols
if haskey(shArgs, "additional") && haskey(shArgs, "addDir")
  for ι ∈ split(shArgs["additional"], ",")
    include(
      string(shArgs["addDir"], ι),
    )
  end
end

####################################################################################################

# read annotation
if haskey(shArgs, "annotation") && haskey(shArgs, "annotDir")
  annotFile = annotationReader(
    string(shArgs["annotDir"], shArgs["annotation"]),
  )
end

####################################################################################################

#  read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)

  # calibrate annotations
  if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
    labelAr = annotationCalibrator(
      annotFile[replace(shArgs["input"], ".edf" => "")];
      startTime = startTime,
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      shParams = shArgs,
    )
  end
end;

# ####################################################################################################

# # build autoencoder & train hidden Markov model
# begin

#   # create empty dictionary
#   hmmDc = Dict{String, HMM}()

#   for (κ, υ) in freqDc

#     print()
#     @info κ

#     #  build & train autoencoder
#     freqAr = shifter(υ)

#     model = buildAutoencoder(
#       length(freqAr[1]);
#       nnParams = NNParams,
#     )

#     modelTrain!(
#       model,
#       freqAr;
#       nnParams = NNParams,
#     )

#     ####################################################################################################

#     # calculate post autoencoder
#     postAr = cpu(model).(freqAr)

#     # autoencoder error
#     aErr = reshifter(postAr - freqAr) |> π -> flatten(π) |> π -> permutedims(π)

#     ####################################################################################################

#     begin
#       # TODO: add hmm iteration settings
#       @info "Creating Hidden Markov Model..."

#       # setup
#       hmm = setup(aErr)

#       # process
#       for _ ∈ 1:4
#         _ = process!(
#             hmm,
#           aErr,
#           true;
#           params = hmmParams,
#         )
#       end

#       # final
#       for _ ∈ 1:2
#         _ = process!(
#           hmm,
#           aErr,
#           false;
#           params = hmmParams,
#         )
#       end

#       # record hidden Markov model
#       hmmDc[κ] = hmm
#     end

#     ####################################################################################################

#   end

#   print()
# end;

# ####################################################################################################

# # write traceback & states
# writeHMM(hmmDc, shArgs)

# ####################################################################################################

# load hmm
# TODO: build & using hmm reconstruction

####################################################################################################

if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
  writedlm(
    string(shArgs["outDir"], "screen/", replace(shArgs["input"], "edf" => "csv")),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
    ", ",
  )

  ####################################################################################################

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs, labelAr)

else

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs)

end

####################################################################################################
