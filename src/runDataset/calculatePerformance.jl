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

# read annotation
annotFile = annotationReader("data/chb21-summary.txt",)

####################################################################################################

# read data
for ƒ ∈ readdir() |> π -> contains.(π, "src") |> π -> readdir()[π]
  @info ƒ

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
  end
end

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
