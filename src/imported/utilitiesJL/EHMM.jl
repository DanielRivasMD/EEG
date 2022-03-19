################################################################################

using StructArrays

################################################################################

struct ScorePair
  score::Float64
  index::Int64
end

mutable struct EHMM
  dataM::Array
  tbM::Array
end

################################################################################

function setup(v::Array{Float64, 2})
  mPen = 5000.
  noIter = 1
  hmm = EHMM([zeros(size(v, 1)) for i in 1:noIter], [zeros(size(v, 2) + 1) for i in 1:noIter])
  reset!(hmm)
  return (mPen, hmm)
end

################################################################################

function distance(self::EHMM, j::Int64, h::Array{Float64, 1})
  dis = 0.
  for ix in eachindex(self.dataM[j])
    dis += (self.dataM[j][ix] - h[ix]) ^ 2
  end
  dis = sqrt(dis)
  return dis
end

function distance(arr::Array{Float64, 1}, h::Array{Float64, 1})
  dis = 0.
  for ix in eachindex(arr)
    dis += (arr[ix] - h[ix]) ^ 2
  end
  dis = sqrt(dis)
  return dis
end

################################################################################

function reset!(self::EHMM)
  self.tbM = [x .= [0; repeat(-1:-1, length(self.tbM[1]) - 1)] for x in self.tbM]
  return self.tbM
end

################################################################################

function feed(self::EHMM, frame::Int64, d::Array{Float64, 2}, pen::Float64)
  for ix in eachindex(self.tbM)
    plus = distance(self, ix, d[:, frame])
    for jx in eachindex(self.tbM)
      lpen = copy(pen)
      if (jx == ix) lpen = 0 end
      if self.tbM[jx][frame + 1] < 0. || self.tbM[ix][frame] + plus + lpen < self.tbM[jx][frame + 1]
        self.tbM[jx][frame + 1] = self.tbM[ix][frame] + plus + lpen
      end
    end
  end
end

################################################################################

function backTrace(self::EHMM)
  state = 0
  min = self.tbM[1][end]

  for ix in eachindex(self.tbM)
    if self.tbM[ix][end] <= min
      state = ix
      min = self.tbM[ix][end]
    end

    tb = fill(-1, size(self.tbM[1], 1))

    for ix in reverse(eachindex(self.tbM[1]))
      vlocal = min
      global sig = -1

      for jx in eachindex(self.tbM)
        dob = self.tbM[jx][ix]
        if dob <= vlocal
          vlocal = dob
          sig = jx # - 1 # adjust for 0-index?
        end
      end

      tb[ix] = state
      state = sig

    end

    tb = tb[1:end - 1]

    # @info "Print TB:"
    # for ix in eachindex(tb)
    #   print(ix)
    #   println(": ", tb[ix])
    # end

    return tb
  end
end

################################################################################

function process(self::EHMM, d::Array{Float64, 2}, pen::Float64)

  # @info "Reset"
  reset!(self)

  for ix in axes(d, 2)
    # @info "Feed frame $(ix)"
    feed(self, ix, d, pen)
  end

  # @info "Backtrace"
  tb = backTrace(self)

  divider = fill(1, size(self.dataM, 1))
  orig = deepcopy(self.dataM)
  pp = StructArray{ScorePair}(undef, 0)

  # @info "Update model"
  for ix in axes(d, 2)
    self.dataM[tb[ix]] .+= d[:, ix]
    divider[tb[ix]] += 1
    pair = ScorePair(distance(orig[tb[ix]], d[:, ix]), ix)
    push!(pp, pair)
  end

  scores = sort(pp.score, rev = true)
  ixs = map(x -> findall(x .== pp.score), scores)
  pp = pp[vcat(ixs...)]

  for ix in eachindex(self.dataM)
    self.dataM[ix] /= divider[ix]
  end

  # for jx in eachindex(self.dataM)
  #   @info "Print state $(jx)"
  #   for ix in eachindex(self.dataM[jx])
  #     @info self.dataM[jx][ix]
  #   end
  # end

  extra = fill(0, size(self.dataM[1], 1))

  # @info("Split")
  co = 0
  for ix in 1:floor(Int64, (5 + size(pp, 1) / 50))
    extra += d[:, pp.index[ix]]
    co += 1
  end

  extra ./= co
  push!(self.dataM, extra)

  push!(self.tbM, fill(0, size(self.tbM[1], 1)))

  return tb, self.dataM

end

################################################################################
