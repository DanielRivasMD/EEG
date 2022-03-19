################################################################################

using Flux

################################################################################

"""

    shifter(inputAr)

Reshape signals for autoencoder

"""
function shifter(inputAr)
  outAr = [
    Array{Float64}(
      undef,
      prod(size(inputAr)[1:2])
    )
    for i in 1:size(inputAr, 3)
  ]
  for ix in 1:size(inputAr, 3)
    outAr[ix] = vec(inputAr[:, :, ix])
  end
  return outAr
end

################################################################################

"""

    reshifter(inputAr;
    binSize = 256)

Reshape signals from autoencoder

"""
function reshifter(inputAr, binSize = length(inputAr[1]))
  ch = length(inputAr[1]) / binSize |> p -> convert(Int64, p)
  outAr  = Array{Float64}(
    undef,
    ch,
    binSize,
    length(inputAr)
  )

  for ix in 1:length(inputAr)
    outAr[:, :, ix] = inputAr[ix] |> p -> reshape(p, ch, binSize)
  end

  return outAr
end

################################################################################
