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
end;

####################################################################################################

# read dataframe
df = readdf(string(dataDir, "/", "summary", "/", "event", "0", ".csv"); sep = ',')

####################################################################################################

# collect subject times
gdf = @chain df begin
  groupby(_, :Subject)
  combine(:Detected => sum => :Detected)
end

# declare empty column
gdf[!, :Annotated] .= 0

# collect counts
@chain df begin
  groupby(_, :Subject)
  for (ι, γ) ∈ enumerate(_)
    gdf[ι, :Annotated] = size(γ, 1)
  end
end

# calculate total
push!(gdf, ("Total", sum(gdf[:, :Detected]), sum(gdf[:, :Annotated])))

# calculate percentage
gdf[!, :Percentage] .= round.(gdf[:, :Detected] ./ gdf[:, :Annotated] .* 100, digits = 2)

####################################################################################################

# write dataframe
writedf(string(dataDir, "/", "summary", "/", "eventsDetected", ".csv"), gdf; sep = ',')

####################################################################################################
