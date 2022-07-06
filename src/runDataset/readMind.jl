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

  # flux
  using Flux: cpu, gpu, flatten, leakyrelu

  # parameters
  using Parameters: @with_kw
end;

####################################################################################################

# argument parser
include(string(importDir, "/utilitiesJL/argParser.jl"));

####################################################################################################

# load parameters
include(string(shArgs["paramsDir"], shArgs["params"]))

####################################################################################################

# include additional protocols
if haskey(shArgs, "additional") && haskey(shArgs, "addDir")
  for ι ∈ split(shArgs["additional"], ",")
    include(string(shArgs["addDir"], ι))
  end
end

####################################################################################################

# read annotation
if haskey(shArgs, "annotation") && haskey(shArgs, "annotDir")
  annotFile = annotationReader(shArgs["annotDir"], shArgs["annotation"])
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
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      shParams = shArgs,
    )
  end
end;

####################################################################################################

# read available channels
channels = @chain begin
  readdir(mindHMM)
  filter(χ -> contains(χ, "chb01_01"), _)
  filter(χ -> contains(χ, "model"), _)
  replace.(_, "chb01_01_" => "")
  replace.(_, "_model.csv" => "")
end

# load hmm
hmmDc = reconstructHMM(mindHMM, "/chb01_01", channels)

####################################################################################################

if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
  writedlm(
    string(shArgs["outDir"], "/", "screen/", replace(shArgs["input"], "edf" => "csv")),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
    ", ",
  )

  ####################################################################################################

else

end

####################################################################################################
