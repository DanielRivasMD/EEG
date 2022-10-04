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

# declare collected dataframe
sensDf = DataFrame(Electrode = String[])

# list directories
rocList = readdir(string(mindROC))

# # iterate on directories
# for tier ∈ rocList

  # list records
  csvList = readdir(string(mindROC, "/", tier))

  # iterate on files
  for csv ∈ csvList

    # read csv file
    df = CSV.read(string(mindROC, "/", tier, "/", csv), DataFrame)

    # remove missing rows by index
    df = df[Not(ismissing.(df[:, :Electrode])), :]

    # join dataframes
    global sensDf = outerjoin(sensDf, df[:, [:Electrode, :Sensitivity]]; on = :Electrode)
    rename!(sensDf, :Sensitivity => Symbol(replace(csv, ".csv" => "")))

  end
# end

####################################################################################################
