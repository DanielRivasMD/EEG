################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

################################################################################

# # load project enviroment
# using Pkg
# if Pkg.project().path != string(projDir, "/Project.toml")
#   Pkg.activate(projDir)
# end

################################################################################

# load packages
begin
  using MindReader
  using HiddenMarkovModelReaders

  using DelimitedFiles
end;

################################################################################

# import flux
import Flux: cpu, gpu, flatten, leakyrelu

################################################################################

# import parameters
import Parameters: @with_kw

################################################################################

# load modules
begin
  # read parameters
  include(string(runDataset, "/Parameters.jl"))

  # load annotation functions
  include(string(annotationDir, "/functions/annotationCalibrator.jl"))
  include(string(annotationDir, "/functions/fileReaderXLSX.jl"))
end;

################################################################################

# # argument parser
# include( "runDataset/argParser.jl" );

################################################################################

# outsvg = "/Users/drivas/Factorem/MindReader/data/svg/"
# outcsv = "/Users/drivas/Factorem/MindReader/data/csv/"
# outscreen = "/Users/drivas/Factorem/MindReader/data/screen/"
# outhmm = "/Users/drivas/Factorem/MindReader/data/hmm/"

# TODO: modify by command line arguments
shArgs = Dict(
  "indir" => "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/",
  "file" => "chb04_28.edf",
  "outdir" => "/Users/drivas/Factorem/MindReader/data/",
  "outsvg" => "/Users/drivas/Factorem/MindReader/data/svg/",
  "outcsv" => "/Users/drivas/Factorem/MindReader/data/csv/",
  "outscreen" => "/Users/drivas/Factorem/MindReader/data/screen/",
  "outhmm" => "/Users/drivas/Factorem/MindReader/data/hmm/",
  "window-size" => 256,
  "bin-overlap" => 4,
)

dir = "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/"
xfile = "chb04-summary.txt"
file = "chb04_28.edf"

annotFile = annotationReader(string(dir, xfile))

################################################################################

dirRead = readdir(dir)
fileList = contains.(dirRead, r"edf$") |> π -> getindex(dirRead, π)

# for file in fileList

@info file

#  read data
begin
  # read edf file
  edfDf, startTime, recordFreq = getSignals(shArgs)

  # calculate fft
  freqDc = extractFFT(edfDf, shArgs)

  if haskey(annotFile, replace(shArgs["file"], ".edf" => ""))
    labelAr = annotationCalibrator(
      annotFile[replace(shArgs["file"], ".edf" => "")],
      startTime = startTime,
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      shParams = shArgs,
    )
  end
end;

################################################################################

# build autoencoder & train hidden Markov model
begin

  # create empty dictionary
  hmmDc = Dict{String,HMM}()

  for (κ, υ) ∈ freqDc

  # κ = "P8-O2"
  # υ = freqDc[κ]

  println()
  @info κ

  #  build & train autoencoder
  freqAr = shifter(υ)
  model = buildAutoencoder(length(freqAr[1]), nnParams = NNParams)
  model = modelTrain!(model, freqAr, nnParams = NNParams)

  ################################################################################

  # calculate post autoencoder
  postAr = cpu(model).(freqAr)

  # autoencoder error
  aErr = reshifter(postAr - freqAr) |> π -> flatten(π) |> π -> permutedims(π)

    ################################################################################

    begin
      @info "Creating Hidden Markov Model..."

      # setup
      hmm = setup(aErr)

      # process
      for _ ∈ 1:4
        process!(hmm, aErr, true, params = hmmParams)
      end

      # final
      for _ ∈ 1:2
        process!(hmm, aErr, false, params = hmmParams)
      end

      # record hidden Markov model
      hmmDc[κ] = hmm
    end

    ################################################################################

  end

  println()

end;

################################################################################

# write traceback & states
writeHMM(hmmDc, shArgs)

################################################################################

if haskey(annotFile, replace(shArgs["file"], ".edf" => ""))

  writedlm(string(shArgs["outscreen"], replace(shArgs["file"], "edf" => "csv")), writePerformance(sensitivitySpecificity(hmmDc, labelAr)), ", ")

  ################################################################################

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs, labelAr)

else

  # # graphic rendering
  # mindGraphics(hmmDc, shArgs)

end

################################################################################

# end

################################################################################
