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
  include(string(configDir, "/timeThresholds.jl"))
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
      R" labelDf <- peakIden($labelAr, 1) "
      @rget labelDf

    end;

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
      R" peakDf <- peakIden($tb, 2) "
      @rget peakDf

      # reset traceback
      υ.traceback = ones(Int, υ.traceback |> length)

      # apply filter
      if timeThres >= 0

        # assign peak values
        for ρ ∈ eachrow(filter(:peakLengthIx => χ -> χ >= timeThres, peakDf))
          υ.traceback[Int(ρ[:lowerLimIx]):Int(ρ[:upperLimIx])] .= artificialState
        end

      elseif timeThres < 0

        # assign peak values
        for ρ ∈ eachrow(filter(:peakLengthIx => χ -> χ <= abs(timeThres), peakDf))
          υ.traceback[Int(ρ[:lowerLimIx]):Int(ρ[:upperLimIx])] .= artificialState
        end

      end

      # preallocate temporary values
      overs = zeros(Int, size(labelDf, 1))

      # true positive counter
      tp = 0

      # false positive counter
      fp = 0

      # iterate on annotations
      for (ι, ρ) ∈ enumerate(eachrow(labelDf))

        # extract subset
        subVc = υ.traceback[Int(ρ[:lowerLimIx]):Int(ρ[:upperLimIx])]

        # identify peak overlaps
        R" subDf <- peakIden($subVc, $artificialState) "
        @rget subDf

        # score overlaps
        if size(subDf, 1) > 0
          overs[ι] += 1
        end

        # update true positive counter
        tp += size(subDf, 1)

        # update false positive counter
        if size(subDf, 1) > 1
          fp += size(subDf, 1) - 1
        end

      end

      # collect identification record
      labelDf[!, κ] .= overs

      # adjust counts
      begin

        # positive counts
        adPos = size(peakDf, 1)

        # negative counts
        st = 0
        ed = 0
        if peakDf[1, :lowerLimIx] != 1 st = 1 end
        if peakDf[end, :upperLimIx] == length(tb) ed = 1 end
        adNeg = (size(peakDf, 1) - st - ed)

      end;

      # build confusion matrix
      cnMt = [tp (adPos - tp); fp (adNeg - fp)]

      # write confusion matrix
      writedlm(
        string(shArgs["outDir"], "/", "confusionMt", "/", "channel", "/", timeThres, "/", "event", "_", edf, "_", κ, ".csv"),
        cnMt,
        ",",
      )

    end

    ####################################################################################################

    # write label & identification
    writedf(
      string(shArgs["outDir"], "/", "event", "/", timeThres, "/", replace(ƒ, "edf" => "csv")),
      labelDf;
      sep = ',',
    )

    ####################################################################################################

  end

end

####################################################################################################
