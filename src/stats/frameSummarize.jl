####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  # mind reader
  using MindReader
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
  datasetMt = readdlm(string(mindCM, "/", "dataset", "/", "frame", timeThres, ".csv"), ',')

  # write dataset
  writePerformance(
    string(mindROC, "/", "dataset", "/", "frame", timeThres, ".csv"),
    performance(datasetMt),
    delim = ",",
  )

  # list records
  csvList = readdir(string(mindEvent, "/", timeThres)) |> π -> replace.(π, ".csv" => "")

  # iterate on subjects
  for subj ∈ subjectList

    # load subject
    subjectMt = readdlm(string(mindCM, "/", "subject", "/", timeThres, "/", "frame", "_", subj, ".csv"), ',')

    # write subject
    writePerformance(
      string(mindROC, "/", "subject", "/", timeThres, "/", "frame", "_", subj, ".csv"),
      performance(subjectMt),
      delim = ",",
    )

    # select subject files
    recordList = csvList |> π -> filter(χ -> contains(χ, subj), π)

    # iterate on files
    for record ∈ recordList

      # load record
      recordMt = readdlm(string(mindCM, "/", "record", "/", timeThres, "/", "frame", "_", record, ".csv"), ',')

      # write record
      writePerformance(
        string(mindROC, "/", "record", "/", timeThres, "/", "frame", "_", record, ".csv"),
        performance(recordMt),
        delim = ",",
      )

      # preallocate dictionary
      channelDc = Dict{String, Dict{String, Float64}}()

      # select record files
      channelList = @chain begin
        readdir(string(mindCM, "/", "channel", "/", timeThres))
        filter(χ -> contains(χ, record), _)
        filter(χ -> contains(χ, "frame"), _)
        replace.(_, ".csv" => "")
      end

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
        string(mindROC, "/", "channel", "/", timeThres, "/", "frame", "_", record, ".csv"),
        channelDc,
        delim = ",",
      )

    end

  end

end

####################################################################################################

# iterate on times
for timeThres ∈ timeThresholds

  # read dataframes
  df = [readdf(string(mindROC, "/", "subject", "/", timeThres, "/", "frame", "_", subj, ".csv"), sep = ',') for subj ∈ subjectList]

  # concatenate dataframes
  df = vcat(df...)

  # append overall
  push!(df, eachrow(readdf(string(mindROC, "/", "dataset", "/", "frame", timeThres, ".csv"), sep = ','))[1])

  # append subjects
  df = hcat([subjectList; "Total"], df)
  rename!(df, "x1" => :Subject)

  # write dataframe
  writedf(
    string(mindData, "/", "summary", "/", "performance", "_", "frame", "_", timeThres, ".csv"),
    df,
    sep = ',',
  )

end

####################################################################################################

# read dataframes
df = [readdf(string(mindROC, "/", "dataset", "/", "frame", timeThres, ".csv"), sep = ',') for timeThres ∈ timeThresholds]

# concatenate dataframes
df = vcat(df...)

# append time stamps
df = hcat(timeThresholds, df)
rename!(df, "x1" => :Filter)

writedf(
  string(mindData, "/", "summary", "/", "dataset", "_", "frame", "_",".csv"),
  df,
  sep = ',',
)

####################################################################################################
