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
  include(string(utilDir, "/ioDataFrame.jl"))
  include(string(annotationDir, "/functions/annotationCalibrator.jl"))
end;

####################################################################################################

# declare recording
record = "chb12_27"
subject = "chb12"

####################################################################################################

# read edf file
edfDf, startTime, recordFreq = getSignals(string(dataDir, "/", record, ".edf"))

####################################################################################################

# read annotation
annotFile = annotationReader(string(dataDir, "/"), string(subject, "-summary.txt"))

####################################################################################################

# calibrate annotations
labelDf = annotationCalibrator(
  annotFile[record];
  recordFreq = recordFreq,
  signalLength = size(edfDf, 1),
  shParams = Dict("window-size" => 256, "bin-overlap" => 4),
) |> π -> DataFrame(Annotation = π)

####################################################################################################

# identify files to load
states = @chain begin
  readdir(mindHMM)
  filter(χ -> occursin(record, χ), _)
  filter(χ -> occursin("traceback", χ), _)
end

####################################################################################################

# read files into dataframe array & concatenate
df = [readdf(string(mindHMM, "/", ι); sep = ',') for ι ∈ states]
df = hcat(labelDf, df...)

####################################################################################################

# write dataframe
writedf(string(mindCSV, "/", record, ".csv"), df; sep = ',')

####################################################################################################

# load peak identification function
R" source(paste0($utilDir, '/peakIden.R')) "

####################################################################################################

# declare artificial state
artificialState = 10.

# since sample per record = 256, window size = 256, & overlap = 4
# then each bin represents 1 second of recording with 1 quarter of second offset
# declare time threshold
timeThres = 120

# apply filter
for ι ∈ axes(df, 2)

  # preserve annotation
  if ι == 1 continue end

  # declare traceback
  ψ = df[:, ι]

  # identify peak
  R" peakDf <- peak_iden($ψ, 2) "
  @rget peakDf

  # reset traceback
  df[!, ι] = ones(size(df, 1))

  # assign peak values
  for ρ ∈ eachrow(filter(:peak_length_ix => χ -> χ >= timeThres, peakDf))
    df[Int(ρ[:lower_lim_ix]):Int(ρ[:upper_lim_ix]), ι] .= artificialState
  end

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
save(string(mindPlot, "/", record, ".svg"), φ)

####################################################################################################
