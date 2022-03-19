################################################################################

utilDir = "../utilitiesJL/"
include(string(utilDir, "EHMMargParser.jl"))

# parse shell arguments
shArgs = shArgParser(ARGS)

begin
  file = shArgs["file"]
  outDir = string(shArgs["output"], "/")
end;

################################################################################

# load functions
include(string(utilDir, "EHMMReader.jl"));
include(string(utilDir, "EHMM.jl"));

################################################################################

# setup
mPen, hmm = setup(v)

################################################################################

# process
for i in 1:5
  process(hmm, v, mPen)
end

################################################################################
