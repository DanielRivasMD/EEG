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

edf = replace(shArgs["input"], ".edf" => "")

# read data
begin

  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # calibrate annotations
  if haskey(annotFile, edf)
    labelAr = annotationCalibrator(
      annotFile[edf];
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      shParams = shArgs,
    )
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

# calculate performance unfiltered
if haskey(annotFile, edf)
  writedlm(
    string(shArgs["outDir"], "/", "screen/", replace(shArgs["input"], "edf" => "csv")),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
    ", ",
  )
end

####################################################################################################

# declare time threshold
timeThres = 120

# iterate on dictionary
for (κ, υ) ∈ hmmDc

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

# calculate performance filtered
if haskey(annotFile, edf)
  writedlm(
    string(shArgs["outDir"], "/", "filterScreen/", replace(shArgs["input"], "edf" => "csv")),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
    ", ",
  )
end

####################################################################################################
