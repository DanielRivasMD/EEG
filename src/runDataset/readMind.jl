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

begin
  # declare peak identification function
  R"
  peak_iden <- function(

    f_seq,
    d_threshold = NULL
  ) {

    if (is.null(d_threshold)) d_threshold <- 1
    f_seq <- c(0, f_seq, 0)
    f_threseq <- which(f_seq >= d_threshold)
    f_peak_length <- which(f_seq[f_threseq + 1] < d_threshold) - which(f_seq[f_threseq-1] < d_threshold) + 1
    f_upper_lim_ix <- (f_threseq[cumsum(f_peak_length)]) - 1
    f_lower_lim_ix <- f_upper_lim_ix - f_peak_length + 1
    peak_feat <- data.frame(peak_no = seq_along(f_lower_lim_ix), lower_lim_ix = f_lower_lim_ix, upper_lim_ix = f_upper_lim_ix, peak_length_ix = f_peak_length)

    return(peak_feat)
  }
  "
end;

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

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)

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
  R"peakDf <- peak_iden($tb, 2)"
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
