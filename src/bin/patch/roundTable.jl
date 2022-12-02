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
  include(string(configDir, "/", "timeThresholds.jl"))
end;

####################################################################################################

# read dataframe
df = readdf(string(dataDir, "/", "summary", "/", "performance", "_", "frame", "_", "0", ".csv"); sep = ',')

# round values
for ι ∈ axes(df, 2)
  if ι == 1 continue end
  df[!, ι] .= round.(df[:, ι], digits = 4)
end

# write dataframe
writedf(string(dataDir, "/", "summary", "/", "round", "_", "performance", "_", "frame", "_", "0", ".csv"), df; sep = ',')

####################################################################################################
