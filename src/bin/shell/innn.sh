#!/bin/bash
####################################################################################################

patientEEG="/Volumes/ECHO/MacBookPro/drivas/Factorem/EEG/data/patientEEG"
mindReaderDir="$HOME/Factorem/MindReader"
eegDir="$HOME/Factorem/EEG"
logDir="$HOME/Factorem/EEG/data/log"

####################################################################################################

# iterate on patient directories
for patient in $(command ls ${patientEEG}/*.edf)
do

  patient=$(basename ${patient//.edf/})
  # log
  echo "Processing ${patient}"

    # specific julia version MindReader compatible
    julia +1.7.3 \
      --project="${mindReaderDir}" \
      "${mindReaderDir}/src/ReadMind.jl" \
      --input "${patient}.edf" \
      --inputDir "${patientEEG}/" \
      --params "Parameters.jl" \
      --paramsDir "${eegDir}/src/bin/config/" \
      --outDir "${mindReaderDir}/" 1> "${logDir}/${patient}.log" 2> "${logDir}/${patient}.err"

  done
done

####################################################################################################
