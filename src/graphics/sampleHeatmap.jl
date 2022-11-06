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

  # dependencies
  using ImageTransformations
  using RCall

  # Makie
  using CairoMakie
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(annotationDir, "/", "functions", "/", "annotationCalibrator.jl"))
end;

####################################################################################################

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) ";

####################################################################################################

# declare variables
sizeW = 256
overW = 4

# subjects
subjectList = string.("chb", string.(1:24, pad = 2))

####################################################################################################

# iterate on subjects
for subject ∈ subjectList

  # log
  @info subject

  ####################################################################################################

  # read annotation
  annotFile = annotationReader(string(dataDir, "/"), string(subject, "-summary.txt"))

  # select subject files
  recordList = @chain begin
    readdir(string(database, "/", subject))
    filter(χ -> contains(χ, r"edf$"), _)
    replace.(".edf" => "")
  end

  # iterate on records
  for record ∈ recordList

    # log
    @info record

    ####################################################################################################

    # read edf file
    edfDf, startTime, recordFreq = getSignals(string(database, "/", subject, "/", record, ".edf"))

    ####################################################################################################

    # calibrate annotations
    if haskey(annotFile, record)
      labelDf = annotationCalibrator(
        annotFile[record];
        recordFreq = recordFreq,
        signalLength = size(edfDf, 1),
        shParams = Dict("window-size" => sizeW, "bin-overlap" => overW),
      ) |> π -> DataFrame(Annotation = π)
    # declare an empty vector
    else
      labelDf = zeros(Int, convert.(Int, size(edfDf, 1) / (sizeW / overW))) |> π -> DataFrame(Annotation = π)
    end

    ####################################################################################################

    # identify files to load
    states = @chain begin
      readdir(mindHMM)
      filter(χ -> contains(χ, record), _)
      filter(χ -> contains(χ, "traceback"), _)
      filter(χ -> !contains(χ, "VNS"), _)
      filter(χ -> !contains(χ, "EKG"), _)
      filter(χ -> !contains(χ, "LOC"), _)
      filter(χ -> !contains(χ, "LUE"), _)
      filter(χ -> !contains(χ, "_-_"), _)
      filter(χ -> !contains(χ, "_._"), _)
      replace.(record => "")
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

    # read files into dataframe array & concatenate
    df = [readdf(string(mindHMM, "/", record, "_", ι, "_", "traceback", ".csv"); sep = ',') for ι ∈ states]
    df = hcat(df..., labelDf)

    ####################################################################################################

    # write dataframe
    writedf(string(mindCSV, "/", record, ".csv"), df; sep = ',')

    ####################################################################################################

    if monochromatic == true

      # declare artificial state
      artificialState = 10.

      # apply filter
      for ι ∈ axes(df, 2)

        # preserve annotation filtering & adjust values
        if ι == size(df, 2)
          df[df[:, :Annotation] .== 1, ι] .= artificialState
          df[df[:, :Annotation] .== 0, ι] .+= 1
          continue
        end

        # declare traceback
        ψ = df[:, ι]

        # identify peak
        R" peakDf <- peakIden($ψ, 2) "
        @rget peakDf

        # reset traceback
        df[!, ι] = ones(size(df, 1))

        # assign peak values
        for ρ ∈ eachrow(filter(:peakLengthIx => χ -> χ >= timeThres, peakDf))
          df[Int(ρ[:lowerLimIx]):Int(ρ[:upperLimIx]), ι] .= artificialState
        end

      end

    else

      # recalibrate annotation values
      df[!, :Annotation] .+= 1

    end

    ####################################################################################################

    # plot heatmap
    φ = Figure()

    # assign axes labels
    ξ = CairoMakie.Axis(
      φ[1, 1],
      title = "Heatmap representing all channels during length of recording",
      xlabel = "Time along EEG recording",
      yticks = (1:size(df, 2), df |> names),
      xticksvisible = false,
      xticklabelsvisible = false,
    )

    # plot matrix
    heatmap!(
      ξ,
      df |> Matrix |> π -> imresize(π, (Int(size(df, 1) / 4), size(df, 2))),
      colormap = ["#ffffff", "#ff0000"],
    )

    # save figure
    save(string(mindHeatmap, "/", record, "_", timeThres, ".svg"), φ)

    ####################################################################################################

  end

end

####################################################################################################

# # interactive annotations
# annot = df[:, :Annotation]
# R" peakDf <- peakIden($annot, 2) ";
# @rget peakDf

# # iterate on peaks
# for ρ ∈ eachrow(peakDf)
#   @info ((map(sum, eachrow(df[Int(ρ.lowerLimIx):Int(ρ.upperLimIx), 1:end - 1])) ./ (size(df, 2) - 1)) |> sum) ./ ρ.peakLengthIx
# end

####################################################################################################
