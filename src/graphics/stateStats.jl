################################################################################

# TODO: add test
function stateStats(stateAr::Array{Float64, 2}, numState = 5)
  statsAr = zeros(Int64, numState, size(stateAr, 1))                            # empty out array
  ct = 0
  for rw ∈ eachrow(stateAr)                                                    # iterate on each row (channel)
    rwFq = FreqTables.freqtable(rw)                                             # get the frequency
    tmpFq = FreqTables.freqtable([1.:numState...])                              # adjust frecuency table for non-present values
    for jx ∈ 1:numState
      ixs = findall(isequal.(names(tmpFq)[1][jx], names(rwFq)[1]))
      if sum(ixs) > 0
        tmpFq[jx] = rwFq[ixs[1]]
      else
        tmpFq[jx] = 0
      end
    end
    ct += 1
    statsAr[:, ct] = tmpFq.array                                                # collect frecuency into array
  end
  return statsAr
end

################################################################################

function summarizeStats(fileList::Array{String, 1}, maxChannel = 25)
  collectAr = zeros(Float64, length(fileList), maxChannel)
  cf = 0
  for f ∈ fileList
    cf += 1
    stAr = DelimitedFiles.readdlm(f, ',')                                       # read csv files
    maxChannel < size(stAr, 2) ? lMar = maxChannel : lMar = size(stAr, 2)       # adjust margin
    grRt = groundStateRatio(stAr)[1:lMar]                                       # perform operations. get ground state ratio
    collectAr[cf, 1:length(grRt)] = grRt[:, 1]                                  # collect into array
  end
  plotStatesHeatmap(collectAr)                                                  # plot
  return collectAr
end

################################################################################

function groundStateRatio(stateAr)
  stateAr[1, :] ./ sum(stateAr, dims = 1)'
end

################################################################################

function plotStatesHeatmap(toSummarize::Array{Float64, 2}, outimg = "groundStateRatio")

  # plot layout
  plotFig = CairoMakie.Figure()
  heatplot = plotFig[1, 1] = CairoMakie.Axis(plotFig, title = "Ground state ratio")

  # # axis labels
  # heatplot.xlabel = "Recording Time"
  # heatplot.ylabel = "Channels"
  # heatplot.yticks = 1:22

  # heatmap plot & color range
  hm = CairoMakie.heatmap!(heatplot, toSummarize')
  hm.colorrange = (0, 1)

  # color bar
  cbar = plotFig[2, 1] = CairoMakie.Colorbar(plotFig, hm, label = "Ground State proportion")
  cbar.vertical = false
  cbar.height = 10
  cbar.width = CairoMakie.Relative(2 / 3)
  cbar.ticks = 0:0.1:1

  # save rendering
  CairoMakie.save(string(outdir, "/", outimg, ".svg"), plotFig, )

end

################################################################################
