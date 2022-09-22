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
  filter(χ -> !contains(χ, "_VNS_"), _)
  filter(χ -> !contains(χ, "_-_"), _)
  filter(χ -> !contains(χ, "_._"), _)
  replace.(annot => "")
  replace.(r"_\d\d" => "")
  replace.("model.csv" => "")
  replace.("_" => "")
  replace.("+" => "")
  unique(_)
end

####################################################################################################

# declare master datatypes
msLabelAr = Vector{Int64}(undef, 0)
msHmmDc = Dict{String, HMM}(χ => HMM(Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Int64}(undef, 0)) for χ = channels)

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
  for κ ∈ channels
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
  writeHMM(string(mindHMM, "/", annot, "_", κ, "_traceback", ".csv"), υ.traceback, κ)
end

# write concatenated labels
CSV.write(string(mindLabel, "/", annot, ".csv"), Tables.table(msLabelAr, header = [annot]))

####################################################################################################

# measure performance
writedlm(
  string(shArgs["outDir"], "/", "screen/", replace(shArgs["annotation"], "-summary.txt" => ".csv")),
  writePerformance(sensitivitySpecificity(msHmmDc, msLabelAr)),
  ", ",
)

####################################################################################################
