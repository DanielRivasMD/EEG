################################################################################

# declarations
begin
  include( "/Users/drivas/Factorem/EEG/src/config/config.jl" )
end;

################################################################################

# load project enviroment
using Pkg
if Pkg.project().path != string( projDir, "/Project.toml" )
  Pkg.activate(projDir)
end

################################################################################

# load packages
begin

end;

################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
end;

################################################################################

# identify files to load
states = @chain begin
  readdir(mindHMM)
  filter(χ -> occursin("chb04_28", χ) && occursin("traceback", χ), _)
end

################################################################################

# read files into dataframe array & concatenate
df = [readdf(string(mindHMM, "/", ι), ',') for ι ∈ states]
df = hcat(df...)

################################################################################

# write dataframe
writedf(string(mindCSV, "/sample.csv"), df, ',')

################################################################################
