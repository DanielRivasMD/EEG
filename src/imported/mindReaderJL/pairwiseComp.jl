################################################################################

using JLD2

################################################################################

outDir = "outDir/"

@load string(outDir, ftrim, "_errDcChFFTA3.jld2")

################################################################################

dimension = 6 * 21
states = 1:6

comparativeMt = zeros(dimension, dimension)

################################################################################

# icx = 0
# icy = 0
cx = 0
# cy = 0
for (ko, vo) in errDc
  # global icx += 1
  # icx == 7 ? icx = 1 :
  for icx in states
    global cx += 1
    # cy = 0
    # for (ki, vi) in errDc
    #   for icy in states
    #     # global icy += 1
    #     # icy == 7 ? icy = 1 :
    #     global cy += 1
        comparativeMt[:, cx] .= vo[2][icx] |> sum
    #     # @info "icx = $(icx)"
    #     # @info "icy = $(icy)"
    #     # @info "cx = $(cx)"
    #     # @info "cy = $(cy)"
    #     # println()
    #   end
    # end
  end
end



################################################################################
