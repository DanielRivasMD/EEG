################################################################################

using CairoMakie
using MakieLayout
using AbstractPlotting
using Images
using JLD2

################################################################################

file = "/Users/drivas/Factorem/EEG/Data/patientEEG/0040AE.edf"
xfile = "/Users/drivas/Factorem/EEG/Data/patientEEG/0040AE.xlsx"
winBin = 128
overlap = 4

################################################################################

begin
  ftrim = replace(file, r".+/" => "")
  ftrim = replace(ftrim, ".edf" => "")
end

################################################################################

utilDir = "../utilitiesJL/"

# load functions
@info("Loading modules...")
include(string(utilDir, "fileReader.jl"));

include(string(utilDir, "imageProcessing.jl"));
include(string(utilDir, "electrodeCoor.jl"));

include(string(utilDir, "signalBin.jl"));
# include(string(utilDir, "FFT.jl"));
# include(string(utilDir, "shapeShifter.jl"));
include(string(utilDir, "annotationCalibrator.jl"));
# include(string(utilDir, "EHMM.jl"));
# include(string(utilDir, "architect.jl"));
# include(string(utilDir, "autoencoder.jl"));
# include(string(utilDir, "screening.jl"));

################################################################################

# load data
# @load "outDir/0040AE_postDcChFFTA3.jld2"
@load "outDir/0040AE_errDcChFFTA3.jld2"
# @load "outDir/0040AE_compDcChFFTA3.jld2"

################################################################################

# read edf file
edfDf, startTime, recordFreq, electrodeID = getSignals(file)

# read xlsx file
xDf = xread(xfile)

# labels array
labelAr = annotationCalibrator(
  xDf,
  startTime = startTime,
  recordFreq = recordFreq,
  signalLength = size(edfDf, 1),
  binSize = winBin,
  binOverlap = overlap,
) .+= 1 # adjust labels

################################################################################

img = load("assets/EEGMontage.png")
img = arFlipper(img)

################################################################################

βmontage = map(x -> findall(x.b > 0), img) .|> sum .|> p -> convert(Float64, p)
βMask = convert.(Bool, βmontage)

################################################################################

βimg = Array{RGBA, 2}(undef, size(img))
for i in 1:(size(βimg, 1))
  for j in 1:(size(βimg, 2))
    if ! βMask[i, j]
      βimg[i, j] = RGBA(img[i, j].r, img[i, j].g, img[i, j].b, img[i, j].alpha)
    else
      βimg[i, j] = RGBA(0, 0, 0, 0)
    end
  end
end

################################################################################

conicRange = range(0, 3, length = 101)
conicMask = [sin(i) * sin(j) for i in conicRange, j in conicRange]

################################################################################

cPal = [:black, :gray, :red, :green, :yellow, :blue, ]

################################################################################

step = convert(Int64, winBin / overlap)
frames = range(1, step = step, length = length(errDc[electrodeID[1]][1]))


for ix in eachindex(frames)
  frame = frames[ix]

  scene, layout = layoutscene(resolution = (1200, 900));

  # plotting channels
  axesDc = Dict()
  for ex in eachindex(electrodeID)
    k = electrodeID[ex]
    axesDc[k] = layout[ex, 1] = LAxis(scene)
    lines!(axesDc[k], edfDf[frame:(frame + step), ex], color = cPal[errDc[k][1][ix]], linewidth = 2)
    hidedecorations!(axesDc[k])
    hidespines!(axesDc[k])
    layout[ex, 1, Left()] = LText(scene, k, textsize = 35,
      font = "Noto Sans Bold", halign = :right)
  end

  ################################################################################

  toHeat = zeros(size(βmontage))
  for (k, v) in electrodes
    toHeat[v[1]:v[1] + 100, v[2] - 100:v[2]] .=  βmontage[v[1]:v[1] + 100, v[2] - 100:v[2]] .* conicMask .* errDc[k][1][ix]
  end

  ################################################################################

  # plotting heatmap
  axHm = layout[:, 2] = LAxis(scene)
  image!(axHm, toHeat, colormap = :amp, transparency = true)
  image!(axHm, βimg, transparency = true)
  hidedecorations!(axHm)
  hidespines!(axHm)

  ################################################################################

  colsize!(layout, 1, Relative(1/3))

  save(string("tmpDir/", ftrim, ix, ".png"), scene, pt_per_unit = 0.5)
  # save(string(ftrim, ix, ".svg"), scene, pt_per_unit = 0.5)

  ################################################################################

end

################################################################################
