####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  # MindReader
  using MindReader

  # Makie
  using CairoMakie

  # dependencies
  using ImageTransformations
  using RCall
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(annotationDir, "/", "functions", "/", "annotationCalibrator.jl"))
end;

####################################################################################################

# defined arbitrary extract points
# record:     chb04_28
# event 1)    6713  : 7128
# event 2)    15125 : 15596
extractPoints = [7000, 15550, 25000, 43530]

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) ";

####################################################################################################

# declare variables
begin
  # window parameters
  sizeW = 256
  overW = 4

  # matrix compression
  collapseFactor = 4

  # color palette
  coldPalette = ["#FFFFFF", "#0000FF", "#003FFF", "#007FFF", "#00BFFF", "#00FFFF"]
  warmPalette = ["#FFFFFF", "#FF0000", "#FF3F00", "#FF7F00", "#FFBF00", "#FFFF00", "#8A2BE2"]
  binaryPalatte = ["#FFFFFF", "#FF0000"]
  monochromatic = false

  # since sample per record = 256, window size = 256, & overlap = 4
  # then each bin represents 1 second of recording with 1 quarter of second offset
  # declare time threshold
  timeThres = 0

  # subject
  subject = "chb04"

  # recording
  record = "chb04_28"
end;

####################################################################################################

# read annotation
annotFile = annotationReader(string(dataDir, "/"), string(subject, "-summary.txt"))

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

# declare files to load manually
include(string(configDir, "/", "electrodeDisplay.jl"))

####################################################################################################

# read files into dataframe array & concatenate
df = [readdf(string(mindHMM, "/", record, "_", ι, "_", "traceback", ".csv"); sep = ',') for ι ∈ electrodeDisplay]
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
  df[df[:, :Annotation] .== 1, :Annotation] .= artificialState - 1
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
  xticks = (extractPoints ./ collapseFactor, repeat([""], length(extractPoints))),
)

# plot matrix
heatmap!(
  ξ,
  df |> Matrix |> π -> imresize(π, (Int(size(df, 1) / collapseFactor), size(df, 2))),
  colormap = warmPalette,
)

# save figure
save(string(mindHeatmap, "/", record, "_", timeThres, ".svg"), φ)

####################################################################################################
