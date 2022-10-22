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
  collectDf = DataFrame(Record = String[], Detected = Int[], peak_no = Float64[], lower_lim_ix = Float64[], upper_lim_ix = Float64[], peak_length_ix = Float64[])

  # list records
  csvList = readdir(string(mindData, "/", "event", "/", tier))

  # iterate on files
  for csv ∈ csvList

    # read csv file
    df = CSV.read(string(mindData, "/", "event", "/", tier, "/", csv), DataFrame)

    # read files with annotations
    if size(df, 1) > 0

      # collected detection
      # peak detection only contains 4 fields
      det = map(sum, eachrow(df[:, 5:end]))

      for ι ∈ axes(df, 1)
        push!(collectDf, [replace(csv, ".csv" => ""); det[ι] > 0; [df[ι, ο] for ο ∈ 1:4]])
      end

    end

  end

  # write dataframe
  writedf(string(mindData, "/", "recall", "/", "filter", tier, ".csv"), collectDf; sep = ',')

end

####################################################################################################
