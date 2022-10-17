####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
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
df = DataFrame(record = String[], samples = Int64[])

# list directories
timeList = readdir(string(mindData, "/", "time"))

# iterate on times
for tim ∈ timeList

  # read time
  mt = readdlm(string(mindData, "/", "time", "/", tim))

  # append rows
  push!(df, [replace(tim, ".txt" => ""), mt[1, 1]])

end

# write dataframe
writedf(string(mindData, "/", "summary", "/", "time", ".csv"), df; sep = ',')

####################################################################################################
