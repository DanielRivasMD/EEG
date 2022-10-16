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

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) ";

####################################################################################################

# declare artificial state
artificialState = 10.

# since sample per record = 256, window size = 256, & overlap = 4
# then each bin represents 1 second of recording with 1 quarter of second offset
# declare time threshold
timeThresholds = [120, 100, 80, 60, 40, 20, 0]

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
      string(shArgs["outDir"], "/", "roc/", timeThres, "/", summary, "_", montageSt, ".csv"),
      writePerformance(sensitivitySpecificity(msHmmDc, maskDc, msLabelAr)),
      ",",
    )

    ####################################################################################################

  end

end

####################################################################################################
