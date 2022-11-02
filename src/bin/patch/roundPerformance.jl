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
  include(string(utilDir, "/", "ioDataFrame.jl"))
  include(string(configDir, "/timeThresholds.jl"))
end;

####################################################################################################

# iterate on measurements
for measure ∈ ["event", "frame"]

  # iterate on times
  for timeThres ∈ timeThresholds

    # read dataframe
    df = readdf(string(mindData, "/", "summary", "/", "performance", "_", measure, "_", timeThres, ".csv"), sep = ',')

    # round values
    for ι ∈ axes(df, 2)
      if ι == 1 continue end
      df[!, ι] .= round.(df[:, ι], digits = 4)
    end

    # write dataframe
    writedf(string(mindData, "/", "summary", "/", "performance", "_", measure, "_", timeThres, ".csv"), df; sep = ',')

  end

end

####################################################################################################
