################################################################################

# declarations
begin
  include("/Users/drivas/Factorem/EEG/src/config/config.jl")
end;

################################################################################

# load project enviroment
using Pkg
if Pkg.project().path != string(projDir, "/Project.toml")
  Pkg.activate(projDir)
end

################################################################################

# load packages
begin
  using Images
end;

################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
  include(string(utilDir, "/electrodeCoor.jl"))
end;

################################################################################

# load backtrace dataframe
df = readdf("/Users/drivas/Factorem/MindReader/data/csv/sample.csv", ',')

################################################################################

# load image & permute dimensions
img = load("assets/EEGMontage.png") |> permutedims

################################################################################

# extract blue values
montageβ = @chain img begin
  map(χ -> findall(χ.b > 0), _)
  sum.(_)
  convert.(Float64, _)
end

################################################################################

# image post masking
imgβ = Array{RGBA,2}(undef, size(img))
for ι ∈ 1:(size(imgβ, 1))
  for ο ∈ 1:(size(imgβ, 2))
    if !(montageβ[ι, ο] |> π -> convert(Bool, π))
      imgβ[ι, ο] = RGBA(img[ι, ο].r, img[ι, ο].g, img[ι, ο].b, img[ι, ο].alpha)
    else
      imgβ[ι, ο] = RGBA(0, 0, 0, 0)
    end
  end
end

################################################################################

# conic mask
conicMask = @chain begin
  range(0, 3, length=101)
  [sin(ι) * sin(ο) for ι ∈ _, ο ∈ _]
end

################################################################################

# preallocate matrix
rangeSize = 100

# defined arbitrary extract points
extractPoints = [500, 2800, 5000]

################################################################################

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

################################################################################
