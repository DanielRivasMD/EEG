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
rocList = readdir(string(mindScreen))

# iterate on directories
for tier ∈ rocList

  # iterate on performance
  for Π ∈ performance

    # declare symbols
    collectDf = Symbol(Π, "Df")

    # declare collected dataframe
    @eval $collectDf = DataFrame(Electrode = String[])

    # list records
    csvList = readdir(string(mindScreen, "/", tier))

    # iterate on files
    for csv ∈ csvList

      # read csv file
      df = CSV.read(string(mindScreen, "/", tier, "/", csv), DataFrame)

      # remove missing rows by index
      df = df[Not(ismissing.(df[:, :Electrode])), :]

      # join dataframes
      @eval global $collectDf = outerjoin($collectDf, $df[:, ["Electrode", $(string(Π))]]; on = :Electrode)
      @eval rename!($collectDf, $(string(Π)) => Symbol(replace($csv, ".csv" => "")))

    end

    # write dataframe
    @eval dir = $(string(Π)) |> lowercase
    @eval writedf(string(mindData, "/", dir, "/", "filter", $tier, ".csv"), $collectDf; sep = ',')

  end

end

####################################################################################################
