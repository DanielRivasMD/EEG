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

# declare artificial state
artificialState = 10.

if monochromatic == true

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

# assign axes labels
ξ1 = CairoMakie.Axis(
  φ[1, 1],
  title = "Heatmap representing all channels during length of recording",
  xticks = (extractPoints ./ collapseFactor, repeat([""], length(extractPoints))),
  yticks = ([1], [names(df)[end]]),
)

# assign axes labels
ξ2 = CairoMakie.Axis(
  φ[2, 1],
  yticks = (1:size(df, 2), names(df)),
  xticks = (extractPoints ./ collapseFactor, repeat([""], length(extractPoints))),
  xlabel = "Time along EEG recording",
)


# spacing multipler
spx = 20

# plot heatmap
φ = Figure()

# declare grid
γ = φ[1, 1] = GridLayout()

# panel layout
α = [MakieLayout.Axis(γ[row, col]) for row ∈ 1:2, col ∈ 1:1]

# # hide decorations
# hidedecorations!(α[1, 1])

# ticks
α[1, 1].yticks = ([1], [names(df)[end]])
α[1, 1].xticks = ([], [])
α[2, 1].yticks = (1:size(df, 2), names(df))
α[2, 1].xticks = (extractPoints ./ collapseFactor, repeat([""], length(extractPoints)))

# panel title
Label(γ[1, :, Top()], "Heatmap representing all channels during length of recording", valign = :bottom)

# plot annotations
heatmap!(
  α[1, 1],
  df|> Matrix |> π -> imresize(π, (Int(size(df, 1) / collapseFactor), size(df, 2))) |> π -> π[:, end] |> π -> reshape(π, (length(π), 1)),
  colormap = warmPalette[[1, end]],
)

# plot matrix
heatmap!(
  α[2, 1],
  df[:, Not(end)] |> Matrix |> π -> imresize(π, (Int(size(df, 1) / collapseFactor), size(df, 2) - 1)),
  colormap = warmPalette,
)

# row sizes
rowsize!(γ, 1, 1 * spx)
rowsize!(γ, 2, 22 * spx)

# row gap
rowgap!(γ, 0 * spx)

# save figure
save(string(mindHeatmap, "/", record, "_", timeThres, ".svg"), φ)

####################################################################################################
