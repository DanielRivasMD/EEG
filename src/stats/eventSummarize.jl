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

# list directories
rocList = readdir(string(mindData, "/", "event"))

# iterate on directories
for tier ∈ rocList

  # log
  @info tier

  # read dataframe
  df = readdf(string(mindData, "/", "recall", "/", "filter", tier, ".csv"); sep = ',')

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

  # supress missing column
  Df = Df[:, Not(:nmissing)]

  # log
  @info describe(Df)
  @info Df

  # write dataframe
  writedf(string(mindData, "/", "summary", "/", "recall", tier, ".csv"), Df; sep = ',')

end

####################################################################################################
