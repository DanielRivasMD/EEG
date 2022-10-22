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

# declare artificial state
artificialState = 10

# since sample per record = 256, window size = 256, & overlap = 4
# then each bin represents 1 second of recording with 1 quarter of second offset
# declare time threshold
timeThresholds = [120, 100, 80, 60, 40, 20, 0]

####################################################################################################

# iterate on file vector
for ƒ ∈ shArgs["input"]

  # log
  @info ƒ

  ####################################################################################################

  # trim file extension
  edf = replace(ƒ, ".edf" => "")

  # read available channels
  channels = @chain begin
    readdir(mindHMM)
    filter(χ -> contains(χ, edf), _)
    filter(χ -> contains(χ, "traceback"), _)
    filter(χ -> !contains(χ, "VNS"), _)
    filter(χ -> !contains(χ, "EKG"), _)
    filter(χ -> !contains(χ, "LOC"), _)
    filter(χ -> !contains(χ, "LUE"), _)
    filter(χ -> !contains(χ, "_-_"), _)
    filter(χ -> !contains(χ, "_._"), _)
    replace.(edf => "")
    replace.(r"_\d\d" => "")
    replace.("traceback.csv" => "")
    replace.("a" => "")
    replace.("b" => "")
    replace.("c" => "")
    replace.("_" => "")
    replace.("+" => "")
    unique(_)
  end

  ####################################################################################################

  # iterate on thresholds
  for timeThres ∈ timeThresholds

    ####################################################################################################

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
        ) .|> Int
      # declare an empty vector
      else
        labelAr = zeros(Int, convert.(Int, size(edfDf, 1) / (shArgs["window-size"] / shArgs["bin-overlap"])))
      end

      # identify peak
      R" labelDf <- peak_iden($labelAr, 1) "
      @rget labelDf

    end;

    ####################################################################################################

    # preallocate dataframe
    df = DataFrame(Electrode = String[], TP = Int64[], FP = Int64[])

    ####################################################################################################

    # load manually. catch non-present files
    hmmDc = Dict{String, HMM}()
    try
      hmmDc = reconstructHMM(string(mindHMM, "/"), edf, channels)
    catch
      @warn "$(edf) file does not exist"
    end

    ####################################################################################################

    # iterate on dictionary
    for (κ, υ) ∈ hmmDc

      # declare traceback
      tb = υ.traceback

      # identify peak
      R" peakDf <- peak_iden($tb, 2) "
      @rget peakDf

      # reset traceback
      υ.traceback = ones(Int, υ.traceback |> length)

      # assign peak values
      for ρ ∈ eachrow(filter(:peak_length_ix => χ -> χ >= timeThres, peakDf))
        υ.traceback[Int(ρ[:lower_lim_ix]):Int(ρ[:upper_lim_ix])] .= artificialState
      end

      # preallocate temporary values
      tp = zeros(Int, size(labelDf, 1))

      # iterate on annotations
      for (ι, ρ) ∈ enumerate(eachrow(labelDf))

        # extract subset
        subVc = υ.traceback[Int(ρ[:lower_lim_ix]):Int(ρ[:upper_lim_ix])]

        # identify peak overlaps
        R" subDf <- peak_iden($subVc, $artificialState) "
        @rget subDf

        # score overlaps
        if size(subDf, 1) > 0
          tp[ι] += 1
        end

      end

      # collect identification record
      labelDf[!, κ] = tp

      # append dataframe
      push!(df, (κ, sum(tp), size(labelDf, 1) - sum(tp)))

    end

    ####################################################################################################

    # calculate recall
    df[:, :Recall] .= df[:, :TP] ./ (df[:, :TP] + df[:, :FP])

    ####################################################################################################

    # write label & identification
    writedf(
      string(shArgs["outDir"], "/", "event", "/", timeThres, "/", replace(ƒ, "edf" => "csv")),
      labelDf;
      sep = ',',
    )

    ####################################################################################################

    # write precision
    writedf(
      string(shArgs["outDir"], "/", "precision", "/", timeThres, "/", replace(ƒ, "edf" => "csv")),
      df;
      sep = ',',
    )

    ####################################################################################################

  end

end

####################################################################################################