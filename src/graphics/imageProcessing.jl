################################################################################

function arFlipper(img::Array{Float64, 2})
  out = zeros(size(img) |> reverse)
  for i in 1:(size(img, 1))
    for j in 1:(size(img, 2))
      out[j, end + 1 - i] = img[i, j]
    end
  end
  return out
end

function arFlipper(img::Array{RGBA{Normed{UInt8,8}},2})
  out = Array{RGBA, 2}(undef, (size(img) |> reverse))
  for i in 1:(size(img, 1))
    for j in 1:(size(img, 2))
      out[j, end + 1 - i] = RGBA(img[i, j].r, img[i, j].g, img[i, j].b, img[i, j].alpha)
    end
  end
  return out
end

################################################################################
