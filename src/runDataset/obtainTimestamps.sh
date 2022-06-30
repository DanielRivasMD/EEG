#!/bin/bash
# set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# declare database
database="${dataDir}/chb-mit-scalp-eeg-database-1.0.0.zip"

####################################################################################################

# iterate on files
for file in $(unzip -l "${database}" | awk '/summary/ {print $NF}')
do
  # log
  echo "${file/*\/}"
    # extract
    unzip -p "${database}" "${file}" > "${dataDir}/${file/*\/}"
done

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
    # extract
    unzip -p "${database}" "${file}" > "${dataDir}/${file/*\/}"
  fi
done

####################################################################################################
