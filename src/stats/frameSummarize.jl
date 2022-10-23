####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  # mind reader
  using MindReader

  # dependencies
  using DataFrames
  using DelimitedFiles
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
  datasetMt = readdlm(string(mindData, "/", "confusionMt", "/", "dataset", "/", timeThres, ".csv"), ',')

  # write dataset
  writePerformance(
    string(mindROC, "/", "dataset", "/", timeThres, ".csv"),
    performance(datasetMt),
    delim = ",",
  )

  # list records
  csvList = readdir(string(mindData, "/", "event", "/", timeThres)) |> π -> replace.(π, ".csv" => "")

  # iterate on subjects
  for subj ∈ subjectList

    # load subject
    subjectMt = readdlm(string(mindData, "/", "confusionMt", "/", "subject", "/", timeThres, "/", subj, ".csv"), ',')

    # write subject
    writePerformance(
      string(mindROC, "/", "subject", "/", timeThres, "/", subj, ".csv"),
      performance(subjectMt),
      delim = ",",
    )

    # select subject files
    recordList = csvList |> π -> filter(χ -> contains(χ, subj), π)

    # iterate on files
    for record ∈ recordList

      # load record
      recordMt = readdlm(string(mindData, "/", "confusionMt", "/", "record", "/", timeThres, "/", record, ".csv"), ',')

      # write record
      writePerformance(
        string(mindROC, "/", "record", "/", timeThres, "/", record, ".csv"),
        performance(recordMt),
        delim = ",",
      )

      # preallocate dictionary
      channelDc = Dict{String, Dict{String, Float64}}()

      # select record files
      channelList = readdir(string(mindData, "/", "confusionMt", "/", "channel", "/", timeThres)) |> π -> filter(χ -> contains(χ, record), π) |> π -> replace.(π, ".csv" => "")

      for channel ∈ channelList

        # define channel id
        channelID = channel[findlast("_", channel)[1] + 1:end]

        # load channel
        channelMt = readdlm(string(mindData, "/", "confusionMt", "/", "channel", "/", timeThres, "/", channel, ".csv"), ',')

        # append channel performance
        channelDc[channelID] = performance(channelMt)

      end

      # write channels
      writePerformance(
        string(mindROC, "/", "channel", "/", timeThres, "/", record, ".csv"),
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
  df = [readdf(string(mindROC, "/", "subject", "/", timeThres, "/", subj, ".csv"), sep = ',') for subj ∈ subjectList]

  # concatenate dataframes
  df = vcat(df...)

  # append overall
  push!(df, eachrow(readdf(string(mindROC, "/", "dataset", "/", timeThres, ".csv"), sep = ','))[1])

  # append subjects
  df[:, :Subject] .= [subjectList; "Total"]
  df = [df[:, :Subject] df[:, Not(:Subject)]]
  rename!(df, "x1" => :Subject)

  # write dataframe
  writedf(
    string(mindData, "/", "summary", "/", "performance", timeThres, ".csv"),
    df,
    sep = ',',
  )

end

####################################################################################################
