################################################################################

# load packages
begin
  using DataFrames
  using DelimitedFiles
end;

################################################################################

"read dataframe"
function readdf(path; sep = '\t')
  f, h = readdlm(path, sep, header = true)
  DataFrame(f, h |> vec)
end

################################################################################

"write dataframe"
function writedf(path, df::DataFrame; sep = '\t')
  toWrite = [(df |> names |> permutedims); (df |> Array)]
  writedlm(path, toWrite, sep)
end

################################################################################
