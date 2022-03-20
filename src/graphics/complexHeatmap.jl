################################################################################

"read dataframe"
function readdf(path, sep='\t')
  f, h = readdlm(path, sep, header=true)
  DataFrame(f, h |> vec)
end

################################################################################

"write dataframe"
function writedf(path, df::DataFrame, sep='\t')
  toWrite = [(df |> names |> permutedims); (df |> Array)]
  writedlm(path, toWrite, sep)
end

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
