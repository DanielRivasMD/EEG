################################################################################

using DataFrames
using Dates

################################################################################


"""

    annotationCalibrator(xDf;
    startTime, recordFreq, signalLength, binSize = 256, binOverlap = 8)

Input annotations from XLSX and incorporates them to neural network for training

# Arguments
`xDf` annotations from XLSX file

`startTime` signal start time

`recordFreq` recording frecuency

`signalLength` recording length

`binSize` window bin size

`binOverlap` overlap

"""
function annotationCalibrator(xDf; startTime, recordFreq, signalLength, binSize, binOverlap)

  # collect recording frecuency
  recFreq = begin
    recAv = (sum(recordFreq)) / (length(recordFreq))
    recAv |> p -> convert(Int64, p)
  end


  # fields to check
  fields = ["ST", "MA", "EM"]
  stepSize = floor(Int32, binSize / binOverlap)
  signalSteps = 1:stepSize:signalLength
  binArr = zeros(Int64, length(signalSteps), length(fields))

  # binArr = [0 for i in eachindex(fields)]
  # binArr = [zeros(length(signalSteps)) for i in eachindex(fields)]
  for fx in eachindex(fields)
    fk = fields[fx]

    # purge missing records on all columns
    toSupress = begin
      [ismissing(xDf[fk][j, i]) for j in 1:size(xDf[fk], 1) for i in 1:size(xDf[fk], 2)] |>
      p -> reshape(p, size(xDf[fk], 2), size(xDf[fk], 1)) |>
      p -> sum(p, dims = 1)
    end

    delete!(xDf[fk], (toSupress' .== size(xDf[fk], 2))[:, 1])

    # generate signal holder
    signalVec = zeros(signalLength)

    # collect annotations
    for ix in 1:size(xDf[fk], 1)
      if !ismissing(xDf[fk][ix, :START]) & !ismissing(xDf[fk][ix, :END])
        emSt = xDf[fk][ix, :START] - startTime |> p -> convert(Dates.Second, p) |> p -> p.value * recFreq
        emEn = xDf[fk][ix, :END] - startTime |> p -> convert(Dates.Second, p) |> p -> p.value * recFreq
        signalVec[emSt:emEn, :] .= 1
      else
        @warn "Annotation is not formatted properly & is not reliable"
      end
    end

    # binned signal
    binVec = begin
      binVec = extractChannelSignalBin(signalVec, binSize = binSize, binOverlap = binOverlap)
      binVec = sum(binVec, dims = 2)
      replace!(r -> r >= 1 ? 1 : 0, binVec)
      binVec = convert.(Int64, binVec)
      binVec[:, 1]
    end
    binArr[:, fx] = binVec
  end

  return binArr
end

################################################################################
