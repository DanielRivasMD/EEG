####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using MindReader
  using HiddenMarkovModelReaders

  using DelimitedFiles

  # flux
  using Flux: cpu, gpu, flatten, leakyrelu

  # parameters
  using Parameters: @with_kw
end;

####################################################################################################

# load modules
begin
  # read parameters
  include(
    string(runDataset, "/Parameters.jl"),
  )

  # load annotation functions
  include(
    string(annotationDir, "/functions/annotationCalibrator.jl"),
    string(annotationDir, "/functions/fileReaderXLSX.jl"),
  )
end;

####################################################################################################

# TODO: modify by command line arguments
shArgs = Dict(
  "input" => "chb04_28.edf",
  "inputDir" => "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/",
  "outDir" => "/Users/drivas/Factorem/MindReader/data/",
  "window-size" => 256,
  "bin-overlap" => 4,
)

dir = "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/"
xfile = "chb04-summary.txt"
file = "chb04_28.edf"

annotFile = annotationReader(
  string(dir, xfile),
)

####################################################################################################

@info file

# read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)

  # calibrate annotations
  if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
    labelAr = annotationCalibrator(
      annotFile[replace(shArgs["input"], ".edf" => "")],
      startTime = startTime,
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      shParams = shArgs,
    )
  end
end;

####################################################################################################

# build autoencoder & train hidden Markov model
begin

  # create empty dictionary
  hmmDc = Dict{String, HMM}()

  # for (κ, υ) ∈ freqDc
  begin
    κ = "P8-O2"
    υ = freqDc[κ]

    println()
    @info κ

    #  build & train autoencoder
    freqAr = shifter(υ)

    model = buildAutoencoder(
      length(freqAr[1]);
      nnParams = NNParams,
    )

    modelTrain!(
      model,
      freqAr;
      nnParams = NNParams,
    )

    ####################################################################################################

    # calculate post autoencoder
    postAr = cpu(model).(freqAr)

    # autoencoder error
    aErr = reshifter(postAr - freqAr) |> π -> flatten(π) |> π -> permutedims(π)

    ####################################################################################################

    begin
      # TODO: add hmm iteration settings
      @info "Creating Hidden Markov Model..."

      # setup
      hmm = setup(aErr)

      # process
      for _ ∈ 1:4
        process!(
          hmm,
          aErr,
          true;
          params = hmmParams,
        )
      end

      # final
      for _ ∈ 1:2
        process!(
          hmm,
          aErr,
          false;
          params = hmmParams,
        )
      end

      # record hidden Markov model
      hmmDc[κ] = hmm
    end

    ####################################################################################################

  end

  println()

end;

####################################################################################################

# write traceback & states
writeHMM(hmmDc, shArgs)

####################################################################################################

if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))

  writedlm(
    string(shArgs["outDir"], "screen/", replace(shArgs["input"], "edf" => "csv"),),
    writePerformance(sensitivitySpecificity(hmmDc, labelAr)),
    ",",
  )

  ####################################################################################################

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs, labelAr)

else

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs)

end

####################################################################################################
