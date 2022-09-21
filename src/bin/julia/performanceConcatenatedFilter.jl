####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  # mind reader
  using MindReader

  # hidden Markov model
  using HiddenMarkovModelReaders

  # dependencies
  using DelimitedFiles
  using RCall

  # parameters
  using Parameters: @with_kw
end;

####################################################################################################

# argument parser
include(string(importDir, "/utilitiesJL/argParser.jl"));

####################################################################################################

# split parameter into vector
shArgs["input"] = shArgs["input"] |> π -> split(π, ",") |> π -> π[1:end - 1]

# declare artificial state
artificialState = 10.

####################################################################################################

# since sample per record = 256, window size = 256, & overlap = 4
# then each bin represents 1 second of recording with 1 quarter of second offset
# declare time threshold
timeThres = 120

# iterate on dictionary
for (κ, υ) ∈ msHmmDc

  # declare traceback
  tb = υ.traceback

  # identify peak
  R" peakDf <- peak_iden($tb, 2) "
  @rget peakDf

  # reset traceback
  υ.traceback = ones(υ.traceback |> length)

  # assign peak values
  for ρ ∈ eachrow(filter(:peak_length_ix => χ -> χ >= timeThres, peakDf))
    υ.traceback[Int(ρ[:lower_lim_ix]):Int(ρ[:upper_lim_ix])] .= artificialState
  end

end

####################################################################################################

# measure performance
writedlm(
  string(shArgs["outDir"], "/", "filterScreen/", replace(shArgs["annotation"], "-summary.txt" => ".csv")),
  writePerformance(sensitivitySpecificity(msHmmDc, msLabelAr)),
  ", ",
)

####################################################################################################
