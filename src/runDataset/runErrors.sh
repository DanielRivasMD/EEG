#!/bin/bash
# set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# iterate on errors
for err in $(command find "${mindData}/typeErr/annotation" -type f)
do

  # declare edf
  edf="${err/err/edf}"

  # echo input file
  echo "EDF: ${${edf//*\/}/.edf/}"

  # call read mind
  julia \
    --project \
    "/Users/drivas/Factorem/MindReader/src/ReadMind.jl" \
    --input "${edf//*\/}" \
    --inputDir "${patient}/" \
    --params "Parameters.jl" \
    --paramsDir "/Users/drivas/Factorem/EEG/src/runDataset/" \
    --annotation "${annotation//*\/}" \
    --annotDir "${patient}/" \
    --outDir "/Users/drivas/Factorem/MindReader/data/" \
    --additional "annotationCalibrator.jl,fileReaderXLSX.jl" \
    --addDir "/Users/drivas/Factorem/EEG/src/annotation/functions/" 1> "/Users/drivas/Factorem/MindReader/data/log/${${edf//*\/}/edf/log}" 2> "/Users/drivas/Factorem/MindReader/data/err/${${edf//*\/}/edf/err}"

done

####################################################################################################
