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
  using Statistics
end

####################################################################################################

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(annotationDir, "/", "functions", "/", "annotationCalibrator.jl"))
end;

####################################################################################################

# create dataframe
df = DataFrame(subject = String[], events = Int64[])

# list directories
summList = readdir(dataDir) |> π -> filter(χ -> contains(χ, "summary"), π)

# iterate on summaries
for summ ∈ summList

  # read annotation
  annotFile = annotationReader(string(dataDir, "/"), summ)

  # append rows
  push!(df, [replace(summ, "-summary.txt" => ""), length(annotFile)])

end

# write dataframe
writedf(string(mindData, "/", "summary", "/", "events", ".csv"), df, ',')

####################################################################################################
