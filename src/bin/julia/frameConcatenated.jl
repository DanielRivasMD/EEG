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

# load modules
begin
  include(string(utilDir, "/montage.jl"))
  include(string(configDir, "/timeThresholds.jl"))
end;

####################################################################################################

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) ";

####################################################################################################

# declare artificial state
artificialState = 10.

####################################################################################################

# trim file extension
summary = replace(shArgs["input"], "-summary.txt" => "")

# read available channels
channels = @chain begin
  readdir(mindHMM)
  filter(χ -> contains(χ, summary), _)
  filter(χ -> contains(χ, "model"), _)
  filter(χ -> !contains(χ, "VNS"), _)
  filter(χ -> !contains(χ, "EKG"), _)
  filter(χ -> !contains(χ, "LOC"), _)
  filter(χ -> !contains(χ, "LUE"), _)
  filter(χ -> !contains(χ, "_-_"), _)
  filter(χ -> !contains(χ, "_._"), _)
  replace.(summary => "")
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

# identify montage
mainBipolar, secBipolar, unipolar, refChannels = montageIden(channels)

####################################################################################################

# montages
montages = [:mainBipolar, :secBipolar, :unipolar, :refChannels]

# iterate on montages
for montage ∈ montages

  # declare variables
  @eval montageSt = $(string(montage))
  @eval montageLn = length($montage)

  # check for empty vector
  if montageLn == 0 continue end

  # log
  @info montageSt

  # load labels
  msLabelAr = readdlm(string(mindLabel, "/", summary, "_", montageSt, ".csv"))[2:end] .|> Int

  ####################################################################################################

  # iterate on thresholds
  for timeThres ∈ timeThresholds

    ####################################################################################################

    # load hidden Markov model
    msHmmDc = Dict{String, HMM}()
    for κ ∈ @eval $montage
      msHmmDc[κ] = HMM([zeros(0)], [zeros(0)], HiddenMarkovModelReaders.readHMMtraceback(string(mindHMM, "/"), string(summary, "_", κ, "_", montageSt)))
    end

    ####################################################################################################

    # preallocate mask
    maskDc = Dict{String, Vector{Int}}()

    ####################################################################################################

    # iterate on dictionary
    for (κ, υ) ∈ msHmmDc

      # declare traceback
      tb = υ.traceback

      # collect masks
      maskDc[κ] = findall(χ -> χ == -1, tb)

      # identify peak
      R" peakDf <- peakIden($tb, 2) "
      @rget peakDf

      # reset traceback
      υ.traceback = ones(υ.traceback |> length)

      # assign peak values
      for ρ ∈ eachrow(filter(:peakLengthIx => χ -> χ >= timeThres, peakDf))
        υ.traceback[Int(ρ[:lowerLimIx]):Int(ρ[:upperLimIx])] .= artificialState
      end

    end

    ####################################################################################################

    # measure performance
    writedlm(
      string(shArgs["outDir"], "/", "roc/", timeThres, "/", summary, "_", montageSt, ".csv"),
      writePerformance(sensitivitySpecificity(msHmmDc, maskDc, msLabelAr)),
      ",",
    )

    ####################################################################################################

  end

end

####################################################################################################
