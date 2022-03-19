################################################################################

using DelimitedFiles
using Glob
using Plots

################################################################################

files = glob("*autoEncoderTunning.csv", "outDir")

anim = @animate for i in range(1, step = 1, (files |> length))
  fl = files[i]
  sig = readdlm(fl)
  p = plot(sig[:, 1], title = fl, ylims = (-20_000_000, 20_000_000))
end

gif(anim, "autoEncoderTunning.gif", fps = 5)

################################################################################
