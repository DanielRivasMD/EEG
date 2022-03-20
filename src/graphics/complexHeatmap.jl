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
  readdir("/Users/drivas/Factorem/MindReader/data/hmm/")
  filter(χ -> occursin("states", χ), _)
end

################################################################################

# read files into dataframe array & concatenate
df = [readdf(string("/Users/drivas/Factorem/MindReader/data/hmm/", ι), ',') for ι ∈ states]
df = hcat(df...)

################################################################################

# write dataframe
writedf("/Users/drivas/Factorem/MindReader/data/csv/sample.csv", df, ',')

################################################################################
