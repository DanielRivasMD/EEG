####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  # dependencies
  using CSV
  using DataFrames
  using DelimitedFiles
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

  # read dataframe
  df = readdf(string(mindData, "/", "recall", "/", "filter", tier, ".csv"); sep = ',')

  if tier == rocList[1]

    # group by existing records
    eventRecords = groupby(df, :Record) |> length

    # write number of records
    writedlm(
      string(mindData, "/", "summary", "/", "eventRecords", ".csv"),
      eventRecords,
      ",",
    )

  end

  # add total count
  df[!, :Total] .= 1

  # collect results
  gdf = @chain df begin
    groupby(_, :Subject)
    combine(:Detected => sum => :Detected, :Total => sum => :Total)
  end

  # summarize all subjects
  push!(gdf, ("Total", sum(gdf[:, :Detected]), sum(gdf[:, :Total])))

  # calculate percentage
  gdf[!, :Percentage] .= gdf[:, :Detected] ./ gdf[:, :Total]

  # write dataframe
  writedf(string(mindData, "/", "summary", "/", "precision", tier, ".csv"), gdf; sep = ',')

end

####################################################################################################
