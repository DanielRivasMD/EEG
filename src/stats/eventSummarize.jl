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
  using Statistics
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
  include(string(configDir, "/timeThresholds.jl"))
end;

####################################################################################################

# subjects
subjectList = string.("chb", string.(1:24, pad = 2))

# iterate on directories
for timeThres ∈ timeThresholds

  # load dataset
  datasetMt = readdlm(string(mindCM, "/", "dataset", "/", "event", timeThres, ".csv"), ',')

  # write dataset
  writePerformance(
    string(mindROC, "/", "dataset", "/", "event", timeThres, ".csv"),
    performance(datasetMt),
    delim = ",",
  )

  # list records
  csvList = readdir(string(mindEvent, "/", timeThres)) |> π -> replace.(π, ".csv" => "")

  # iterate on subjects
  for subj ∈ subjectList

    # load subject
    subjectMt = readdlm(string(mindCM, "/", "subject", "/", timeThres, "/", subj, ".csv"), ',')

    # write subject
    writePerformance(
      string(mindROC, "/", "subject", "/", timeThres, "/", "event", subj, ".csv"),
      performance(subjectMt),
      delim = ",",
    )

    # select subject files
    recordList = csvList |> π -> filter(χ -> contains(χ, subj), π)

    # iterate on files
    for record ∈ recordList

      # load record
      recordMt = readdlm(string(mindCM, "/", "record", "/", timeThres, "/", record, ".csv"), ',')

      # write record
      writePerformance(
        string(mindROC, "/", "record", "/", timeThres, "/", "event", record, ".csv"),
        performance(recordMt),
        delim = ",",
      )

      # preallocate dictionary
      channelDc = Dict{String, Dict{String, Float64}}()

      # select record files
      channelList = readdir(string(mindCM, "/", "channel", "/", timeThres)) |> π -> filter(χ -> contains(χ, record), π) |> π -> replace.(π, ".csv" => "")

      for channel ∈ channelList

        # define channel id
        channelID = channel[findlast("_", channel)[1] + 1:end]

        # load channel
        channelMt = readdlm(string(mindCM, "/", "channel", "/", timeThres, "/", channel, ".csv"), ',')

        # append channel performance
        channelDc[channelID] = performance(channelMt)

      end

      # write channels
      writePerformance(
        string(mindROC, "/", "channel", "/", timeThres, "/", "event", record, ".csv"),
        channelDc,
        delim = ",",
      )

    end

  end

end

####################################################################################################

# iterate on directories
for timeThres ∈ timeThresholds

  # read dataframe
  df = readdf(string(mindData, "/", "recall", "/", "filter", timeThres, ".csv"); sep = ',')

  if timeThres == timeThresholds[1]

    # group by existing records
    eventRecords = groupby(df, :Record) |> length

    # write number of records
    writedlm(
      string(mindData, "/", "summary", "/", "eventRecords", ".csv"),
      eventRecords,
      ",",
    )

  end

  # add total count
  df[!, :Total] .= 1

  # collect results
  gdf = @chain df begin
    groupby(_, :Subject)
    combine(:Detected => sum => :Detected, :Total => sum => :Total)
  end

  # summarize all subjects
  push!(gdf, ("Total", sum(gdf[:, :Detected]), sum(gdf[:, :Total])))

  # calculate percentage
  gdf[!, :Percentage] .= gdf[:, :Detected] ./ gdf[:, :Total]

  # write dataframe
  writedf(string(mindData, "/", "summary", "/", "precision", timeThres, ".csv"), gdf; sep = ',')

end

####################################################################################################
