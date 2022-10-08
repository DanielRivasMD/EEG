#!/bin/bash
set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# declarations
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

  # extract
  unzip -p "${database}" "${fullsummary}" > "${dataDir}/${summary}"

done

####################################################################################################
