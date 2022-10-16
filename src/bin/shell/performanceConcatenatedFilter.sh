#!/bin/bash
set -euo pipefail
# DOC: measure performance on concatenated subjects
# control performanceConcatenatedFilter.jl
# input:
#   summary files for annotations
#   concatenated labels @ label
#   concatenated model tracebacks @ hmm
# output:
#   log files
#   performance files @ roc

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# declarations
database="${externalDir}/chb-mit-scalp-eeg-database-1.0.0.zip"
scriptJL="${binDir}/julia/performanceConcatenatedFilter.jl"

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

  ####################################################################################################

  # calculate performance
  julia \
    --project \
    "${scriptJL}" \
    --params "Parameters.jl" \
    --paramsDir "${binDir}/julia/" \
    --annotation "${summary}" \
    --annotDir "${dataDir}/" \
    --outDir "${mindData}" \
    --additional "annotationCalibrator.jl,fileReaderXLSX.jl" \
    --addDir "${annotationDir}/functions/" &> "${mindLog}/${summary/-summary.txt/.log}"

done

####################################################################################################
