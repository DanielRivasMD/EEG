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

# create dataframe
df = DataFrame(Subject = String[], Record = String[], Start = Int64[], End = Int64[])

# iterate on summaries
for sm ∈ summList

  # declare subject
  subj = replace(sm, "-summary.txt" => "")

  # read annotation
  annotFile = annotationReader(string(dataDir, "/"), sm)

  # preallocate events
  events = 0

  # aggregate events
  eventSum = 0

  # collect event duration
  for (κ, υ) ∈ annotFile

    # increase count
    events += length(υ)

    # iterate on events
    for ι ∈ eachindex(υ)

      # add annotated event
      push!(df, [subj, κ, υ[ι][1].value, υ[ι][2].value])

      # sum event length
      eventSum += υ[ι][2].value - υ[ι][1].value

    end

  end

  # add aggregated to grouped dataframe
  gdf[findfirst(subj .== gdf[:, :Subject]), :Events] = events

  # add aggregated to grouped sum dataframe
  gdf[findfirst(subj .== gdf[:, :Subject]), :EventAggregate] = eventSum

end

# calculate event duration
df[!, :Duration] .= df[:, :End] .- df[:, :Start]

# summarize all subjects
push!(gdf, ("Total", sum(gdf[:, :Seconds]), sum(gdf[:, :Events]), sum(gdf[:, :EventAggregate])))

# calculate percentage
gdf[!, :Percentage] .= round.(gdf[:, :EventAggregate] ./ gdf[:, :Seconds], digits = 4)

# write dataframe annotated events
writedf(string(mindData, "/", "summary", "/", "timeEvents", ".csv"), df; sep = ',')

# write dataframe annotated events aggregate
writedf(string(mindData, "/", "summary", "/", "timeSubjects", ".csv"), gdf; sep = ',')

####################################################################################################
