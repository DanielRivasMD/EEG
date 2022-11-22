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
end;

####################################################################################################

# defined arbitrary extract points
# record:     chb04_28
# event 1)    6713  : 7128
# event 2)    15125 : 15596
extractPoints = [7000, 15550, 25000, 43530]

# plot window
plotWindow = 500

# y axis offset
yOffset = 25

####################################################################################################

# declare variables
begin
  # window parameters
  sizeW = 256
  overW = 4

  # subject
  subject = "chb04"

  # recording
  record = "chb04_28"
end;

####################################################################################################

# read edf file
edfDf, _, _ = getSignals(string(database, "/", subject, "/", record, ".edf"))

####################################################################################################

# declare files to load manually
include(string(configDir, "/", "electrodeDisplay.jl"))

####################################################################################################

# iterate on extract points
for (ι, υ) ∈ enumerate(extractPoints)

  ####################################################################################################

  # first signal plot
  startIx = extractPoints[ι] - plotWindow

  # extract matrix
  toPlot = edfDf[startIx:(startIx + plotWindow), electrodeDisplay]

  # plot signals
  φ = Figure()

  # assign axes labels
  ξ = CairoMakie.Axis(
    φ[1, 1],
    title = "Sample raw signal",
    yticks = (range(start = round(yOffset / 2), step = yOffset, length = size(toPlot, 2)), toPlot |> names),
    xticksvisible = false,
    xticklabelsvisible = false,
)

  # plot matrix
  for ο ∈ axes(toPlot, 2)
    lines!(ξ, 1:size(toPlot, 1), toPlot[:, ο] .+ (ο * yOffset), color = "black")
  end

  # save figure
  save(string(dataDir, "/", "signal", "_", record, "_", υ, ".svg"), φ)

  ####################################################################################################

end

####################################################################################################
