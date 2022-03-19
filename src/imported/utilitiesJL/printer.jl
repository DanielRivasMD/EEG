################################################################################

using DelimitedFiles

################################################################################

# write files
# model
for i in 1:(model |> length)
  writedlm( string(outDir, "MWeightsLayer", i, ".csv"), model[i].W, ", " )
  writedlm( string(outDir, "MBiasesLayer", i, ".csv"), model[i].b, ", " )
end

# compressed
outAr = Array{Float64}(undef, 4, 32576)
for i in 1:(timeAr |> length)
  outAr[:, i] = cpu(model[1])(timeAr[i])
end
writedlm( string(outDir, "SignalCompressed.csv"), outAr, ", " )

################################################################################
