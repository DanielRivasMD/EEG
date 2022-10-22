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
  include(string(utilDir, "/montage.jl"))
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

    # preallocate maximum vector
    mxHmm = zeros(Int, msHmmDc |> keys .|> string |> π -> getindex(π, 1) |> π -> msHmmDc[π].traceback |> length)

    ####################################################################################################

    # preallocate mask
    maskDc = Dict{String, Vector{Int}}()

    ####################################################################################################

    # create output dataframe with zero values
    df = DataFrame(Electrode = String[], TP = Int64[], FP = Int64[])

    ####################################################################################################

    # iterate on dictionary
    for (κ, υ) ∈ msHmmDc

      # preallocate temporary values
      tp = 0
      fp = 0

      # load maximum vector
      mxHmm += υ.traceback

      # collect masks
      maskDc[κ] = findall(χ -> χ == -1, υ.traceback)

      # keep mask footprint
      mxHmm[maskDc[κ]] .= -1

      # redeclare traceback & label array
      tb = υ.traceback[1:end .∉ [maskDc[κ]]]
      lb = msLabelAr[1:end .∉ [maskDc[κ]]]

      # identify peak
      R" peakDf <- peak_iden($lb, 1) "
      @rget peakDf

      # iterate on peaks
      for ρ ∈ eachrow(peakDf)

        # collect calls
        if sum(tb[convert(Int, ρ.lower_lim_ix):convert(Int, ρ.upper_lim_ix)] .> 1) > 1
          tp += 1
        else
          fp += 1
        end

      end

      # assign dataframe row
      push!(df, (κ, tp, fp))

    end

    ####################################################################################################

    # preallocate temporary values
    tp = 0
    fp = 0

    # redeclare maximum traceback
    tb = mxHmm[1:end .∉ [findall(χ -> χ == -1, mxHmm)]]
    lb = msLabelAr[1:end .∉ [findall(χ -> χ == -1, mxHmm)]]

    # identify peak
    R" peakDf <- peak_iden($lb, 1) "
    @rget peakDf

    # iterate on peaks
    for ρ ∈ eachrow(peakDf)

      # collect calls
      if sum(tb[convert(Int, ρ.lower_lim_ix):convert(Int, ρ.upper_lim_ix)] .> 1) > 1
        tp += 1
      else
        fp += 1
      end

    end

    # assign dataframe row
    push!(df, ("Maximum", tp, fp))

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
