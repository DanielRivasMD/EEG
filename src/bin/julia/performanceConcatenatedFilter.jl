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

# read annotation
if haskey(shArgs, "annotation") && haskey(shArgs, "annotDir")
  annotFile = annotationReader(shArgs["annotDir"], shArgs["annotation"])
end

####################################################################################################

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) "

####################################################################################################

# declare artificial state
artificialState = 10.

# since sample per record = 256, window size = 256, & overlap = 4
# then each bin represents 1 second of recording with 1 quarter of second offset
# declare time threshold
timeThresholds = [120, 100, 80, 60, 40, 20, 0]

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
  replace.("a" => "")
  replace.("b" => "")
  replace.("c" => "")
  replace.("_" => "")
  replace.("+" => "")
  unique(_)
end

####################################################################################################

# load labels
msLabelAr = readdlm(string(mindLabel, "/", annot, ".csv"))[2:end] .|> Int

####################################################################################################

# iterate on thresholds
for timeThres ∈ timeThresholds

  ####################################################################################################

  # load hidden Markov model
  msHmmDc = Dict{String, HMM}()
  for κ ∈ channels
    msHmmDc[κ] = HMM([zeros(0)], [zeros(0)], HiddenMarkovModelReaders.readHMMtraceback(string(mindHMM, "/"), string(annot, "_", κ)))
  end

  ####################################################################################################

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
      υ.traceback[Int(ρ[:lower_lim_ix]):Int(ρ[:upper_lim_ix])] .= artificialState
    end

  end

  ####################################################################################################

  # measure performance
  writedlm(
    string(shArgs["outDir"], "/", "roc/", timeThres, "/", replace(shArgs["annotation"], "-summary.txt" => ".csv")),
    writePerformance(sensitivitySpecificity(msHmmDc, msLabelAr)),
    ",",
  )

  ####################################################################################################

end

####################################################################################################
