####################################################################################################

# declarations
begin
  include( "/Users/drivas/Factorem/EEG/src/config/config.jl" )
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  using HiddenMarkovModelReaders
end;

####################################################################################################

# TODO: read annotation
if haskey(shArgs, "annotation") && haskey(shArgs, "annotDir")
  annotFile = annotationReader(
    string(shArgs["annotDir"], shArgs["annotation"]),
  )
end

####################################################################################################

# TODO: read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)

  # calibrate annotations
  if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
    labelAr = annotationCalibrator(
      annotFile[replace(shArgs["input"], ".edf" => "")];
      # BUG: annotation probably offset for calling wrong function
      startTime = startTime,
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      shParams = shArgs,
    )
  end
end;

####################################################################################################

# TODO: write edf file metadata

####################################################################################################

# load hidden Markov model model
model = @chain begin
  readdf("data/hmm/chb01_01_C3-P3_model.csv", ',')
  map(1:size(_, 2)) do μ
    _[:, μ]
  end
end

# load hidden Markov model traceback
traceback = @chain begin
  readdf("data/hmm/chb01_01_C3-P3_traceback.csv", ',')
  _[:, 1]
end

# reconstruct hidden Markov model with empty data
hmm = HMM([zeros(0)], model, traceback)

####################################################################################################

# TODO: calculate accuracy
sensitivitySpecificity(hmmDc, labelAr)

####################################################################################################
