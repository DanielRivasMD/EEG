################################################################################

toHeat = zeros(length(compDc), length(compDc[convert.(String, keys(compDc))[1]][1]))
c = 0
for (k, v) in compDc
  c += 1
  toHeat[c, :] = v[1]
end
UnicodePlots.heatmap(toHeat)

toHeat = zeros(length(errDc), length(errDc[convert.(String, keys(errDc))[1]][1]))
c = 0
for (k, v) in errDc
  c += 1
  toHeat[c, :] = v[1]
end
UnicodePlots.heatmap(toHeat)

toHeat = zeros(length(errDc), length(errDc[convert.(String, keys(errDc))[1]][1]))
c = 0
for k in elecID
  if haskey(errDc, k)
    c += 1
    toHeat[c, :] = errDc[k][1]
  else
    @info k
  end
end
UnicodePlots.heatmap(toHeat, border = :none, height = 19, width = 150, )



s2 = Scene()
s2 = AbstractPlotting.heatmap(toHeat', show_axis = false)
save("hm.svg", s2, pt_per_unit = 0.5)

################################################################################

utilDir = "utilitiesJL/"
include(string(utilDir, "fileReader.jl"));

function vision(xDf)
  for (k, v) in xDf
    @info k
    v |> println
  end
end

eegDir = "/Users/drivas/Factorem/EEG/Data/patientEEG/"

fls = cd(readdir, eegDir)

lsxl = fls[match.(r"\S+xlsx", fls) .|> !isnothing]

for f in lsxl
  println()
  @info f
  XLSX.readxlsx(string(eegDir, f)) |> XLSX.sheetnames |> println
end

for f in lsxl
  println()
  # @info f
  xread(string(eegDir, f))
end

################################################################################
