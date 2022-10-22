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
rocList = readdir(string(mindROC))

# iterate on directories
for tier ∈ rocList

  # iterate on performance
  for Π ∈ performance

    # declare symbols
    Df = Symbol(Π, "Df")

    # declare collected dataframe
    @eval $Df = DataFrame(Electrode = String[])

    # list records
    csvList = readdir(string(mindROC, "/", tier))

    # iterate on files
    for csv ∈ csvList

      # read csv file
      df = CSV.read(string(mindROC, "/", tier, "/", csv), DataFrame)

      # remove missing rows by index
      df = df[Not(ismissing.(df[:, :Electrode])), :]

      # join dataframes
      @eval global $Df = outerjoin($Df, $df[:, ["Electrode", $(string(Π))]]; on = :Electrode)
      @eval rename!($Df, $(string(Π)) => Symbol(replace($csv, ".csv" => "")))

    end

    # write dataframe
    @eval dir = $(string(Π)) |> lowercase
    @eval writedf(string(mindData, "/", dir, "/", "filter", $tier, ".csv"), $Df; sep = ',')

  end

end

####################################################################################################
