################################################################################

using Flux, Flux.Data.MNIST
using Flux: @epochs, onehotbatch, mse, throttle
using Base.Iterators: partition
using Parameters: @with_kw
using CUDAapi

################################################################################

if has_cuda()
  # @info "CUDA is on"
  import CuArrays
  CuArrays.allowscalar(false)
end

################################################################################

"""

    modelTrain(inputAr, model, Params;
    kws...)

Train autoencoder

# Arguments
`inputAr` array to train on

`model` neural network architecture

arguments passed as `Params` with `Parameters::@with_kw`

"""
function modelTrain(inputAr, model, Params)
  args = Params()

  @info("Loading data...")
  trainAr = args.device.(inputAr)

  @info("Training model...")
  loss(x) = mse(model(x), x)

  # training
  evalcb = throttle(() -> @show(loss(trainAr[1])), args.throttle)
  opt = ADAM(args.η)

  @epochs args.epochs Flux.train!(loss, params(model), zip(trainAr), opt, cb = evalcb)

  return model
end

################################################################################
