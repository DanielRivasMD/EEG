####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain
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

  # declare dataset matrix
  datasetMt = zeros(Int, 2, 2)

  # list records
  csvList = readdir(string(mindEvent, "/", timeThres)) |> π -> replace.(π, ".csv" => "")

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
      channelList = @chain begin
        readdir(string(mindCM, "/", "channel", "/", timeThres))
        filter(χ -> contains(χ, record), _)
        filter(χ -> contains(χ, "event"), _)
        replace.(_, ".csv" => "")
      end

      for channel ∈ channelList

        # read csv file
        mt = readdlm(string(mindCM, "/", "channel", "/", timeThres, "/", channel, ".csv"), ',')

        # add channel to record confusion matrix
        recordMt .+= mt

      end

      # write record matrix
      writedlm(string(mindCM, "/", "record", "/", timeThres, "/", "event", "_", record, ".csv"), recordMt, ',')

      # add record to subject confusion matrix
      subjectMt .+= recordMt

    end

    # write subject matrix
    writedlm(string(mindCM, "/", "subject", "/", timeThres, "/", "event", "_", subj, ".csv"), subjectMt, ',')

    # add subject to dataset confusion matrix
    datasetMt .+= subjectMt

  end

  # write dataset matrix
  writedlm(string(mindCM, "/", "dataset", "/", "event", timeThres, ".csv"), datasetMt, ',')

end

####################################################################################################

# iterate on directories
for timeThres ∈ timeThresholds

  # declare collected dataframe
  collectDf = DataFrame(Subject = String[], Record = String[], Detected = Int[], peakNo = Float64[], lowerLimIx = Float64[], upperLimIx = Float64[], peakLengthIx = Float64[])

  # list records
  csvList = readdir(string(mindEvent, "/", timeThres))

  # iterate on files
  for csv ∈ csvList

    # extract subject
    subj = @chain csv begin
      replace.(".csv" => "")
      replace.(r"_\d\d" => "")
      replace.("a" => "")
      replace.("b" => "")
      replace.("c" => "")
      replace.("h" => "")
      replace.("_" => "")
      replace.("+" => "")
      string("chb", _)
    end

    # read csv file
    df = readdf(string(mindEvent, "/", timeThres, "/", csv); sep = ',')

    # read files with annotations
    if size(df, 1) > 0

      # collected detection
      # peak detection only contains 4 fields
      det = map(sum, eachrow(df[:, 5:end]))

      for ι ∈ axes(df, 1)
        push!(collectDf, [subj; replace(csv, ".csv" => ""); det[ι] > 0; [df[ι, ο] for ο ∈ 1:4]])
      end

    end

  end

  # write dataframe
  writedf(string(mindData, "/", "summary", "/", "events", timeThres, ".csv"), collectDf; sep = ',')

end

####################################################################################################
