####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  # mind reader
  using MindReader

  # hidden Markov model
  using HiddenMarkovModelReaders

  using DelimitedFiles
  using RCall

  # parameters
  using Parameters: @with_kw
end;

####################################################################################################

# argument parser
include(string(importDir, "/utilitiesJL/argParser.jl"));

####################################################################################################

# split parameter into vector
shArgs["input"] = shArgs["input"] |> π -> split(π, " ")
# declare artificial state
artificialState = 10.

####################################################################################################

# include additional protocols
if haskey(shArgs, "additional") && haskey(shArgs, "addDir")
  for ι ∈ split(shArgs["additional"], ",")
    include(string(shArgs["addDir"], ι))
  end
end

####################################################################################################

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) "

####################################################################################################

# read annotation
if haskey(shArgs, "annotation") && haskey(shArgs, "annotDir")
  annotFile = annotationReader(shArgs["annotDir"], shArgs["annotation"])
end

####################################################################################################

# read channels from summary
channels = annotationSummaryChannels(shArgs["annotDir"], shArgs["annotation"])

####################################################################################################

# declare master datatypes
msLabelAr = Vector{Float64}(undef, 0)
msHmmDc = Dict{String, HMM}(χ => HMM(Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Int32}(undef, 0)) for χ = channels)

####################################################################################################

# iterate on file vector
for ƒ ∈ shArgs["input"]

  # log
  @info ƒ

  ####################################################################################################

  edf = replace(ƒ, ".edf" => "")

  # read data
  begin

    # read edf file
    edfDf, startTime, recordFreq = getSignals(string(shArgs["inputDir"], ƒ))

    # calibrate annotations
    if haskey(annotFile, edf)
      labelAr = annotationCalibrator(
        annotFile[edf];
        recordFreq = recordFreq,
        signalLength = size(edfDf, 1),
        shParams = shArgs,
      )
    # declare an empty vector
    else
      labelAr = zeros(convert.(Int64, size(edfDf, 1) / (shArgs["window-size"] / shArgs["bin-overlap"])))
    end

  end;

  ####################################################################################################

  # record time points
  writedlm(
    string(mindData, "/", "time", "/", edf, ".txt"),
    [size(edfDf, 1)],
  )

  ####################################################################################################

  # load hmm
  hmmDc = reconstructHMM(string(mindHMM, "/"), edf, channels)

  ####################################################################################################

  # concatenate labels
  append!(msLabelAr, labelAr)

  # concatenate hidden Markov model traceback
  for (κ, υ) ∈ hmmDc
    append!(msHmmDc[κ].traceback, υ.traceback)
  end

  ####################################################################################################

end

####################################################################################################

writedlm(
  string(shArgs["outDir"], "/", "screen/", replace(shArgs["annotation"], "-summary.txt" => "")),
  writePerformance(sensitivitySpecificity(msHmmDc, msLabelAr)),
  ", ",
)

####################################################################################################

# declare time threshold
timeThres = 120

# iterate on dictionary
for (κ, υ) ∈ msHmmDc

  # declare traceback
  tb = υ.traceback

  # identify peak
  R" peakDf <- peak_iden($tb, 2) "
  @rget peakDf

  # reset traceback
  υ.traceback = ones(υ.traceback |> length)

  # assign peak values
  for ρ ∈ eachrow(filter(:peak_length_ix => χ -> χ >= timeThres, peakDf))
    υ.traceback[Int(ρ[:lower_lim_ix]):Int(ρ[:upper_lim_ix])] .= artificialState
  end

end

####################################################################################################

writedlm(
  string(shArgs["outDir"], "/", "filterScreen/", replace(shArgs["annotation"], "-summary.txt" => "")),
  writePerformance(sensitivitySpecificity(msHmmDc, msLabelAr)),
  ", ",
)

####################################################################################################
