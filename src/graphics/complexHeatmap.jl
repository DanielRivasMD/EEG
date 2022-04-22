################################################################################

# declarations
begin
  include( "/Users/drivas/Factorem/EEG/src/config/config.jl" )
end;

################################################################################

# load project enviroment
using Pkg
if Pkg.project().path != string( projDir, "/Project.toml" )
  Pkg.activate(projDir)
end

################################################################################

# load packages
begin
  # Makie
  using CairoMakie
end;

################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
end;

################################################################################

# identify files to load
states = @chain begin
  readdir(mindHMM)
  filter(χ -> occursin("chb04_28", χ) && occursin("states", χ), _)
end

################################################################################

# read files into dataframe array & concatenate
df = [readdf(string(mindHMM, "/", ι), ',') for ι ∈ states]
df = hcat(df...)

################################################################################

# write dataframe
writedf(string(mindCSV, "/chb04_28.csv"), df, ',')

################################################################################

# plot heatmap
φ = Figure()

# assign axes labels
ξ = Axis(
  φ[1, 1],
  title = "Heatmap representing all channels during length of recording",
  xlabel = "Time along EEG recording",
  yticks = (1:size(df, 2), df |> names),
)

# plot matrix
heatmap!(
  ξ,
  df |> Matrix,
  colormap = :cherry,
)

# save figure
save(string(mindPlot, "/chb04_28.svg"), φ)

################################################################################
