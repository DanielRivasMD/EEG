#!/bin/bash
# set -euo pipefail

################################################################################

# iterate on patient directories
for patient in $( $(which fd) . '/Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0' --type directory )
do

  # identify annotation file
  annotation=$( $(which fd) summary.txt "${patient}" --type file  )

  # iterate on recordings
  for edf in $( $(which fd) edf$ "${patient}" --type file )
  do

    # echo input file
    echo "EDF: ${${edf//*\/}/.edf/}"

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
      --addDir "/Users/drivas/Factorem/EEG/src/annotation/functions/" &> "/Users/drivas/Factorem/MindReader/data/log/${${edf//*\/}/edf/log}"

  done
done

################################################################################
