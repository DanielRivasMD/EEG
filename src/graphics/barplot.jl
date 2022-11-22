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

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(configDir, "/", "timeThresholds.jl"))
end;

####################################################################################################

# time threshold
timeThres = timeThresholds[1]

# read dataframe
df = readdf(string(mindData, "/", "summary", "/", "electrodePercentage", timeThres, ".csv"); sep = ',')

# total events
totev = sum(df[:, :Count])

####################################################################################################

# plot signals
φ = Figure()

# assign axes labels
ξ = CairoMakie.Axis(
  φ[1, 1],
  title = "Number of events detected per channel",
  ylabel = "Percentage of total events",
  xlabel = "Percentage of channels event is detected on",
  yticks = ((totev / 4) * [0:4...], ["0 %", "25 %", "50 %", "75 %", "100 %"]),
  xticks = (1:12, string.(df[:, :RangeS] .* 100, " %", " - ", df[:, :RangeE] .* 100, " %")),
  xticklabelrotation = 45.,
)

# barplot
barplot!(ξ, df[:, :Count], color = df[:, :Percentage], strokecolor = :black, strokewidth = 1)

# limits
ylims!(ξ, (0, totev))

# save figure
save(string(dataDir, "/", "ensemble", "Barplot", ".svg"), φ)

####################################################################################################
