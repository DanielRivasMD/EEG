####################################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

####################################################################################################

# load packages
begin
  using Chain: @chain

  # ai models
  using AImodels

  # Makie
  using CairoMakie

  # images
  using Images
end;

####################################################################################################

"wrapper over Makie image"
function renderImg(mt, out)

  # declare figure
  φ = Figure()

  # customize layout
  gl = φ[1, 1] = GridLayout()
  render = MakieLayout.Axis(gl[1, 1])

  # render image
  image!(render, mt)

  # hide decorations
  hidedecorations!(render)

  # save figure
  save(out, φ)

end

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
df = [readdf(string(mindHMM, "/", ι); sep = ',') for ι ∈ states]
df = hcat(df...)

####################################################################################################

# load image & permute dimensions
img = load("assets/EEGMontage.png") |> permutedims |> π -> π[:, end:-1:1]

####################################################################################################

# extract blue values
montageβ = @chain img begin
  map(χ -> findall(χ.b > 0), _)
  sum.(_)
  convert.(Float64, _)
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
extractPoints = [1215, 2800, 5000]

####################################################################################################

# iterate on extract points
for ι ∈ extractPoints

  ####################################################################################################

  # column counter
  ç = 0

  # redefine matrix
  toHeat = zeros(size(montageβ))

  # iterate on electrodes
  for (κ, υ) ∈ electrodes
    ç += 1
    if df[ι, ç] == 1
      toHeat[υ[1]:υ[1] + rangeSize, υ[2] - rangeSize:υ[2]] .= montageβ[υ[1]:υ[1] + rangeSize, υ[2] - rangeSize:υ[2]] .* -1
    else
      toHeat[υ[1]:υ[1] + rangeSize, υ[2] - rangeSize:υ[2]] .= montageβ[υ[1]:υ[1] + rangeSize, υ[2] - rangeSize:υ[2]] .* conicMask .* df[ι, ç]
    end
  end

  ####################################################################################################

  # normalize by min-max
  normHeat = minMax(toHeat)

  # clone image
  heatβ = copy(img)

  # iterate on rows & cols
  for ι ∈ eachindex(eachrow(heatβ)), ο ∈ eachindex(eachcol(heatβ))
    # substitute electrode positions
    if toHeat[ι, ο] > 0
      val = abs(normHeat[ι, ο] - 1)
      val > 1 && @info ι, ο, normHeat[ι, ο]
      heatβ[ι, ο] = RGBA(1, val, val, img[ι, ο].alpha)
    end
  end

  ####################################################################################################

  # render image
  renderImg(heatβ, string(dataDir, "/", "heatmap", ι, ".svg"))

  ####################################################################################################

end

####################################################################################################
