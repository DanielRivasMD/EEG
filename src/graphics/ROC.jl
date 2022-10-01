####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using CSV
  using DataFrames

  # Makie
  using CairoMakie
end

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
    xticks = (0:0.1:1, string.(0:10:100, "%")),
    yticks = (0:0.1:1, string.(0:10:100, "%")),
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
