####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load project enviroment
using Pkg
if Pkg.project().path != string(projDir, "/Project.toml")
  Pkg.activate(projDir)
end

####################################################################################################

# load packages
begin
  using Images

  # Makie
  using CairoMakie
end;

####################################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
  include(string(utilDir, "/electrodeCoor.jl"))
end;

####################################################################################################

# identify files to load
states = @chain begin
  readdir(mindHMM)
  filter(χ -> occursin("chb04_28", χ), _)
  filter(χ -> occursin("traceback", χ), _)
end

####################################################################################################

# read files into dataframe array & concatenate
df = [readdf(string(mindHMM, "/", ι), ',') for ι ∈ states]
df = hcat(df...)

####################################################################################################

# sample row
# DataFrameRow
#   Row │ C3-P3    C4-P4    CZ-PZ    F3-C3    F4-C4    F7-T7    F8-T8    FP1-F3   FP1-F7   FP2-F4   FP2-F8   FT10-T8  FT9-FT10  FZ-CZ    P3-O1    P4-O2    P7-O1    P7-T7    P8-O2    T7-FT9   T7-P7    T8-P8
#       │ Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64   Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64  Float64
# ──────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  1215 │     3.0      1.0      1.0      4.0      3.0      2.0      2.0      2.0      5.0      2.0      3.0      2.0       2.0      2.0      2.0      2.0      2.0      2.0      2.0      2.0      3.0      2.0
sampleRow = [3.0, 1.0, 1.0, 4.0, 3.0, 2.0, 2.0, 2.0, 5.0, 2.0, 3.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 3.0, 2.0]

 ####################################################################################################

# load image & permute dimensions
img = load("assets/EEGMontage.png") |> permutedims |> π -> π[:, end:-1:1]

φ = Figure()

gl = φ[1, 1] = GridLayout()
render = MakieLayout.Axis(gl[1, 1])

# render image
image!(render, img)

# hide decorations
hidedecorations!(render)

# save figure
save("data/img.svg", φ)

####################################################################################################

# extract blue values
montageβ = @chain img begin
  map(χ -> findall(χ.b > 0), _)
  sum.(_)
  convert.(Float64, _)
end

####################################################################################################

# image post masking
imgβ = Array{RGBA, 2}(undef, size(img))
for ι ∈ eachindex(eachrow(imgβ)), ο ∈ eachindex(eachcol(imgβ))
  if !(montageβ[ι, ο] |> π -> convert(Bool, π))
    imgβ[ι, ο] = RGBA(img[ι, ο].r, img[ι, ο].g, img[ι, ο].b, img[ι, ο].alpha)
  else
    imgβ[ι, ο] = RGBA(0, 0, 0, 0)
  end
end

####################################################################################################

# conic mask
conicMask = @chain begin
  range(0, 3, length = 101)
  [sin(ι) * sin(ο) for ι ∈ _, ο ∈ _]
end

####################################################################################################

# preallocate matrix
rangeSize = 100

# defined arbitrary extract points
extractPoints = [500, 2800, 5000]

####################################################################################################

# iterate on extract points
for ι ∈ extractPoints

  # BUG: electrodes is an unipolar dictionary
  # use arbitrary electrodes to generate image
  γ = 0

  # redefine matrix
  toHeat = zeros(size(montageβ))

  # iterate on electrodes
  for (κ, υ) ∈ electrodes
    γ += 1
    toHeat[υ[1]:υ[1] + rangeSize, υ[2] - rangeSize:υ[2]] .= montageβ[υ[1]:υ[1] + rangeSize, υ[2] - rangeSize:υ[2]] .* conicMask .* df[ι, γ]
  end

  # write
  writedlm(
    string(mindCSV, "/", "EEGMontage", ι, ".csv"),
    toHeat,
    ',',
  )

end

####################################################################################################
