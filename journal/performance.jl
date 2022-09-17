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
  peak_iden <- function(

    f_seq,
    d_threshold = NULL
  ) {

    if (is.null(d_threshold)) d_threshold <- 1
    f_seq <- c(0, f_seq, 0)
    f_threseq <- which(f_seq >= d_threshold)
    f_peak_length <- which(f_seq[f_threseq + 1] < d_threshold) - which(f_seq[f_threseq-1] < d_threshold) + 1
    f_upper_lim_ix <- (f_threseq[cumsum(f_peak_length)]) - 1
    f_lower_lim_ix <- f_upper_lim_ix - f_peak_length + 1
    peak_feat <- data.frame(peak_no = seq_along(f_lower_lim_ix), lower_lim_ix = f_lower_lim_ix, upper_lim_ix = f_upper_lim_ix, peak_length_ix = f_peak_length)

    return(peak_feat)
  }
  "
end;

####################################################################################################

begin
  # load data
  files = readdir(mindHMM)

  file = files |> π -> match.(r"chb04_28_(.*)states", π) |> π -> findall(!isnothing, π) |> π -> getindex(files, π)

  smp = 57692

  pt = Matrix{Int64}(undef, 22, 57692)
  lx = 1:smp |> collect
  ly = Vector{String}()

  for (ι, ƒ) ∈ enumerate(file)
    ψ = ƒ |> π -> replace(π, "chb04_28_" => "") |> π -> replace(π, "_states.csv" => "")
    @info ψ
    push!(ly, ψ)
    pt[ι, :] .= readdlm(string(mindHMM, "/", ƒ))[2:end, 1] |> π -> convert.(Int64, π)
  end

  utilDir = string(mindDir, "/src/Utilities/")
  include(string(utilDir, "readEDF.jl"))

  signalDir = string(mindDir, "/src/SignalProcessing/")
  include(string(signalDir, "signalBin.jl"))

  annotDir = string(srcDir, "/annotation/functions/")
  include(string(annotDir, "annotationCalibrator.jl"))

  dir = string(dataDir, "/physionet.org/files/chbmit/1.0.0/chb04/")
  xfile = "chb04-summary.txt"
  annotFile = annotationReader(dir, xfile)
  file = "chb04_28.edf"
  outimg = replace(file, ".edf" => "")

  edfDf, startTime, recordFreq = getSignals(string(dir, file))

  winBin = 256
  overlap = 4

  labelAr = annotationCalibrator(
    annotFile[outimg];
    recordFreq = recordFreq,
    signalLength = size(edfDf, 1),
    shParams = Dict(
      "window-size" => winBin,
      "bin-overlap" => overlap,
    )
  )

  frThres = 120
  ç = 0
  for ρ ∈ eachrow(pt)

    R"
    tmp <- peak_iden($ρ, 2)
    "

    @rget tmp
    global ç += 1
    insertcols!(tmp, :channel => ç)
    pgTmp = filter(:peak_length_ix => χ -> χ >= frThres, tmp)
    if ρ == pt[1, :]
      global δ = tmp
      global pgDf = pgTmp
    else
      δ = [δ; tmp]
      pgDf = [pgDf; pgTmp]
    end
  end

  ms = ones(Int64, size(pt))

  for r ∈ eachrow(pgDf)
    ms[r.channel, convert(Int64, r.lower_lim_ix):convert.(Int64, r.upper_lim_ix)] .= 2
  end

  annotSJTime = [
             "00:09:50"
             "00:15:40"
             "00:28:30"
             "00:32:35"
             "01:07:43"
            ]

  annotSJSec = Dates.Time.(annotSJTime) .- Dates.Time("0") |> p -> convert.(Second, p)
  annotSJ = [(annotSJSec[i], annotSJSec[i] + Second(60)) for i = eachindex(annotSJTime)]

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

hmASJ = heatmap(labelSJ |> permutedims, framestyle = :none, leg = :none, title = "SanJuan / Angel Annotations")
hmAPh = heatmap(labelAr |> permutedims, framestyle = :none, leg = :none, title = "Physionet Annotations")
hmRec = heatmap(lx, ly, pt, framestyle = :semi, leg = :none)
hmMas = heatmap(lx, ly, ms, framestyle = :semi, leg = :none)
plot(hmASJ, hmAPh, hmRec, hmMas, layout = grid(4, 1, heights = [0.05, 0.05, 0.45, 0.45]), dpi = 300)

####################################################################################################

δ |> π -> sort(π, :peak_length_ix, rev = true) |> π -> bar(π[:, :peak_length_ix], leg = :none, dpi = 300)

####################################################################################################
