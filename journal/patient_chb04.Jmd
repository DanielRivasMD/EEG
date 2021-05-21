################################################################################

# load packages
using DelimitedFiles
using Plots
using RCall

################################################################################

# import R functions
begin

  # declare peak identification function
  R"
  peak_iden <- function(

    f_seq,
    d_threshold = NULL
  ) {

    if ( is.null(d_threshold) ) d_threshold <- 1
    f_seq <- c(0, f_seq, 0)
    f_threseq <- which(f_seq >= d_threshold)
    f_peak_length <- which(f_seq[f_threseq + 1] < d_threshold) - which(f_seq[f_threseq-1] < d_threshold) + 1
    f_upper_lim_ix <- (f_threseq[cumsum(f_peak_length)]) - 1
    f_lower_lim_ix <- f_upper_lim_ix - f_peak_length + 1
    peak_feat <- data.frame(peak_no = seq_along(f_lower_lim_ix), lower_lim_ix = f_lower_lim_ix, upper_lim_ix = f_upper_lim_ix, peak_length_ix = f_peak_length)

    return(peak_feat)
  }
  "

  # declare range assembler function
  R"
  range_assembler <- function(

    f_data,
    b_genom = TRUE
  ) {

    f_data <- as.data.frame(f_data)
    if ( b_genom ) {
      f_out <- GenomicRanges::GRanges(
        seqnames = f_data[, 3],
        ranges = IRanges::IRanges(
          start = f_data[, 1],
          end = f_data[, 2]
        )
      )
    } else {
      f_out <- IRanges::IRanges(
        start = f_data[, 1],
        end = f_data[, 2]
      )
    }

    return(f_out)
  }
  "

  # declare share coordinate function
  R"
  shared_coor <- function(

    f_query,
    f_subj,
    query,
    subj,
    d_genomic = FALSE
  ) {

    f_query_ranges <- range_assembler(f_query, b_genom = d_genomic)
    f_subj_ranges <- range_assembler(f_subj, b_genom = d_genomic)

    f_query_subj <- as.data.frame(IRanges::findOverlaps(f_query_ranges, f_subj_ranges))
    colnames(f_query_subj) <- c(query, subj)
    shared_pos_ls <- list(f_query[f_query_subj[, query], ], f_subj[f_query_subj[, subj], ])
    names(shared_pos_ls) <- c(query, subj)

    return(shared_pos_ls)
  }
  "

end;

################################################################################

# load modules
utilDir    = "/Users/drivas/Factorem/MindReader/src/Utilities/"
include( string(utilDir,    "fileReaderEDF.jl") )

signalDir = "/Users/drivas/Factorem/MindReader/src/SignalProcessing/"
include( string(signalDir,  "signalBin.jl") )

annotDir   = "/Users/drivas/Factorem/MindReader/src/Annotator/"
include( string(annotDir,   "annotationCalibrator.jl") )

################################################################################

# edf binning settings
winBin = 256
overlap = 4

################################################################################

# manual annoations. file chb04_28
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
  startTime = startTime,
  recordFreq = recordFreq,
  signalLength = size(edfDf, 1),
  binSize = winBin,
  binOverlap = overlap
)

################################################################################

# declare paths
dir = "/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/chb04/"
xfile = "chb04-summary.txt"
annotFile = annotationReader( string(dir, xfile) )

patient = readdir(dir)
patientRecords = patient |> p -> match.(r"edf$", p) |> p -> findall(!isnothing, p) |> p -> getindex(patient, p)

d = readdir("/Users/drivas/Factorem/MindReader/data/hmm")

hmRec = Vector{Plots.Plot}()
hmMas = Vector{Plots.Plot}()

# read files
for file ∈ patientRecords

  # define state files
  prefix = replace(file, ".edf" => "")
  files = d |> p -> match.(Regex( string(prefix, "_(.*)states") ), p) |> p -> findall(!isnothing, p) |> p -> getindex(d, p)

  # electrode labels
  ly = Vector{String}()

  # load data
  for (c, f) ∈ enumerate(files)
    k = f |> p -> replace(p, string(prefix, "_") => "") |> p -> replace(p, "_states.csv" => "")
    @info k
    push!(ly, k)
    mod =  readdlm( string("/Users/drivas/Factorem/MindReader/data/hmm/", f) )
    if c == 1
      global lx = 1:size(mod, 1) - 1 |> collect
      global pt = Matrix{Int64}(undef, length(files), length(lx))
    end
    pt[c, :] .= mod[2:end, 1] |> p -> convert.(Int64, p)
  end

  # read edf
  edfDf, startTime, recordFreq = getSignals( string(dir, file) )

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
    R"tmp <- peak_iden($r, 2)"
    @rget tmp
    global ct += 1
    insertcols!(tmp, :channel => ct)
    pgTmp = filter(:peak_length_ix => x -> x >= frThres, tmp)
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
      lab <- peak_iden($labelAr)
      matchesRaw <- shared_coor(lab[, 2:3], tmp[, 2:3], 'Annoation', 'Model')
      matchesPur <- shared_coor(lab[, 2:3], $pgTmp[, 2:3], 'Annoation', 'Model')
      "

    end

  end

  # create mask
  ms = ones(Int64, size(pt))

  for r ∈ eachrow(pgDf)
    ms[r.channel, convert(Int64, r.lower_lim_ix):convert.(Int64, r.upper_lim_ix)] .= 2
  end

  # push!(hmRec, heatmap(lx, ly, pt, framestyle = :semi, leg = :none, ytickfontsize = 4, yticks = ([0.5:length(ly) - 0.5...], ly)))
  # push!(hmMas, heatmap(lx, ly, ms, framestyle = :semi, leg = :none, ytickfontsize = 4, yticks = ([0.5:length(ly) - 0.5...], ly)))

end

# plot(
#   # hmRec[1],
#   # hmRec[2],
#   # hmRec[3],
#   # hmRec[4],
#   # hmRec[5],
#   hmRec[6],
#   hmRec[7],
#   hmRec[8],
#   hmRec[9],
#   hmRec[10],
#   # hmRec[11],
#   # hmRec[12],
#   # hmRec[13],
#   # hmRec[14],
#   # hmRec[15],
#   # hmRec[16],
#   # hmRec[17],
#   # hmRec[18],
#   # hmRec[19],
#   # hmRec[20],
#   # hmRec[21],
#   # hmRec[22],
#   # hmRec[23],
#   # hmRec[24],
#   # hmRec[25],
#   # hmRec[26],
#   # hmRec[27],
#   # hmRec[28],
#   # hmRec[29],
#   # hmRec[30],
#   # hmRec[31],
#   # hmRec[32],
#   # hmRec[33],
#   # hmRec[34],
#   # hmRec[35],
#   # hmRec[36],
#   # hmRec[37],
#   # hmRec[38],
#   # hmRec[39],
#   # hmRec[40],
#   # hmRec[41],
#   # hmRec[42],
#   layout = grid(5, 1)
# )
#
#
#
# plot(
#   # hmMas[1],
#   # hmMas[2],
#   # hmMas[3],
#   # hmMas[4],
#   # hmMas[5],
#   hmMas[6],
#   hmMas[7],
#   hmMas[8],
#   hmMas[9],
#   hmMas[10],
#   # hmMas[11],
#   # hmMas[12],
#   # hmMas[13],
#   # hmMas[14],
#   # hmMas[15],
#   # hmMas[16],
#   # hmMas[17],
#   # hmMas[18],
#   # hmMas[19],
#   # hmMas[20],
#   # hmMas[21],
#   # hmMas[22],
#   # hmMas[23],
#   # hmMas[24],
#   # hmMas[25],
#   # hmMas[26],
#   # hmMas[27],
#   # hmMas[28],
#   # hmMas[29],
#   # hmMas[30],
#   # hmMas[31],
#   # hmMas[32],
#   # hmMas[33],
#   # hmMas[34],
#   # hmMas[35],
#   # hmMas[36],
#   # hmMas[37],
#   # hmMas[38],
#   # hmMas[39],
#   # hmMas[40],
#   # hmMas[41],
#   # hmMas[42],
#   layout = grid(5, 1)
# )



hmASJ = heatmap(labelSJ |> permutedims, framestyle = :none, leg = :none, ytickfontsize = 4, yticks = ([1], ["SanJuan / Angel"]))
hmAPh = heatmap(labelAr |> permutedims, framestyle = :none, leg = :none, ytickfontsize = 4, yticks = ([1], ["Physionet"]))
hmRec = heatmap(lx, ly, pt, framestyle = :semi, leg = :none, ytickfontsize = 4, yticks = ([0.5:length(ly) - 0.5...], ly))
hmMas = heatmap(lx, ly, ms, framestyle = :semi, leg = :none, ytickfontsize = 4, yticks = ([0.5:length(ly) - 0.5...], ly))
plot(hmASJ, hmAPh, hmRec, hmMas, layout = grid(4, 1, heights = [0.05, 0.05, 0.45, 0.45]), dpi = 300)



df |> p -> sort(p, :peak_length_ix, rev = true) |> p -> bar(p[:, :peak_length_ix], leg = :none, dpi = 300)
