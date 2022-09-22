#!/bin/bash
# set -euo pipefail
# DOC: concatenate patient models & measure performance. call performanceConcatenate.jl

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# declarations
scriptJL="${binDir}/julia/performanceConcatenatedFilter.jl"

####################################################################################################

# iterate on records
for ix in {1..24}
do

  # calculate performance
  julia \
    --project \
    "${scriptJL}" \
    --inputDir "${dataDir}/" \
    --params "Parameters.jl" \
    --paramsDir "${binDir}/julia/" \
    --annotation "${summary}" \
    --annotDir "${dataDir}/" \
    --outDir "${mindData}" \
    --additional "annotationCalibrator.jl,fileReaderXLSX.jl" \
    --addDir "${annotationDir}/functions/" &> "${mindLog}/${summary/-summary.txt/.log}"

done

####################################################################################################
