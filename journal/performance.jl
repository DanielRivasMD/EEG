####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using DataFrames
  using DelimitedFiles
  using EDF
  using Plots
  using RCall
end;

####################################################################################################

begin
  # declare peak identification function
  R"
  peakIden <- function(

    f_seq,
    d_threshold = NULL
  ) {

    if (is.null(d_threshold)) d_threshold <- 1
    f_seq <- c(0, f_seq, 0)
    f_threseq <- which(f_seq >= d_threshold)
    f_peak_length <- which(f_seq[f_threseq + 1] < d_threshold) - which(f_seq[f_threseq-1] < d_threshold) + 1
    f_upperLimIx <- (f_threseq[cumsum(f_peak_length)]) - 1
    f_lowerLimIx <- f_upperLimIx - f_peak_length + 1
    peak_feat <- data.frame(peak_no = seq_along(f_lowerLimIx), lowerLimIx = f_lowerLimIx, upperLimIx = f_upperLimIx, peakLengthIx = f_peak_length)

    return(peak_feat)
  }
  "
end;

####################################################################################################

begin

  # read available files
  files = readdir(mindHMM)

  # load data
  file = files |> π -> match.(r"chb04_28_(.*)states", π) |> π -> findall(!isnothing, π) |> π -> getindex(files, π)

  # declare variables
  begin
    smp = 57692
    pt = Matrix{Int64}(undef, 22, 57692)
    lx = 1:smp |> collect
    ly = Vector{String}()

    dir = string(dataDir, "/physionet.org/files/chbmit/1.0.0/chb04/")
    xfile = "chb04-summary.txt"
    file = "chb04_28.edf"
    outimg = replace(file, ".edf" => "")

    winBin = 256
    overlap = 4
  end;

  # load channels
  for (ι, ƒ) ∈ enumerate(file)
    ψ = ƒ |> π -> replace(π, "chb04_28_" => "") |> π -> replace(π, "_states.csv" => "")
    @info ψ
    push!(ly, ψ)
    pt[ι, :] .= readdlm(string(mindHMM, "/", ƒ))[2:end, 1] |> π -> convert.(Int64, π)
  end

  # load functions
  begin
    utilDir = string(mindDir, "/src/Utilities/")
    include(string(utilDir, "readEDF.jl"))

    signalDir = string(mindDir, "/src/SignalProcessing/")
    include(string(signalDir, "signalBin.jl"))

    annotDir = string(srcDir, "/annotation/functions/")
    include(string(annotDir, "annotationCalibrator.jl"))
  end;

  # read edf file
  edfDf, startTime, recordFreq = getSignals(string(dir, file))

  # read annotation
  annotFile = annotationReader(dir, xfile)
  labelAr = annotationCalibrator(
    annotFile[outimg];
    recordFreq = recordFreq,
    signalLength = size(edfDf, 1),
    shParams = Dict(
      "window-size" => winBin,
      "bin-overlap" => overlap,
    )
  )

  # filter frames
  frThres = 120
  ç = 0
  for ρ ∈ eachrow(pt)

    # identify peaks
    R"
    tmp <- peakIden($ρ, 2)
    "
    @rget tmp

    # load into dataframe
    global ç += 1
    insertcols!(tmp, :channel => ç)
    pgTmp = filter(:peakLengthIx => χ -> χ >= frThres, tmp)
    if ρ == pt[1, :]
      global δ = tmp
      global pgDf = pgTmp
    else
      δ = [δ; tmp]
      pgDf = [pgDf; pgTmp]
    end
  end

  # prepare canvas matrix
  ms = ones(Int64, size(pt))

  # load canvas matrix
  for ρ ∈ eachrow(pgDf)
    ms[ρ.channel, convert(Int64, ρ.lowerLimIx):convert.(Int64, ρ.upperLimIx)] .= 2
  end

  # declare manual annotations
  annotSJTime = [
    "00:09:50"
    "00:15:40"
    "00:28:30"
    "00:32:35"
    "01:07:43"
  ]

  # format annotations
  annotSJSec = Dates.Time.(annotSJTime) .- Dates.Time("0") |> p -> convert.(Second, p)
  annotSJ = [(annotSJSec[i], annotSJSec[i] + Second(60)) for i = eachindex(annotSJTime)]

  # load manual annotations
  labelSJ= annotationCalibrator(
    annotSJ,
    recordFreq = recordFreq,
    signalLength = size(edfDf, 1),
    shParams = Dict(
      "window-size" => winBin,
      "bin-overlap" => overlap,
    )
  )

end;

####################################################################################################

# plot heatmaps
hmASJ = heatmap(labelSJ |> permutedims, framestyle = :none, leg = :none, title = "SanJuan / Angel Annotations");
hmAPh = heatmap(labelAr |> permutedims, framestyle = :none, leg = :none, title = "Physionet Annotations");
hmRec = heatmap(lx, ly, pt, framestyle = :semi, leg = :none);
hmMas = heatmap(lx, ly, ms, framestyle = :semi, leg = :none);
plot(hmASJ, hmAPh, hmRec, hmMas, layout = grid(4, 1, heights = [0.05, 0.05, 0.45, 0.45]), dpi = 300)

####################################################################################################

# barplot peak distribution
δ |> π -> sort(π, :peakLengthIx, rev = true) |> π -> bar(π[:, :peakLengthIx], leg = :none, dpi = 300)

####################################################################################################
