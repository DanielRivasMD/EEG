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

# list directories
rocList = readdir(string(mindData, "/", "event"))

# iterate on directories
for tier ∈ rocList

  # declare collected dataframe
  Df = DataFrame(Electrode = String[])

  # list records
  csvList = readdir(string(mindData, "/", "event", "/", tier))

  # iterate on files
  for csv ∈ csvList

    # read csv file
    df = CSV.read(string(mindData, "/", "event", "/", tier, "/", csv), DataFrame)

    # remove missing rows by index
    df = df[Not(ismissing.(df[:, :Electrode])), :]

    # join dataframes
    global Df = outerjoin(Df, df[:, [:Electrode, :Recall]]; on = :Electrode)
    rename!(Df, :Recall) => replace(csv, ".csv" => "")

  end

  # write dataframe
  writedf(string(mindData, "/", "recall", "/", "filter", tier, ".csv"), Df, ',')

end

####################################################################################################
