####################################################################################################

# load packages
begin
  using Dates
end;

####################################################################################################

"""

    annotationReader(path::S, summaryFile::S; verbose::B = false)
      where S <: String
      where B <: Bool

# Description
Extract anomaly events from summary file [physionet]. Return a dictionary with files as keys.


See also: [`annotationCalibrator`](@ref), [`labelParser`](@ref)
"""
function annotationReader(path::S, summaryFile::S; verbose::B = false) where S <: String where B <: Bool

  # verbose
  if verbose @info "Reading annotations..." end

  annotDc = Dict{String, Vector{Tuple{Second, Second}}}()
  lastFile = ""
  startTime = Second(0)
  endTime = Second(0)
  timeVc = [(startTime, endTime)]
  ç = 0
  ϟ1 = false
  ϟ2 = false

  # read file by lines
  for ł ∈ eachline(string(path, summaryFile))

    # identify lines
    if contains(ł, "File Name")
      lastFile = getSeizureFile(ł)
      ϟ1 = true
    elseif contains(ł, "Number of Seizures")
      ç = getSeizureNo(ł)
    elseif contains(ł, "Seizure") && contains(ł, "Start Time")
      startTime = getSeizureSec(ł)
    elseif contains(ł, "Seizure") && contains(ł, "End Time")
      endTime = getSeizureSec(ł)
      push!(timeVc, (startTime, endTime))
      if length(timeVc) == ç + 1
        ϟ2 = true
      end
    end

    # collect on switches
    if ϟ1 && ϟ2
      ϟ2 = false
      annotDc[lastFile] = timeVc[2:end]
      timeVc = [(startTime, endTime)]
    end

  end

  return annotDc
end

####################################################################################################

"""

    annotationCalibrator(annotations::VT;
    recordFreq::V, signalLength::I, shParams::D, verbose::B = false)
      where VT <: Vector{Tuple{Sc, Sc}}
      where Sc <: Second
      where V <: Vector{N}
      where N <: Number
      where I <: Int64
      where D <: Dict
      where B <: Bool

# Description
Calibrate timestamp from summary file [physionet].

# Arguments
`annotations` annotations summary [physionet].

`recordFreq` recording frecuency.

`signalLength` recording length.

`shParams` dictionary with command line arguments to extract: `binSize` window bin size and `binOverlap` overlap.

`verbose` set verbosity.


See also: [`annotationReader`](@ref), [`labelParser`](@ref)
"""
function annotationCalibrator(annotations::VT; recordFreq::V, signalLength::I, shParams::D, verbose::B = false) where VT <: Vector{Tuple{Sc, Sc}} where Sc <: Second where V <: Vector{N} where N <: Number where I <: Int64 where D <: Dict where B <: Bool

  # verbose
  if verbose @info "Calibrating annotations..." end

  # collect recording frecuency
  recFreq = begin
    recAv = (sum(recordFreq)) / (length(recordFreq))
    recAv |> π -> convert(Int64, π)
  end

  # generate signal holder
  signalVec = zeros(signalLength)

  # collect annotations
  for α ∈ annotations
    emSt = α[1].value * recFreq
    emEn = (α[2].value * recFreq) + recFreq
    signalVec[emSt:emEn, :] .= 1
  end

  # binned signal
  binVec = begin
    binVec = extractSignalBin(signalVec, binSize = shParams["window-size"], binOverlap = shParams["bin-overlap"])
    binVec = sum(binVec, dims = 2)
    replace!(ρ -> ρ >= 1 ? 1 : 0, binVec)
    binVec[:, 1]
  end

  return binVec
end

####################################################################################################

"""

    annotationCalibrator(xDf;
    startTime::Tm, recordFreq::V, signalLength::N, shParams::D, verbose::B = false)
      where Tm <: Time
      where V <: Vector{N}
      where N <: Number
      where D <: Dict
      where B <: Bool

# Description
Calibrate annotations from XLSX.

# Arguments
`xDf` annotations from XLSX file.

`startTime` signal start time.

`recordFreq` recording frecuency.

`signalLength` recording length.

`shParams` dictionary with command line arguments to extract: `binSize` window bin size and `binOverlap` overlap.

`verbose` set verbosity.


See also: [`annotationReader`](@ref), [`labelParser`](@ref)
"""
function annotationCalibrator(xDf; startTime::Tm, recordFreq::V, signalLength::N, shParams::D, verbose::B = false) where Tm <: Time where V <: Vector{N} where N <: Number where D <: Dict where B <: Bool

  # verbose
  if verbose @info "Calibrating annotations..." end

  # collect recording frecuency
  recFreq = begin
    recAv = (sum(recordFreq)) / (length(recordFreq))
    recAv |> π -> convert(Int64, π)
  end

  # fields to check
  fields = ["ST", "MA", "EM"]
  stepSize = floor(Int64, shParams["window-size"] / shParams["bin-overlap"])
  signalSteps = 1:stepSize:signalLength
  binArr = zeros(Int64, length(signalSteps), length(fields))

  for ο ∈ eachindex(fields)
    κ = fields[ο]

    # purge missing records on all columns
    toSupress = begin
      [ismissing(xDf[κ][j, i]) for j ∈ 1:size(xDf[κ], 1) for i ∈ 1:size(xDf[κ], 2)] |>
      π -> reshape(π, size(xDf[κ], 2), size(xDf[κ], 1)) |>
      π -> sum(π, dims = 1)
    end

    delete!(xDf[κ], (toSupress' .== size(xDf[κ], 2))[:, 1])

    # generate signal holder
    signalVec = zeros(signalLength)

    # collect annotations
    for ι ∈ 1:size(xDf[κ], 1)
      if !ismissing(xDf[κ][ι, :START]) & !ismissing(xDf[κ][ι, :END])
        emSt = xDf[κ][ι, :START] - startTime |> π -> convert(Dates.Second, π) |> π -> π.value * recFreq
        emEn = xDf[κ][ι, :END] - startTime |> π -> convert(Dates.Second, π) |> (π -> π.value * recFreq) |> π -> π + recFreq
        signalVec[emSt:emEn, :] .= 1
      else
        @warn "Annotation is not formatted properly & is not reliable"
      end
    end

    # binned signal
    binVec = begin
      binVec = extractSignalBin(signalVec, binSize = shParams["window-size"], binOverlap = shParams["bin-overlap"])
      binVec = sum(binVec, dims = 2)
      replace!(ρ -> ρ >= 1 ? 1 : 0, binVec)
      binVec = convert.(Int64, binVec)
      binVec[:, 1]
    end
    binArr[:, ο] = binVec
  end

  return binArr
end

####################################################################################################

"""

    labelParser(ɒ::M;
    verbose::B = false)
      where M <: Matrix{N}
      where N <: Number
      where B <: Bool

# Description
Parse three-column array into binary encoding.


See also: [`annotationReader`](@ref), See also: [`annotationCalibrator`](@ref)
"""
function labelParser(ɒ::M; verbose::B = false) where M <: Matrix{N} where N <: Number where B <: Bool

  # verbose
  if verbose @info "Parsing annotations..." end

  lbSz = size(ɒ, 1)
  tmpAr = Array{String}(undef, lbSz, 1)
  for ι ∈ 1:lbSz
    tmpAr[ι, 1] = string(ɒ[ι,  1], ɒ[ι, 2], ɒ[ι, 3],)
  end
  Ω = parse.(Int64, tmpAr, base = 2)
  Ω = reshape(Ω, (size(Ω, 1),))

  return Ω
end

####################################################################################################

"""

    annotationSummaryChannels(path::S, summaryFile::S)
      where S <: String

# Description
Extract channels from summary file [physionet]. Return a vector of strings.


See also: [`annotationCalibrator`](@ref), [`labelParser`](@ref)
"""
function annotationSummaryChannels(path::S, summaryFile::S; lineCount = 50) where S <: String
  Ω = Vector{String}(undef, 0)
  ç = 0
  for ł ∈ eachline(string(path, summaryFile))
    ç += 1
    if contains(ł, "Channel ") && ç <= lineCount
      push!(Ω, split(ł, " ")[end])
    end
  end
  return Ω
end

####################################################################################################

"obtain seizure time [physionet]"
function getSeizureSec(annot::S) where S <: String
  annot |> π -> findfirst(':', π) |> π -> getindex(annot, π + 2:length(annot)) |> π -> replace(π, " seconds" => "") |> Second
end

"obtain number seizure events [physionet]"
function getSeizureNo(annot::S) where S <: String
  annot |> π -> replace(π, "Number of Seizures in File: " => "") |> π -> parse(Int64, π)
end

"obtain file name [physionet]"
function getSeizureFile(annot::S) where S <: String
  annot |> π -> replace(π, "File Name: " => "") |> π -> replace(π, ".edf" => "")
end

####################################################################################################
