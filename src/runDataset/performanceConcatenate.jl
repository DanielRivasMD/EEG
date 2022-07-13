####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  # using Chain: @chain

  # # mind reader
  # using MindReader

  # # hidden Markov model
  # using HiddenMarkovModelReaders

  # using DelimitedFiles
  # using RCall

  # # parameters
  # using Parameters: @with_kw
end;

####################################################################################################

# argument parser
include(string(importDir, "/utilitiesJL/argParser.jl"));

# split parameter into vector
shArgs["input"] = shArgs["input"] |> π -> split(π, " ")

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

# declare master datatypes
msLabelAr = Vector{Number}
msHmmDc = Dict{HMM}

####################################################################################################

# iterate on file vector
for ƒ ∈ shArgs["input"]

  # log
  @info ƒ

  ####################################################################################################

  edf = replace(shArgs["input"], ".edf" => "")

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
      labelAr = zeros(1)
    end

  end;

  ####################################################################################################

  # record time points
  writedlm(
    string(mindData, "/", "time", "/", edf, ".txt"),
    [size(edfDf, 1)],
  )

  ####################################################################################################

  # read available channels
  channels = @chain begin
    readdir(mindHMM)
    filter(χ -> contains(χ, edf), _)
    filter(χ -> contains(χ, "model"), _)
    replace.(_, string(edf, "_") => "")
    replace.(_, "_model.csv" => "")
  end

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

  # TODO: calculate performance unfiltered
  writedlm(
    string(shArgs["outDir"], "/", "screen/", replace(shArgs["input"], "edf" => "csv")),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
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
    υ.traceback[Int(ρ[:lower_lim_ix]):Int(ρ[:upper_lim_ix])] .= 10.
  end

end

####################################################################################################

# TODO: calculate performance filtered
  writedlm(
    string(shArgs["outDir"], "/", "filterScreen/", replace(shArgs["input"], "edf" => "csv")),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
    ", ",
  )

####################################################################################################
