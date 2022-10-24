####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  # dependencies
  using DataFrames

  # Makie
  using CairoMakie
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
  include(string(configDir, "/timeThresholds.jl"))
end;

####################################################################################################

"wrapper over Makie scatter"
function renderROC(df, out)

  # declare figure
  φ = Figure()

  # customize layout
  gl = φ[1, 1] = GridLayout()
  render = MakieLayout.Axis(
    gl[1, 1],
    title = "Receiver Operating Characteristic (ROC) curve",
    xlabel = "False Positive Rate",
    ylabel = "True Positive Rate",
    xticks = (0:0.2:1, string.(0:20:100, "%")),
    yticks = (0:0.2:1, string.(0:20:100, "%")),
  )

  # render points
  scatter!(render, 1 .- df[:, :Specificity], df[:, :Sensitivity], color = :blue)

  # render lines
  lines!(render, [0; 1 .- df[:, :Specificity]; 1], [0; df[:, :Sensitivity]; 1], color = :red)

  # limits
  xlims!(render, (0, 1))
  ylims!(render, (0, 1))

  # save figure
  save(out, φ)

end

####################################################################################################

# load dataset
df = readdf(string(mindData, "/", "summary", "/", "dataset", ".csv"), sep = ',')

# plot
renderROC(df, string(mindPlot, "/", "dataset", ".png"))

####################################################################################################
