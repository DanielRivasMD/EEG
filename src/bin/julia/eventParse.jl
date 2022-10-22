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
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
  include(string(configDir, "/timeThresholds.jl"))
end;

####################################################################################################

# iterate on directories
for timeThres ∈ timeThresholds

  # declare collected dataframe
  collectDf = DataFrame(Subject = String[], Record = String[], Detected = Int[], peak_no = Float64[], lower_lim_ix = Float64[], upper_lim_ix = Float64[], peak_length_ix = Float64[])

  # list records
  csvList = readdir(string(mindData, "/", "event", "/", timeThres))

  # iterate on files
  for csv ∈ csvList

    # extract subject
    subj = @chain csv begin
      replace.(".csv" => "")
      replace.(r"_\d\d" => "")
      replace.("a" => "")
      replace.("b" => "")
      replace.("c" => "")
      replace.("h" => "")
      replace.("_" => "")
      replace.("+" => "")
      string("chb", _)
    end

    # read csv file
    df = CSV.read(string(mindData, "/", "event", "/", timeThres, "/", csv), DataFrame)

    # read files with annotations
    if size(df, 1) > 0

      # collected detection
      # peak detection only contains 4 fields
      det = map(sum, eachrow(df[:, 5:end]))

      for ι ∈ axes(df, 1)
        push!(collectDf, [subj; replace(csv, ".csv" => ""); det[ι] > 0; [df[ι, ο] for ο ∈ 1:4]])
      end

    end

  end

  # write dataframe
  writedf(string(mindData, "/", "recall", "/", "filter", timeThres, ".csv"), collectDf; sep = ',')

end

####################################################################################################
