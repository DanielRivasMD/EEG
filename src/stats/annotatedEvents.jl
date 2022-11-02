####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using CSV
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(annotationDir, "/", "functions", "/", "annotationCalibrator.jl"))
end;

####################################################################################################

# create dataframe
df = DataFrame(Subject = String[], Events = Int64[])

# list directories
summList = readdir(dataDir) |> π -> filter(χ -> contains(χ, "summary"), π)

# iterate on summaries
for summ ∈ summList

  # read annotation
  annotFile = annotationReader(string(dataDir, "/"), summ)

  # preallocate events
  events = 0

  # iterate on dictionary
  for (κ, υ) ∈ annotFile
    # increase count
    events += length(υ)
  end

  # append rows
  push!(df, [replace(summ, "-summary.txt" => ""), events])

end

# summarize all subjects
push!(df, ("Total", sum(df[:, :Events])))

# write dataframe
writedf(string(mindData, "/", "summary", "/", "events", ".csv"), df; sep = ',')

####################################################################################################
