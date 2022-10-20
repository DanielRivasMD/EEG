################################################################################

# calculate stats per recording
function recordingSS(df)
  Ω = DataFrame(name = String[], mean = Float64[], std = Float64[])
  for ι ∈ axes(df, 2)
    if ι == 1 continue end
    push!(Ω, [names(df)[ι], df[df[:, ι] .!= 0, ι] |> mean, df[df[:, ι] .!= 0, ι] |> std])
  end
  return Ω
end

################################################################################

# calculate stats per electrode
function channelSS(df, ss)
  Ω = DataFrame(channel = String[], mean = Float64[], std = Float64[])
  @chain df begin
    names
    occursin.(ss, _)
    df[:, _]
    Matrix
    for ι ∈ 1:size(_, 1) - 2
      push!(Ω, [df[ι, 1], _[ι, _[ι, :] .!= 0] |> mean, _[ι, _[ι, :] .!= 0] |> std])
    end
  end
  return Ω
end

function channelSS(df)
  return (channelSS(df, "Sensitivity"), channelSS(df, "Specificity"))
end

################################################################################
