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
end

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
    @eval df = readdf(string(mindData, "/", dir, "/", "filter", $tier, ".csv"), ',')

    # log
    @info dir

    # log
    @info describe(Df)
    @info Df

  end

end

####################################################################################################
