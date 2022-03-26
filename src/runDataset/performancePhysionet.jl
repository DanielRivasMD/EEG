################################################################################

# declarations
begin
  include( "/Users/drivas/Factorem/EEG/src/config/config.jl" )
end;

################################################################################

# load project enviroment
using Pkg
if Pkg.project().path != string( projDir, "/Project.toml" )
  Pkg.activate(projDir)
end

################################################################################

# load packages
begin

end;

################################################################################

# load modules
begin
  include(string(utilDir, "/ioDataFrame.jl"))
end;

################################################################################

# identify files to load
events = readdir(mindScreen)

################################################################################

# read files into dataframe array
df = [readdf(string(mindScreen, "/", ι), ',') |> π -> rename(π, π |> names .|> π -> replace(π, " " => "") .|> π -> string(π, "_", replace(ι, ".csv" => ""))) for ι ∈ events]

# collect electrode names
electrode = Array{String, 1}(undef, 0)
foreach(df) do ξ
  for (ι, υ) ∈ enumerate(map(χ -> χ .== electrode, ξ[:, 1]) .|> sum)
    if υ != 1
      push!(electrode, ξ[ι, 1])
    end
  end
end

# patch electrodes
foreach(df) do ξ
  for (ι, υ) ∈ enumerate(map(χ -> findall(χ .== ξ[:, 1]), electrode) .|> sum)
    if υ == 0
      push!(ξ, [electrode[ι], 0.0, 0.0])
    end
  end
end

# concatenate dataframe
df = hcat(DataFrame(Electrode = electrode), map(ξ -> ξ = ξ[:, Not(1)], df) |> π -> hcat(π...))

################################################################################

# write dataframe
writedf(string(mindCSV, "/performace.csv"), df, ',')

################################################################################
