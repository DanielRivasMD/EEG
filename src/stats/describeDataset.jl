####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  # Makie
  using CairoMakie

  # dependencies
  using Dates
  using Statistics
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(utilDir, "/", "timeConversion.jl"))
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
  combine(:Seconds => sum => :TotalSeconds)
end

# count records
gdf[!, :RecordCount] .= 0

# iterate on subjects
for subj ∈ string.("chb", string.(1:24, pad = 2))
  gdf[findfirst(gdf[:, :Subject] .== subj), :RecordCount] = length(findall(subj .== df[:, :Subject]))
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
push!(gdf, ("Total", sum(gdf[:, :TotalSeconds]), sum(gdf[:, :RecordCount]), sum(gdf[:, :Events]), sum(gdf[:, :EventAggregate])))

# add time columns
time = convertFromSeconds.(gdf[:, :TotalSeconds])
gdf[:, :Hours] .= Int.([τ[1] for τ ∈ time])
gdf[:, :Minutes] .= Int.([τ[2] for τ ∈ time])
gdf[:, :Seconds] .= Int.([τ[3] for τ ∈ time])

# calculate percentage
gdf[!, :Percentage] .= round.(gdf[:, :EventAggregate] ./ gdf[:, :TotalSeconds], digits = 4)

# write dataframe annotated events
writedf(string(mindData, "/", "summary", "/", "timeEvents", ".csv"), df; sep = ',')

# write dataframe annotated events aggregate
writedf(string(mindData, "/", "summary", "/", "timeSubjects", ".csv"), gdf; sep = ',')

####################################################################################################

# calculate annotated event distribution per subject
gdf = @chain df begin
  groupby(_, :Subject)
  combine(_, describe)
  filter(χ -> χ.variable == :Duration, _)
  _[:, Not([:variable, :nmissing, :eltype])]
end

# calculate annotated event standard deviation per subject
@chain df begin
  groupby(_, :Subject)
  combine(:Duration => std)
  gdf[!, :std] .= _[:, :Duration_std]
end

# append overall annotated distribution & std deviation
@chain df begin
  describe
  filter(χ -> χ.variable == :Duration, _)
  _[:, Not([:variable, :nmissing, :eltype])]
  push!(gdf, ["Overall"; Vector(_[1, :]); std(df[:, :Duration])])
end

# round mean & std
gdf[!, :mean] .= round.(gdf[:, :mean], digits = 2)
gdf[!, :std] .= round.(gdf[:, :std], digits = 2)

# write dataframe annotated events distribution
writedf(string(mindData, "/", "summary", "/", "timeDistribution", ".csv"), gdf; sep = ',')

####################################################################################################

# plot boxplot
φ = Figure()

# assign axes labels
ξ = CairoMakie.Axis(
  φ[1, 1],
  title = "Distribution of annotated events",
  xlabel = "Subjects",
  ylabel = "Event duration in Seconds",
  xticks = ([1:24...], string.("chb", string.(1:24, pad = 2))),
  xticklabelsize = 8,
)

# plot distribution
boxplot!(
  ξ,
  df[:, :Subject] .|> π -> replace(π, "chb" => "") .|> π -> parse(Int, π),
  df[:, :Duration],
  show_outliers = true
)

# save figure
save(string(mindPlot, "/", "eventDistribution", ".svg"), φ)

####################################################################################################
