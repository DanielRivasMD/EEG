####################################################################################################

# declarations
begin
  include( "/Users/drivas/Factorem/EEG/src/config/config.jl" )
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  using HiddenMarkovModelReaders
end;

####################################################################################################

function reconstructHMM(filename::S) where S <: String

  # load hidden Markov model model
  model = @chain begin
    readdf(string(filename, "_model.csv"), ',')
    map(1:size(_, 2)) do μ
      _[:, μ]
    end
  end

  # load hidden Markov model traceback
  traceback = @chain begin
    readdf(string(filename, "_traceback.csv"), ',')
    _[:, 1]
  end

  # reconstruct hidden Markov model with empty data
  return HMM([zeros(0)], model, traceback)

end

####################################################################################################
