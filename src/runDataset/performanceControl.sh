#!/bin/bash
# set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# declarations
database="${dataDir}/chb-mit-scalp-eeg-database-1.0.0.zip"
scriptJL="${runDataset}/readMind.jl"

####################################################################################################

# declare counter
total=0

# purge log file
if [[ -f "${dataDir}/log.txt" ]]
then
  rm "${dataDir}/log.txt"
fi

# create log file
touch "${dataDir}/log.txt"

# iterate on records
for ix in {1..24}
do

  # declare counter
  patient=0

  # select summary
  fullsummary="$(unzip -l "${database}" | awk -v ix="$(printf %02d $ix)" '{if ($NF ~ ix && $NF ~ "summary") {print $NF}}')"

  # declare summary
  summary="${fullsummary/*\/}"

  # log
  echo "\nSUMMARY: ${summary}\n"

  # extract
  unzip -p "${database}" "${fullsummary}" > "${dataDir}/${summary}"

  ####################################################################################################

  # iterate on files
  for fulledf in $(unzip -l "${database}" | awk -v ix="$(printf %02d $ix)" '{if ($NF  ~ "chb"ix && $NF ~ "edf$") {print $NF}}')
  do

    # increase counters
    ((total++))
    ((patient++))

    # declare edf
    edf="${fulledf/*\/}"

    # log
    echo "EDF: ${edf}"

    # extract
    unzip -p "${database}" "${fulledf}" > "${dataDir}/${edf}"

    # calculate performance
    julia \
      --project \
      "${scriptJL}" \
      --input "${edf}" \
      --inputDir "${dataDir}/" \
      --params "Parameters.jl" \
      --paramsDir "${runDataset}/" \
      --annotation "${summary}" \
      --annotDir "${dataDir}/" \
      --outDir "${mindData}" \
      --additional "annotationCalibrator.jl,fileReaderXLSX.jl" \
      --addDir "${annotationDir}/functions/" &> "${mindLog}/${edf/edf/log}"

    # remove edf
    if [[ -f "${dataDir}/${edf}" ]]
    then
      rm "${dataDir}/${edf}"
    fi

  done

  # print counter
  echo "${summary/-summary.txt/},${patient}" >> "${dataDir}/log.txt"

  # remove summary
  if [[ -f "${dataDir}/${summary}" ]]
  then
    rm "${dataDir}/${summary}"
  fi

done

# print counter
echo "total,${total}" >> "${dataDir}/log.txt"

####################################################################################################
