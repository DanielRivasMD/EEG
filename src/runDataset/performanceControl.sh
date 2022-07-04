#!/bin/bash
# set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# declare database
database="${dataDir}/chb-mit-scalp-eeg-database-1.0.0.zip"

####################################################################################################

# iterate on records
for ix in {1..24}
do

  # select summary
  fullsummary="$(unzip -l "${database}" | awk -v ix="$(printf %02d $ix)" '{if ($NF ~ ix && $NF ~ "summary") {print $NF}}')"

  # declare summary
  summary="${fullsummary/*\/}"

  # log
  echo "\nSUMMARY: ${summary}\n"

  # # extract
  # unzip -p "${database}" "${fullsummary}" > "${dataDir}/${summary}"

  ####################################################################################################

  # iterate on files
  for fulledf in $(unzip -l "${database}" | awk -v ix="$(printf %02d $ix)" '{if ($NF  ~ "chb"ix && $NF ~ "edf$") {print $NF}}')
  do

    # declare edf
    edf="${fulledf/*\/}"

    # log
    echo "EDF: ${edf}"
    echo "OUT: ${dataDir}/${edf}"

    echo "LOG: /Users/drivas/Factorem/MindReader/data/log/${edf/edf/log}"

    # # extract
    # unzip -p "${database}" "${fulledf}" > "${dataDir}/${edf}"

    # julia \
    #   --project \
    #   "/Users/drivas/Factorem/EEG/src/runDataset/readMind.jl" \
    #   --input "${edf}" \
    #   --inputDir "${dataDir}/" \
    #   --annotation "${summary}" \
    #   --annotDir "${dataDir}/" \
    #   --outDir "/Users/drivas/Factorem/MindReader/data/" \
    #   --additional "annotationCalibrator.jl,fileReaderXLSX.jl" \
    #   --addDir "/Users/drivas/Factorem/EEG/src/annotation/functions/" &> "/Users/drivas/Factorem/MindReader/data/log/${edf/edf/log}"

  done

done

####################################################################################################
