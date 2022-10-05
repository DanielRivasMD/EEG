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

  # dependencies
  using CSV
  using DelimitedFiles
  using RCall
  using Tables

  # parameters
  using Parameters: @with_kw
end;

####################################################################################################

# argument parser
include(string(importDir, "/utilitiesJL/argParser.jl"));

####################################################################################################

# split parameter into vector
shArgs["input"] = shArgs["input"] |> π -> split(π, ",") |> π -> π[1:end - 1]

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

# trim file extension
annot = replace(shArgs["annotation"], "-summary.txt" => "")

# read available channels
channels = @chain begin
  readdir(mindHMM)
  filter(χ -> contains(χ, annot), _)
  filter(χ -> contains(χ, "model"), _)
  filter(χ -> !contains(χ, "VNS"), _)
  filter(χ -> !contains(χ, "EKG"), _)
  filter(χ -> !contains(χ, "LOC"), _)
  filter(χ -> !contains(χ, "LUE"), _)
  filter(χ -> !contains(χ, "_-_"), _)
  filter(χ -> !contains(χ, "_._"), _)
  replace.(annot => "")
  replace.(r"_\d\d" => "")
  replace.("model.csv" => "")
  replace.("a" => "")
  replace.("b" => "")
  replace.("c" => "")
  replace.("_" => "")
  replace.("+" => "")
  unique(_)
end

####################################################################################################
# patch patient 12 containing different montages
####################################################################################################

# select unipolar. chb12_28 & chb12_29
unipolar = @chain channels begin
  filter(χ -> !contains(χ, "-"), _)
end

####################################################################################################

# second bipokar set. chb12_27
staticBipolar = ["F7-CS2", "T7-CS2", "P7-CS2", "FP1-CS2", "F3-CS2", "C3-CS2", "P3-CS2", "O1-CS2", "FZ-CS2", "CZ-CS2", "PZ-CS2", "FP2-CS2", "F4-CS2", "C4-CS2", "P4-CS2", "O2-CS2", "F8-CS2", "T8-CS2", "P8-CS2", "C2-CS2", "C6-CS2", "CP2-CS2", "CP4-CS2", "CP6-CS2"]
secBipolar = channels[channels .∈ [staticBipolar]]

####################################################################################################

# reference channels
refChannels = filter(χ -> contains(χ, "Ref"), channels)

####################################################################################################

# patch channels
mainBipolar = channels[channels .∉ [[unipolar; secBipolar; refChannels]]]

####################################################################################################

# montages
montages = [:mainBipolar, :secBipolar, :unipolar, :refChannels]

# iterate on montages
for montage ∈ montages

  # declare variables
  @eval montageSt = $(string(montage))

  @info montageSt

  @eval montageLen = length($montage)

  # check for empty vector
  if montageLen == 0 continue end

  # declare master datatypes
  msLabelAr = Vector{Int64}(undef, 0)
  @eval msHmmDc = Dict{String, HMM}(χ => HMM(Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Int64}(undef, 0)) for χ = $montage)

  ####################################################################################################

  # iterate on file vector
  for ƒ ∈ shArgs["input"]

    # log
    @info ƒ

    ####################################################################################################

    # trim file extension
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

    # load manually. catch non-present files
    hmmDc = Dict{String, HMM}()
    for κ ∈ @eval $montage
      try
        hmmDc[κ] = reconstructHMM(string(mindHMM, "/"), string(edf, "_", κ))
      catch
        hmmDc[κ] = HMM([zeros(0)], [zeros(0)], zeros(Int(size(edfDf, 1) / (shArgs["window-size"] / shArgs["bin-overlap"]))))
      end
    end

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

  # write concatenated traceback
  for (κ, υ) ∈ msHmmDc
    writeHMM(string(mindHMM, "/", annot, "_", κ, "_traceback", "_", montageSt, ".csv"), υ.traceback, κ)
  end

  # write concatenated labels
  CSV.write(string(mindLabel, "/", annot, "_", montageSt, ".csv"), Tables.table(msLabelAr, header = [annot]))

end

####################################################################################################
