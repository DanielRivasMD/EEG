################################################################################

using DataFrames
using FFTW
using Flux

################################################################################

"""

    extractChannelFFT(channel;
    binSize = 256, binOverlap = 2)

Apply fast fourier transform (FFT) to channel

"""
function extractChannelFFT(channel; binSize = 256, binOverlap = 2)
  # define variables
  stepSize = floor(Int32, binSize / binOverlap)
  signalSteps = 1:stepSize:length(channel)
  freqAr = Array{Float64}(
    undef,
    length(signalSteps),
    binSize
  )

  # iterate over signal bins
  for stepIx in eachindex(signalSteps)
    signalBoundry = signalSteps[stepIx] + binSize - 1

    # extract channel
    if signalBoundry <= length(channel)
      channelExtract = [
        channel[signalSteps[stepIx]:signalBoundry];
        zeros(binSize)
      ]

    # adjust last bin
    elseif signalBoundry > length(channel)
      channelExtract = [
        channel[signalSteps[stepIx]:end];
        (signalBoundry - length(channel) |> abs |> zeros);
        zeros(binSize)
      ]
    end

    # calculate fourier transform
    fftChannel = fft(channelExtract)
    realFft = abs.(fftChannel)
    freqAr[stepIx, :] = realFft[1:binSize]

  end
  return freqAr
end

# TODO: why separate fft by bins if they represent one single temparary frame

################################################################################

"""

    extractChannelFFT(edfDf, electrodeID;
    binSize = 256, binOverlap = 2)

Use extractChannelFFT on EDF file per channel

"""
function extractChannelFFT(edfDf::DataFrame; binSize::Int64 = 256, binOverlap::Int64 = 2)
  @info("Extracting channels frecuencies...")
  channelDc = Dict()
  freqAr = begin
    stepSize = floor(Int32, binSize / binOverlap)
    signalSteps = 1:stepSize:size(edfDf, 1)
    Array{Float64}(
      undef,
      1,
      binSize,
      length(signalSteps)
    )
  end

  # iterate on dataframe channels
  for (chl, elec) in enumerate(names(edfDf))
    tmpAr = extractChannelFFT(edfDf[:, chl], binSize = binSize, binOverlap = binOverlap)
    for bn in 1:size(tmpAr, 1)
      freqAr[:, :, bn] = tmpAr[bn, :]
    end
    channelDc[elec] = copy(freqAr)
  end
  return channelDc
end

################################################################################

"""

    extractFFT(edfDf;
    binSize = 256, binOverlap = 2)

Use extractChannelFFT on EDF file

"""
function extractFFT(edfDf; binSize = 256, binOverlap = 2)
  @info("Extracting frecuencies...")
  freqAr = begin
    stepSize = floor(Int32, binSize / binOverlap)
    signalSteps = 1:stepSize:size(edfDf)[1]
    Array{Float64}(
      undef,
      size(edfDf, 2),
      binSize,
      length(signalSteps)
    )
  end

  # iterate on dataframe channels
  for chl in 1:size(edfDf, 2)
    tmpAr = extractChannelFFT(edfDf[:, chl], binSize = binSize, binOverlap = binOverlap)
    for bn in 1:size(tmpAr, 1)
      freqAr[chl, :, bn] = tmpAr[bn, :]
    end
    end
  return freqAr
end

################################################################################

"""

    binChannelFFT(freqAr;
    fftBin = 16)

Bin FFT signals and collect sums

"""
function binChannelFFT(freqAr::Array{Float64, 3}; fftBin::Int64 = 16)
  freqAr = Flux.flatten(freqAr)
  # if size(freqAr, 1) / fftBin != 0
  #   @error "Cannot compute binning. Array size is not divisible by bin size"
  # end

  iterVc = 1:fftBin:size(freqAr, 1)
  outAr = Array{Float64, 2}(undef, fftBin, size(freqAr, 2))
  for (ix, st) in enumerate(iterVc)
    outAr[ix, :] = freqAr[st:floor(Int64, st + (size(freqAr, 1) / fftBin) - 1), :] |> p -> sum(p, dims = 1)
  end
  return outAr
end

################################################################################
