#!/bin/bash
# set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# iterate on files
for file in $(unzip -l "${dataDir}/chb-mit-scalp-eeg-database-1.0.0.zip" | awk '/edf$/ {print $NF}')
do
  echo "${file}"
done

####################################################################################################
