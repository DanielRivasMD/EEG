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
  using DataFrames
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
  include(string(utilDir, "/ioDataFrame.jl"))
end;

####################################################################################################

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) ";

####################################################################################################

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

  # load hidden Markov model
  msHmmDc = Dict{String, HMM}()
  for κ ∈ @eval $montage
    msHmmDc[κ] = HMM([zeros(0)], [zeros(0)], HiddenMarkovModelReaders.readHMMtraceback(string(mindHMM, "/"), string(summary, "_", κ, "_", montageSt)))
  end

  ####################################################################################################

  # identify peak
  R" peakDf <- peak_iden($msLabelAr, 1) "
  @rget peakDf

  ####################################################################################################

  # iterate on thresholds
  for timeThres ∈ timeThresholds

    ####################################################################################################

    # create output dataframe with zero values
    df = DataFrame(Electrode = String[], TP = Int64[], FP = Int64[])

    ####################################################################################################

    # iterate on dictionary
    for (κ, υ) ∈ msHmmDc

      # preallocate temporary values
      tp = 0
      fp = 0

      # iterate on peaks
      for ρ ∈ eachrow(peakDf)

        # collect calls
        if sum(υ.traceback[convert(Int, ρ.lower_lim_ix):convert(Int, ρ.upper_lim_ix)] .> 1) > 1
          tp += 1
        else
          fp += 1
        end

      end

      # assign dataframe row
      push!(df, (κ, tp, fp))

    end

    ####################################################################################################

    # calculate recall
    df[:, :Recall] .= df[:, :TP] ./ (df[:, :TP] + df[:, :FP])

    ####################################################################################################

    # measure performance
    writedf(
      string(shArgs["outDir"], "/", "event", "/", timeThres, "/", summary, "_", montageSt, ".csv"),
      df;
      sep = ',',
    )

    ####################################################################################################

  end

end

####################################################################################################
