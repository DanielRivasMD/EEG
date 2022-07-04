

################################################################################

# load packages
using DelimitedFiles
using Plots
using RCall

################################################################################

# import R GenomicFunctions
R"library('GenomicFunctions')";

################################################################################

# load modules
utilDir    = "/Users/drivas/Factorem/MindReader/src/Utilities/"
include(string(utilDir,    "fileReaderEDF.jl"))

signalDir = "/Users/drivas/Factorem/MindReader/src/SignalProcessing/"
include(string(signalDir,  "signalBin.jl"))

annotDir   = "/Users/drivas/Factorem/MindReader/src/Annotator/"
include(string(annotDir,   "annotationCalibrator.jl"))

################################################################################

# edf binning settings
winBin = 256
overlap = 4

################################################################################

# declare paths
dir = "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/"
xfile = "chb04-summary.txt"
annotFile = annotationReader(string(dir, xfile))

patient = readdir(dir)
patientRecords = patient |> p -> match.(r"edf$", p) |> p -> findall(!isnothing, p) |> p -> getindex(patient, p)

d = readdir("/Users/drivas/Factorem/MindReader/data/hmm")

# read files
for file ∈ patientRecords

  # define state files
  prefix = replace(file, ".edf" => "")
  files = d |> p -> match.(Regex(string(prefix, "_(.*)states")), p) |> p -> findall(!isnothing, p) |> p -> getindex(d, p)

  # electrode labels
  ly = Vector{String}()

  # load data
  for (c, f) ∈ enumerate(files)
    k = f |> p -> replace(p, string(prefix, "_") => "") |> p -> replace(p, "_states.csv" => "")
    # @info k
    push!(ly, k)
    mod =  readdlm(string("/Users/drivas/Factorem/MindReader/data/hmm/", f))
    if c == 1
      global lx = 1:size(mod, 1) - 1 |> collect
      global pt = Matrix{Int64}(undef, length(files), length(lx))
    end
    pt[c, :] .= mod[2:end, 1] |> p -> convert.(Int64, p)
  end

  # read edf
  edfDf, startTime, recordFreq = getSignals(string(dir, file))

  # load & parse annoations
  if haskey(annotFile, prefix)

    labelAr = annotationCalibrator(
      annotFile[prefix],
      startTime = startTime,
      recordFreq = recordFreq,
      signalLength = size(edfDf, 1),
      binSize = winBin,
      binOverlap = overlap
    )

  end

  # loop over channels & identify peaks
  frThres = 120
  ct = 0
  for r ∈ eachrow(pt)
    R"tmp <- peakIden($r, 2)"
    @rget tmp
    ct += 1
    insertcols!(tmp, :channel => ct)
    pgTmp = filter(:peakLengthIx => x -> x >= frThres, tmp)
    if r == pt[1, :]
      global df = tmp
      global pgDf = pgTmp
    else
      df = [df; tmp]
      pgDf = [pgDf; pgTmp]
    end

    # calculate sensitivity & specificity (event-based)
    if haskey(annotFile, prefix)

      R"
      lab <- peakIden($labelAr)
      matchesRaw <- sharedCoor(lab[, 2:3], tmp[, 2:3], 'Annoation', 'Model')
      matchesPur <- sharedCoor(lab[, 2:3], $pgTmp[, 2:3], 'Annoation', 'Model')
      "

    end

  end

  # create mask
  ms = ones(Int64, size(pt))

  for r ∈ eachrow(pgDf)
    ms[r.channel, convert(Int64, r.lowerLimIx):convert.(Int64, r.upperLimIx)] .= 2
  end

  # plot
  if haskey(annotFile, prefix)
    heatmap(labelAr |> permutedims, framestyle = :none, leg = :none, title = string("Annotation: ", file), dpi = 300) |> display
  end

  heatmap(lx, ly, pt, framestyle = :semi, leg = :none, ytickfontsize = 4, yticks = ([0.5:length(ly) - 0.5...], ly), title = string("MindReader: ", file), dpi = 300) |> display
  heatmap(lx, ly, ms, framestyle = :semi, leg = :none, ytickfontsize = 4, yticks = ([0.5:length(ly) - 0.5...], ly), title = string("Masked: ", file), dpi = 300) |> display

end

