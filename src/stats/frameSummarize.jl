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
  using CSV
  using DataFrames
  using Statistics
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
end;

####################################################################################################

# performance
performance = [:Sensitivity, :Specificity]

# list directories
rocList = readdir(string(mindROC))

# iterate on directories
for tier ∈ rocList

  # log
  @info tier

  # iterate on performance
  for Π ∈ performance

    # read dataframe
    @eval dir = $(string(Π)) |> lowercase
    @eval df = readdf(string(mindData, "/", dir, "/", "filter", $tier, ".csv"); sep = ',')

    # log
    @info dir

    # patch missing values
    for (ι, ç) ∈ enumerate(eachcol(df))
      df[!, ι] .= replace(ç, "missing" => missing)
    end

    # construct dataframe
    collectDf = describe(df[:, Not(:Electrode)])

    # rename record
    rename!(collectDf, "variable" => :Record)

    # calculate standard deviation
    collectDf[:, :std] .= map(eachcol(df[:, Not(:Electrode)])) do μ
      std(skipmissing(μ))
    end

    # supress type column
    collectDf = collectDf[:, Not(:eltype)]

    # supress missing column
    collectDf = collectDf[:, Not(:nmissing)]

    # add subjects
    subjects = @chain collectDf[:, :Record] begin
      string.()
      replace.(r"_\d\d" => "")
      replace.("a" => "")
      replace.("b" => "")
      replace.("c" => "")
      replace.("h" => "")
      replace.("_" => "")
      replace.("+" => "")
      string.("chb", _)
    end

    # reorder columns
    collectDf = hcat(subjects, collectDf)
    rename!(collectDf, "x1" => :Subject)

    # write dataframe
    @eval dir = $(string(Π)) |> lowercase
    @eval writedf(string(mindData, "/", dir, "/", "aggregated", $tier, ".csv"), $collectDf; sep = ',')

  end

end

####################################################################################################
