####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using DelimitedFiles
end;

####################################################################################################

# load modules
begin
  include(string(configDir, "/timeThresholds.jl"))
end;

####################################################################################################

# subjects
subjectList = string.("chb", string.(1:24, pad = 2))

# iterate on directories
for timeThres ∈ timeThresholds

  # declare dataset matrix
  datasetMt = zeros(Int, 2, 2)

  # list records
  csvList = readdir(string(mindData, "/", "event", "/", timeThres)) |> π -> replace.(π, ".csv" => "")

  # iterate on subjects
  for subj ∈ subjectList

    # declare subject matrix
    subjectMt = zeros(Int, 2, 2)

    # select subject files
    recordList = csvList |> π -> filter(χ -> contains(χ, subj), π)

    # iterate on files
    for record ∈ recordList

      # declare record matrix
      recordMt = zeros(Int, 2, 2)

      # select record files
      channelList = readdir(string(mindData, "/", "confusionMt", "/", "channel", "/", timeThres)) |> π -> filter(χ -> contains(χ, record), π) |> π -> replace.(π, ".csv" => "")

      for channel ∈ channelList

        # read csv file
        mt = readdlm(string(mindData, "/", "confusionMt", "/", "channel", "/", timeThres, "/", channel, ".csv"), ',')

        # add channel to record confusion matrix
        recordMt .+= mt

      end

      # write record matrix
      writedlm(string(mindData, "/", "confusionMt", "/", "record", "/", timeThres, "/", record, ".csv"), recordMt, ',')

      # add record to subject confusion matrix
      subjectMt .+= recordMt

    end

    # write subject matrix
    writedlm(string(mindData, "/", "confusionMt", "/", "subject", "/", timeThres, "/", subj, ".csv"), subjectMt, ',')

    # add subject to dataset confusion matrix
    datasetMt .+= subjectMt

  end

  # write dataset matrix
  writedlm(string(mindData, "/", "confusionMt", "/", "dataset", "/", timeThres, ".csv"), datasetMt, ',')

end

####################################################################################################
