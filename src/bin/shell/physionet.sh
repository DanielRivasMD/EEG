#!/bin/bash
set -euo pipefail

####################################################################################################

# collect arguments
recordNumber=$1

####################################################################################################

# iterate on patient directories
for patient in $(command find /Volumes/G/EEG/physionet.org/files/chbmit/1.0.0/* -type d -name "chb${recordNumber}")
do

  # identify annotation file
  annotation=$(command find "${patient}" -name '*summary.txt' -type f)

  # iterate on recordings
  for edf in $(command find "${patient}" -name '*edf' -type f)
  do

    # echo input file
    echo "EDF: ${${edf//*\/}/.edf/}"

    # call read mind
    julia \
      --project \
      "${mindDir}/src/ReadMind.jl" \
      --input "${edf//*\/}" \
      --inputDir "${patient}/" \
      --params "Parameters.jl" \
      --paramsDir "${binDir}/config/" \
      --annotation "${annotation//*\/}" \
      --annotDir "${patient}/" \
      --outDir "${mindData}" \
      --additional "annotationCalibrator.jl,fileReaderXLSX.jl" \
      --addDir "${annotationDir}/functions/" 1> "/Users/drivas/Factorem/MindReader/data/log/${${edf//*\/}/edf/log}" 2> "/Users/drivas/Factorem/MindReader/data/err/${${edf//*\/}/edf/err}"

  done
done

####################################################################################################
