####################################################################################################

# set hyperparameters
@with_kw mutable struct NNParams
  η::Float64                   = 1e-3             # learning rate
  epochs::Int                  = 25               # number of epochs
  batchsize::Int               = 1000             # batch size for training
  throttle::Int                = 5                # throttle timeout
  device::Function             = gpu              # set as gpu, if gpu available
  σ::Function                  = leakyrelu        # learning function
  λ::Int                       = 64               # hidden layer on autoencoder
end;

####################################################################################################

# hidden Markov model parameters
hmmParams = HMMParams(
  penalty = 200,
  distance = euclDist,
  minimumFrequency = 20,
  verbosity = false,
)

####################################################################################################
