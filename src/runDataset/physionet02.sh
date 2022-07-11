#!/bin/bash
# set -euo pipefail

####################################################################################################

# iterate on patient directories
for patient in $(command find /Users/drivas/Factorem/EEG/data/physionet.org/files/chbmit/1.0.0/* -type d -name 'chb0[7-9]' -o -name 'chb1[0-2]')
do

  # identify annotation file
  annotation=$(command find "${patient}" -name '*summary.txt' -type f)

  # iterate on recordings
  for edf in $(command find "${patient}" -name '*edf' -type f)
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

####################################################################################################
