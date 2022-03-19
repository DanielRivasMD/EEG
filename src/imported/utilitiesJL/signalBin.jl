################################################################################

using DataFrames

################################################################################

"""

    extractChannelSignalBin(channel;
    binSize = 256, binOverlap = 8)

Bins channel signal

"""
function extractChannelSignalBin(channel::Array; binSize = 256, binOverlap = 8)
  # define variables
  stepSize = floor(Int32, binSize / binOverlap)
  signalSteps = 1:stepSize:length(channel)
  signalAr = Array{Float64}(
    undef,
    length(signalSteps),
    binSize
  )

  # iterate over signal bins
  for stepIx in 1:length(signalSteps)
    signalBoundry = signalSteps[stepIx] + binSize - 1

    # extract signals
    if signalBoundry <= length(channel)
      signalAr[stepIx, :] = channel[signalSteps[stepIx]:signalBoundry]

    # adjust last bin
    elseif signalBoundry > length(channel)
      signalAr[stepIx, :] = [
        channel[signalSteps[stepIx]:end];
        (signalBoundry - length(channel) |> abs |> zeros)
      ]
    end

  end
  return signalAr
end

################################################################################

"""

    extractChannelSignalBin(edfDf, electrodeID;
    binSize = 256, binOverlap = 8)

Use extractChannelSignalBin on EDF file per channel

"""
function extractChannelSignalBin(edfDf::DataFrame, electrodeID; binSize = 256, binOverlap = 8)
  @info("Binning channels signals...")
  channelDc = Dict()
  signalAr = begin
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
  for (chl, elec) in enumerate(electrodeID)
    tmpAr = extractChannelSignalBin(edfDf[:, chl], binSize = binSize, binOverlap = binOverlap)
    for bn in 1:size(tmpAr, 1)
      signalAr[:, :, bn] = tmpAr[bn, :]
    end
    channelDc[elec] = copy(signalAr)
  end
  return channelDc
end

################################################################################

"""

    extractSignalBin(edfDf;
    binSize = 256, binOverlap = 8)

Use extractChannelSignalBin on EDF file

"""
function extractSignalBin(edfDf::DataFrame; binSize = 256, binOverlap = 8)
  @info("Binning signals...")
  signalAr = begin
    stepSize = floor(Int32, binSize / binOverlap)
    signalSteps = 1:stepSize:size(edfDf, 1)
    Array{Float64}(
      undef,
      size(edfDf, 2),
      binSize,
      length(signalSteps)
    )
  end

  # iterate on dataframe channels
  for chl in 1:size(signalAr, 1)
    tmpAr = extractChannelSignalBin(edfDf[:, chl], binSize = binSize, binOverlap = binOverlap)
    for bn in 1:size(tmpAr, 1)
      signalAr[chl, :, bn] = tmpAr[bn, :]
    end
  end
  return signalAr
end

################################################################################
