####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  # dependencies
  using CSV
  using DataFrames

  # Makie
  using CairoMakie
end;

####################################################################################################

# load modules
begin
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

  # render image
  scatter!(render, 1 .- df[:, :Specificity], df[:, :Sensitivity])

  # limits
  xlims!(render, (0, 1))
  ylims!(render, (0, 1))

  # save figure
  save(out, φ)

end

####################################################################################################

# iterate on directories
for timeThres ∈ timeThresholds

  # list records
  csvList = readdir(string(mindROC, "/", timeThres))

  # iterate on files
  for csv ∈ csvList

    # read csv file
    df = CSV.read(string(mindROC, "/", timeThres, "/", csv), DataFrame)

    # plot
    renderROC(df, string(mindPlot, "/", timeThres, "/", replace(csv, ".csv" => ""), ".png"))

  end
end

####################################################################################################
