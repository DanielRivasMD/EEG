#!/bin/bash
# set -euo pipefail

####################################################################################################

for edf in $(command find PATH_TO_EDF_FILES -name '*edf' -type f -exec basename \{} .edf \; )
do

  echo "EDF: ${edf}"
  julia --project "/sw/comp/julia/1.7.2/rackham/test_user/MindReader/src/ReadMind.jl" \
  --input "${edf}.edf" \
  --inputDir "PATH_TO_EDF_FILES" \
  --params "PARAMETERS.jl" \
  --paramsDir "PATH_TO_PARAMETERS" \
  --annotation "${edf}.xlsx" \
  --annotDir "PATH_TO_ANNOT_FILES" \
  --outDir "OUT_DIR" \
  --additional "annotationCalibrator.jl,fileReaderXLSX.jl" \
  --addDir "PATH_TO_ADDITIONAL_FILES"

done

####################################################################################################
