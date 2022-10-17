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
  using Statistics
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
end;

####################################################################################################

# performance
performance = [:Sensitivity, :Specificity]

# list directories
rocList = readdir(string(mindROC))

# iterate on directories
for tier ∈ rocList

  # log
  @info tier

  # iterate on performance
  for Π ∈ performance

    # read dataframe
    @eval dir = $(string(Π)) |> lowercase
    @eval df = readdf(string(mindData, "/", dir, "/", "filter", $tier, ".csv"); sep = ',')

    # log
    @info dir

    # patch missing values
    for (ι, ç) ∈ enumerate(eachcol(df))
      df[!, ι] .= replace(ç, "missing" => missing)
    end

    # construct dataframe
    Df = describe(df[:, Not(:Electrode)])

    # calculate standard deviation
    Df[:, :std] .= map(eachcol(df[:, Not(:Electrode)])) do μ
      std(skipmissing(μ))
    end

    # supress type column
    Df = Df[:, Not(:eltype)]

    # log
    @info describe(Df)
    @info Df

    # write dataframe
    @eval dir = $(string(Π)) |> lowercase
    @eval writedf(string(mindData, "/", "summary", "/", dir, $tier, ".csv"), $Df; sep = ',')

  end

end

####################################################################################################
