#= # install package
using Pkg

Pkg.clone("https://github.com/wherrera10/EDFPlus.jl", "EDFPlus")
Pkg.add("DSP")
Pkg.add("Plots")
Pkg.add("FileIO")
Pkg.add("PyPlot")

Pkg.add("QuartzImageIO")
Pkg.add("ImageMagick")

Pkg.clone("https://github.com/beacon-biosignals/EDF.jl", "EDF")

Pkg.clone("https://github.com/rob-luke/EEG.jl", "EEG")
Pkg.clone("git://github.com/codles/EEG.jl.git")
=#


using EDF

patient_dir = "Data/patientEEG/"
ind_patient = "Bustamante_Sanchez_Luis_Fernando.edf"

ind_file = EDF.read(string(patient_dir, ind_patient))
