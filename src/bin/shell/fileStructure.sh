#!/bin/bash
set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# load time threshold
source "${configDir}/timeThresholds.sh"

####################################################################################################

# declare subdirectories
subdirs=("channel" "record" "subject")

####################################################################################################

# summary
if [[ ! -d "${mindData}/summary" ]]
then
  mkdir "${mindData}/summary"
fi

####################################################################################################

# events
if [[ ! -d "${mindEvent}" ]]
then
  mkdir "${mindEvent}"
fi

for timeThres in "${timeThresholds[@]}"
do
  if [[ ! -d "${mindEvent}/${timeThres}" ]]
  then
    mkdir "${mindEvent}/${timeThres}"
  fi
done

####################################################################################################

# confusion matrices
if [[ ! -d "${mindCM}" ]]
then
  mkdir "${mindCM}"
fi

for dir in "${subdirs[@]}"
do
  if [[ ! -d "${mindCM}/${dir}" ]]
  then
    mkdir "${mindCM}/${dir}"
  fi

  for timeThres in "${timeThresholds[@]}"
  do
    if [[ ! -d "${mindCM}/${dir}/${timeThres}" ]]
    then
      mkdir "${mindCM}/${dir}/${timeThres}"
    fi
  done
done

if [[ ! -d "${mindCM}/dataset" ]]
then
  mkdir "${mindCM}/dataset"
fi

####################################################################################################

# roc
if [[ ! -d "${mindROC}" ]]
then
  mkdir "${mindROC}"
fi

for dir in "${subdirs[@]}"
do
  if [[ ! -d "${mindROC}/${dir}" ]]
  then
    mkdir "${mindROC}/${dir}"
  fi

  for timeThres in "${timeThresholds[@]}"
  do
    if [[ ! -d "${mindROC}/${dir}/${timeThres}" ]]
    then
      mkdir "${mindROC}/${dir}/${timeThres}"
    fi
  done
done

if [[ ! -d "${mindROC}/dataset" ]]
then
  mkdir "${mindROC}/dataset"
fi

####################################################################################################
