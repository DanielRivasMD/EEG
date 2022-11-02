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
  using Dates
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(annotationDir, "/", "functions", "/", "annotationCalibrator.jl"))
end;

####################################################################################################

# all records in this dataset were recorded at 256 samples per second
recordFreq = 256

# create dataframe
df = DataFrame(Subject = String[], Record = String[], Seconds = Int64[])

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
  push!(df, [subj, replace(tim, ".txt" => ""), mt[1, 1] / recordFreq])

end

# write dataframe
writedf(string(mindData, "/", "summary", "/", "timeRecords", ".csv"), df; sep = ',')

####################################################################################################

# collect subject times
gdf = @chain df begin
  groupby(_, :Subject)
  combine(:Seconds => sum => :Seconds)
end

# append columns
gdf[!, :Events] .= 0
gdf[!, :EventAggregate] .= 0

# list directories
summList = readdir(dataDir) |> π -> filter(χ -> contains(χ, "summary"), π)

# iterate on summaries
for sm ∈ summList

  # declare subject
  subj = replace(sm, "-summary.txt" => "")

  # read annotation
  annotFile = annotationReader(string(dataDir, "/"), sm)

  # preallocate events
  events = 0

  # iterate on dictionary
  for (κ, υ) ∈ annotFile
    # increase count
    events += length(υ)
  end

  # add aggregated to grouped dataframe
  gdf[findfirst(subj .== gdf[:, :Subject]), :Events] = events

  # aggregate events
  eventSum = Second(0)

  # collect event duration
  for (κ, υ) ∈ annotFile
    for ι ∈ eachindex(υ)
      eventSum += υ[ι][2] - υ[ι][1]
    end
  end

  # add aggregated to grouped dataframe
  gdf[findfirst(subj .== gdf[:, :Subject]), :EventAggregate] = eventSum.value

end

# summarize all subjects
push!(gdf, ("Total", sum(gdf[:, :Seconds]), sum(gdf[:, :Events]), sum(gdf[:, :EventAggregate])))

# calculate percentage
gdf[!, :Percentage] .= gdf[:, :EventAggregate] ./ gdf[:, :Seconds]

# write dataframe
writedf(string(mindData, "/", "summary", "/", "timeSubjects", ".csv"), gdf; sep = ',')

####################################################################################################
