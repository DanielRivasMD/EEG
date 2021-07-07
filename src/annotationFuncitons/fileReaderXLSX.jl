################################################################################

"""

    xread(shParams::Dict)

# Description
Read annotation XLSX file.

"""
function xread(shParams::Dict)
  # read xlsx file
  @info "Reading XLSX file..."
  xlsxFile = string(shParams["indir"], replace(shParams["file"], "edf" => "xlsx"))
  xtmp = XLSX.readxlsx(xlsxFile)

  if xtmp |> XLSX.sheetcount != 3
    @error "Annotations file $(xlsxFile) does not contain 3 sheets"
  end

  # load sheets on dataframes
  outDc = Dict{String, DataFrame}()
  Κ = ["PD" 7; "SA" 6; "EM" 4]
  for (κ, υ) ∈ eachrow(Κ)
    ξ = (match.(Regex(κ), xtmp |> XLSX.sheetnames) .|> !isnothing |> findall)[1]
    xar = xtmp[ξ][:]
    if size(xar, 2) == υ + 1
      if κ == "EM" && ismissing(xar[1, end - 1])
        xar[1, end - 1] = xar[1, end]
      end
      xar[1, end] = "ADDITIONAL"
    else
      xar = [xar ["ADDITIONAL"; repeat([missing], size(xar, 1) - 1)]]
    end
    xAr = DataFrame(xar[2:end, :], :auto)
    for ι ∈ 1:size(xar, 2)
      rename!(xAr, [ι => xar[1, ι]])
    end
    if κ == "SA"
      outDc["ST"] = xAr[:, 1:3]
      outDc["MA"] = xAr[:, 4:end]
      for ο ∈ ["ST", "MA"]
        for ι ∈ 2:3
          rename!(outDc[ο], [ι => replace.(names(outDc[ο])[ι], r"\S " => "")])
        end
      end
    else
      outDc[κ] = xAr
    end
  end

  return outDc
end

################################################################################
