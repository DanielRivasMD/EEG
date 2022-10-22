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
  using DelimitedFiles
  using DataFrames
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(annotationDir, "/", "functions", "/", "annotationCalibrator.jl"))
end;

####################################################################################################

# create dataframe
df = DataFrame(Subject = String[], Record = String[], Samples = Int64[])

# list directories
timeList = readdir(string(mindData, "/", "time"))

# iterate on times
for tim ∈ timeList

  # extract subject
  subj = @chain tim begin
    replace.(".txt" => "")
    replace.(r"_\d\d" => "")
    replace.("a" => "")
    replace.("b" => "")
    replace.("c" => "")
    replace.("h" => "")
    replace.("_" => "")
    replace.("+" => "")
    string("chb", _)
  end

  # read time
  mt = readdlm(string(mindData, "/", "time", "/", tim))

  # append rows
  push!(df, [subj, replace(tim, ".txt" => ""), mt[1, 1]])

end

# write dataframe
writedf(string(mindData, "/", "summary", "/", "timeRecords", ".csv"), df; sep = ',')

# collect subject times
gdf = @chain df begin
  groupby(_, :Subject)
  combine(:Samples => sum => :Samples)
end

# write dataframe
writedf(string(mindData, "/", "summary", "/", "timeSubjects", ".csv"), gdf; sep = ',')

####################################################################################################
