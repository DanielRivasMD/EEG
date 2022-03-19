################################################################################

using Parameters: @with_kw
using DelimitedFiles

################################################################################

utilDir = "../utilitiesJL/"
include(string(utilDir, "ArgParser.jl"))

# parse shell arguments
shArgs = shArgParser(ARGS)

begin
  file = shArgs["file"]
  outDir = string(shArgs["output"], "/")
  winBin = shArgs["window-size"]
  overlap = shArgs["bin-overlap"]
end;

begin
  ftrim = replace(file, r".+/" => "")
  ftrim = replace(ftrim, ".edf" => "")
end;

################################################################################

# load functions
@info("Loading modules...")
include(string(utilDir, "fileReader.jl"));
include(string(utilDir, "FFT.jl"));
include(string(utilDir, "shapeShifter.jl"));
include(string(utilDir, "architect.jl"));
include(string(utilDir, "autoencoder.jl"));

################################################################################

# set parameters
@with_kw mutable struct Params
  η::Float64 = 1e-3                               # learning rate
  epochs::Int = 10                                # number of epochs
  batchsize::Int = 1000                           # batch size for training
  throttle::Int = 5                               # throttle timeout
  device::Function = gpu                          # set as gpu, if gpu available
end

################################################################################

# read edf file
edfDf, startTime = getSignals(file);

# calculate fft
freqAr = extractFFT(edfDf, binSize = winBin, binOverlap = overlap);

# reshape based on time frames
freqAr = shifter(freqAr);

################################################################################

# reset parameters & run
for il in [5:5:100...]

  ################################################################################

  # autoencoder
  model = buildAutoencoder(length(freqAr[1]), il, leakyrelu)
  model = modelTrain(freqAr, model, Params)

  ################################################################################

  comprAr = Array{Float64}(undef, length(freqAr), il);
  preAr = Array{Float64}(undef, length(freqAr), length(freqAr[1]));
  postAr = copy(preAr);
  diffAr = copy(postAr);
  for i in 1:length(freqAr)
    preAr[i, :] = freqAr[i]
    comprAr[i, :] = cpu(model[1])(preAr[i, :])
    postAr[i, :] = cpu(model)(preAr[i, :])
    diffAr[i, :] = postAr[i, :] - preAr[i, :]
  end

  ################################################################################

  @info("Writting...")

  for ix in 1:length(model)
    writedlm(string(outDir,ftrim, "_", il, "MWeightsLayer", ix, ".csv"), model[ix].W, ", ")
    writedlm(string(outDir,ftrim, "_", il, "MBiasesLayer", ix, ".csv"), model[ix].b, ", ")
  end

  writedlm(string(outDir, ftrim, "_", "compr", il, "autoencoder.csv"), comprAr, ", ")
  writedlm(string(outDir, ftrim, "_", "pre", il, "autoencoder.csv"), preAr, ", ")
  writedlm(string(outDir, ftrim, "_", "post", il, "autoencoder.csv"), postAr, ", ")
  writedlm(string(outDir, ftrim, "_", "diff", il, "autoencoder.csv"), diffAr, ", ")

  ################################################################################

end

################################################################################
