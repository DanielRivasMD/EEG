#!/bin/bash
# set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# declare database
database="${dataDir}/chb-mit-scalp-eeg-database-1.0.0.zip"

####################################################################################################

# declare counter
ct=0

# iterate on files
for file in $(unzip -l "${database}" | awk '/edf$/ {print $NF}')
do
  # log
  echo "${file/*\/}"

  # increase count
  ((ct+=1))
  if [[ ${ct} == 1 ]]
  then
    unzip -p "${database}" "${file}" > "${dataDir}/${file/*\/}"
  fi
done

####################################################################################################
