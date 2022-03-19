################################################################################

using Images
using GLMakie, AbstractPlotting
using JLD2

################################################################################

utilDir = "../utilitiesJL/"

################################################################################

# load functions
@info "Loading modules..."
include(string(utilDir, "imageProcessing.jl"));
include(string(utilDir, "electrodeCoor.jl"));

################################################################################

# load data
@load "outDir/0036LR_postDcChFFTA3.jld2"
@load "outDir/0036LR_errDcChFFTA3.jld2"
@load "outDir/0036LR_compDcChFFTA3.jld2"


################################################################################

img = load("assets/EEGMontage.png")
img = arFlipper(img)

################################################################################

# αmontage = map(x -> findall(x.alpha > 0), img) .|> sum .|> p -> convert(Float64, p)
# αMask = convert.(Bool, αmontage)
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

frames = 1:50
framerate = 2

scene = image(βimg, show_axis = false);
# xlabel!("")
# ylabel!("")
record(scene, "0036LR_errDcChFFTA3.mp4", frames; framerate = framerate) do frame
  @info frame
  toHeat = zeros(size(βmontage))
  for (k, v) in electrodes
    toHeat[v[1]:v[1] + 100, v[2] - 100:v[2]] .=  βmontage[v[1]:v[1] + 100, v[2] - 100:v[2]] .* conicMask .* errDc[k][1][frame]
  end
  heatmap!(toHeat, colormap = :amp)
end

################################################################################

frames = 1:50
framerate = 2

scene = image(βimg, show_axis = false);
# xlabel!("")
# ylabel!("")
record(scene, "0036LR_postDcChFFTA3.mp4", frames; framerate = framerate) do frame
  @info frame
  toHeat = zeros(size(βmontage))
  for (k, v) in electrodes
    toHeat[v[1]:v[1] + 100, v[2] - 100:v[2]] .=  βmontage[v[1]:v[1] + 100, v[2] - 100:v[2]] .* conicMask .* postDc[k][1][frame]
  end
  heatmap!(toHeat, colormap = :amp)
end

################################################################################

frames = 1:50
framerate = 2

scene = image(βimg, show_axis = false);
# xlabel!("")
# ylabel!("")
record(scene, "0036LR_compDcChFFTA3.mp4", frames; framerate = framerate) do frame
  @info frame
  toHeat = zeros(size(βmontage))
  for (k, v) in electrodes
    toHeat[v[1]:v[1] + 100, v[2] - 100:v[2]] .=  βmontage[v[1]:v[1] + 100, v[2] - 100:v[2]] .* conicMask .* compDc[k][1][frame]
  end
  heatmap!(toHeat, colormap = :amp)
end

################################################################################

# for (k, v) in electrodes
#   βmontage[v[1]:v[1] + 100, v[2]:v[2] + 100] .*= conicMask # (conicMask .* f)
# end

################################################################################

# xs = Array{Int64, 1}(undef, 21)
# ys = Array{Int64, 1}(undef, 21)
# c = 0
# for (k, v) in electrodes
#   global c += 1
#   xs[c] = v[1]
#   ys[c] = v[2]
# end
#
# flipElec = [ys 1074 .- xs]

# for i in 1:(size(flipElec, 1))
#   βmontage[flipElec[i, 1]:flipElec[i, 1] + 100, flipElec[i, 2] - 100:flipElec[i, 2]] .*= conicMask
# end

################################################################################

# @pipe βmontage |> heatmap(_, colormap = :Blues_3)
# βimg |> image!
# xlabel!("")
# ylabel!("")

################################################################################

# record(scene, "append_animation.mp4", frames; framerate = 30) do frame
#   new_point = Point2f0(frame, frame)
#   points[] = push!(points[], new_point)
# end
#
# record(scene, "phase_animation.mp4", framerate = framerate) do t
#   for (k, v) in electrodes
#     f = rand(1:5, 1)[1]
#     @info "$k = $f"
#     montage[v[1]:v[1] + 100, v[2]:v[2] + 100] .*= (conicMask .* f)
#   end
# end

################################################################################

# intImg = zeros(size(img))
# for ix in 1:size(img, 1)
#   for jx in 1:size(img, 2)
#     intImg[ix, jx] = img[ix, jx].r
#   end
# end

# amontage = map(x -> findall(x.alpha > 0), img) .|> sum .|> p -> convert(Float64, p)
# montage = map(x -> findall(x.alpha > 0), toPlot) .|> sum .|> p -> convert(Float64, p)

# rmontage = map(x -> findall(x.r > 0), img) .|> sum .|> p -> convert(Float64, p)
# gmontage = map(x -> findall(x.g > 0), img) .|> sum .|> p -> convert(Float64, p)
# bmontage = map(x -> findall(x.b > 0), img) .|> sum .|> p -> convert(Float64, p)
# montage = map(x -> findall(x.r > 0), toPlot) .|> sum .|> p -> convert(Float64, p)


# toPlot = Array{RGB, 2}(undef, size(img, 2),  size(img, 1))
# for i in 1:(size(img, 1))
#   for j in 1:(size(img, 2))
#     toPlot[j, end + 1 - i] = RGB(img[i, j].r, img[i, j].g, img[i, j].b)
#   end
# end
#
# toPlotAlpha = Array{RGBA, 2}(undef, size(img, 2),  size(img, 1))
# for i in 1:(size(img, 1))
#   for j in 1:(size(img, 2))
#     toPlotAlpha[j, end + 1 - i] = RGBA(0, 0, 0, img[i, j].alpha - img[i, j].r)
#   end
# end

################################################################################

# xs = Array{Int64, 1}(undef, 21)
# ys = Array{Int64, 1}(undef, 21)
# c = 0
# for (k, v) in electrodes
#   global c += 1
#   xs[c] = v[1]
#   ys[c] = v[2]
# end
# scatter!(ys, 1074 .- xs, color = :red, markersize = 100)
# flipElec = [ys 1074 .- xs]
#
#
# # for i in 1:(size(flipElec, 1))
# #   montage[flipElec[i, 1]:flipElec[i, 1] + 100, flipElec[i, 2]:flipElec[i, 2] + 100] .*= conicMask
# # end
#
# for i in 1:(size(flipElec, 1))
#   montage[flipElec[i, 1]:flipElec[i, 1] + 100, flipElec[i, 2] - 100:flipElec[i, 2]] .*= conicMask
# end

################################################################################

# # points = [(0, 0)]
# scene = heatmap(montage)
#
# frames = 1:300
#
# record(scene, "append_animation.mp4", frames; framerate = 10) do frame
#     @info frame
#     for (k, v) in electrodes
#       f = rand(1:5, 1)[1]
#       montage[v[1]:v[1] + 100, v[2]:v[2] + 100] .*= (conicMask .* f)
#     end
#     heatmap!(montage)
# end


# toPlot = Array{Float64, 2}(undef, size(img))
# for i in eachindex(img)
#   toPlot[i] = img[i].alpha
# end
# heatmap(toPlot)


# toPlot = Array{RGBA, 2}(undef, size(img, 2),  size(img, 1))
# for i in 1:(size(img, 1))
#   for j in 1:(size(img, 2))
#     toPlot[j, end + 1 - i] = RGB(img[i, j].r, img[i, j].g, img[i, j].b)
#     # toPlot[j, end + 1 - i] = RGBA(img[i, j].r, img[i, j].g, img[i, j].b, img[i, j].alpha)
#   end
# end
# image(toPlot)
# xlabel!("")
# ylabel!("")



# c = 0
# for (k, v) in electrodes
#   global c += 1
#   xs[c] = v[1] + 50
#   ys[c] = v[2] + 50
# end
# scatter!(ys, 1074 .- xs, color = :red, markersize = 100)


# for ix in 1:101
#   for jx in 1:101
#     img[v[1] + ix, v[2] + jx].r *= 0.5
#   end
# end

# toPlot = Array{Float64}(undef, size(img))
# toPlot = zeros(size(img))
# for (k, v) in electrodes
#   toPlot[v[1]:v[1] + 100, v[2]:v[2] + 100] .= montage[v[1]:v[1] + 100, v[2]:v[2] + 100] * conicMask
# end
# image(toPlot)



# record(scene, "phase_animation.mp4", framerate = framerate) do t
#   for (k, v) in electrodes
#     f = rand(1:5, 1)[1]
#     @info "$k = $f"
#     montage[v[1]:v[1] + 100, v[2]:v[2] + 100] .*= (conicMask .* f)
#   end
# end



# points = Node(Point2f0[(0, 0)])
# scene = scatter(points, limits = FRect(0, 0, 30, 30))
# frames = 1:30
#
# record(scene, "append_animation.mp4", frames; framerate = 30) do frame
#     new_point = Point2f0(frame, frame)
#     points[] = push!(points[], new_point)
# end



################################################################################

# colors = [ :gray, :red, :yellow, :blue, :green,]
# concentricA = range(0, 1, length = 10)
# concentricC = range(100, 0, length = 10)

################################################################################

# plot(xlims = (0, 1200), ylims = (0, 1100))

################################################################################

# plot!(circlePlot(600, 545, 475),fill = true, alpha = 0.8, c = :yellow, legend = false)
#
# for (_, elec) in electrodes
#     inten = 5
#     # if elec[3] == 1
#     #   tono = :gray
#     # else
#     #   tono = :red
#     #   inten = elec[3]
#     # end
#     plot!(circlePlot(elec[1], elec[2], 75), fill = true, alpha = 0.2 * inten, c = :red, legend = false) |> display
# end

# for (xi, xv) in enumerate(concentricC)
#   plot!(circlePlot(elec[1], elec[2], xv), fill = true, alpha = concentricA[xi], c = colors[2], legend = false) |> display
# end

################################################################################

# plot!(img)

################################################################################

# function circlePlot(y, x, r)
#   Θ = LinRange(0, 2 * π, 500)
#   y .+ r * sin.(Θ), x .+ r * cos.(Θ)
# end

################################################################################
