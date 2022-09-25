####################################################################################################

# load packages
using DelimitedFiles
using StatsPlots

####################################################################################################

idAr = [
  "0001LB",
  "0066MM",
  "0081MB",
]

for id in idAr
  s = readdlm(string("screen/", id, ".csv"), ',')
  p = readdlm(string("permutation/U", id, ".csv"), ',')
  w = readdlm(string("permutation/W", id, ".csv"), ',')

  spw = [s p w]

  tags = repeat(
    ["sensitivity",
     "specificity",
     "permutationSens",
     "permutationSpec",
    ], inner = size(spw, 1)
  )

  gb = groupedbar(spw,
    group = tags,
    ylims = (0, 1.5),
    title = "sensitivity & specificity",
    xlabel = "Groups",
    ylabel = "Percentage",
  )

  savefig(gb, string("datasetPlots/", id, ".svg"))
end

####################################################################################################
