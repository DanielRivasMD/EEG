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
for timeThres ∈ abs.(timeThresholds)

  # declare dataset matrix
  datasetMt = zeros(Int, 2, 2)

  # iterate on subjects
  for subj ∈ subjectList

    # declare subject matrix
    subjectMt = zeros(Int, 2, 2)

    # select subject files
    recordList = @chain begin
      readdir(string(database, "/", subj))
      filter(χ -> contains(χ, r"edf$"), _)
      replace.(".edf" => "")
    end

    # iterate on files
    for record ∈ recordList

      # declare record matrix
      recordMt = zeros(Int, 2, 2)

      # select record files
      channelList = @chain begin
        readdir(string(mindCM, "/", "channel", "/", timeThres))
        filter(χ -> contains(χ, record), _)
        filter(χ -> contains(χ, "frame"), _)
        replace.(_, ".csv" => "")
      end

      for channel ∈ channelList

        # read csv file
        mt = readdlm(string(mindCM, "/", "channel", "/", timeThres, "/", channel, ".csv"), ',')

        # add channel to record confusion matrix
        recordMt .+= mt

      end

      # write record matrix
      writedlm(string(mindCM, "/", "record", "/", timeThres, "/", "frame", "_", record, ".csv"), recordMt, ',')

      # add record to subject confusion matrix
      subjectMt .+= recordMt

    end

    # write subject matrix
    writedlm(string(mindCM, "/", "subject", "/", timeThres, "/", "frame", "_", subj, ".csv"), subjectMt, ',')

    # add subject to dataset confusion matrix
    datasetMt .+= subjectMt

  end

  # write dataset matrix
  writedlm(string(mindCM, "/", "dataset", "/", "frame", timeThres, ".csv"), datasetMt, ',')

end

####################################################################################################
