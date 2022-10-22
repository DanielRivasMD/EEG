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

####################################################################################################

# subjects
subjectList = string.("chb", string.(1:24, pad = 2))

# list directories
rocList = readdir(string(mindScreen))

# iterate on directories
for tier ∈ rocList

  # declare dataset matrix
  datasetMt = zeros(Int, 2, 2)

  # list records
  csvList = readdir(string(mindData, "/", "event", "/", tier)) |> π -> replace.(π, ".csv" => "")

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
      channelList = readdir(string(mindData, "/", "confusionMt", "/", "channel", "/", tier)) |> π -> filter(χ -> contains(χ, record), π) |> π -> replace.(π, ".csv" => "")

      for channel ∈ channelList

        # read csv file
        mt = readdlm(string(mindData, "/", "confusionMt", "/", "channel", "/", tier, "/", channel, ".csv"), ',')

        # add channel to record confusion matrix
        recordMt .+= mt

      end

      # write record matrix
      writedlm(string(mindData, "/", "confusionMt", "/", "record", "/", tier, "/", record, ".csv"), recordMt, ',')

      # add record to subject confusion matrix
      subjectMt .+= recordMt

    end

    # write subject matrix
    writedlm(string(mindData, "/", "confusionMt", "/", "subject", "/", tier, "/", subj, ".csv"), subjectMt, ',')

    # add subject to dataset confusion matrix
    datasetMt .+= subjectMt

  end

  # write dataset matrix
  writedlm(string(mindData, "/", "confusionMt", "/", "dataset", "/", tier, ".csv"), datasetMt, ',')

end

####################################################################################################
