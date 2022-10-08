#!/bin/bash
set -euo pipefail

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# create error directories
mkdir "${mindData}/typeErr"
mkdir "${mindData}/typeErr/annotation"
mkdir "${mindData}/typeErr/inexact"
mkdir "${mindData}/typeErr/bounds"
mkdir "${mindData}/typeErr/last"
mkdir "${mindData}/typeErr/patch"

####################################################################################################

# iterate on errors
for err in $(command find "${mindErr}" -type f)
do

  # echo err file
  echo "${err}"

  # grep errors
  errGrep=$(grep -w ERROR "${err}")

  # check error
  if [[ ! -z "$errGrep" ]]
  then
    mv "${err}" "${mindData}/typeErr/"
  fi

done

####################################################################################################

# iterate on failed runs
for fail in $(command find "${mindData}/typeErr" -type f)
do

  # echo failed
  echo "${fail}"

  # grep annotation fail
  annotFail=$(grep annotation "${fail}")

  # check annotation fail
  if [[ ! -z "$annotFail" ]]
  then
    mv "${fail}" "${mindData}/typeErr/annotation/"
  fi

  # grep inexact fail
  inexactFail=$(grep Inexact "${fail}")

  # check inexact fail
  if [[ ! -z "${inexactFail}" ]]
  then
    mv "${fail}" "${mindData}/typeErr/inexact/"
  fi

  # grep bounds fail
  boundsFail=$(grep Bounds "${fail}")

  # check bounds fail
  if [[ ! -z "${boundsFail}" ]]
  then
    mv "${fail}" "${mindData}/typeErr/bounds/"
  fi

done

####################################################################################################

# run failed due to lag on updating scripts related to empty channel error
# iterate on errors
for err in $(command find "${mindErr}" -type f)
do

  # echo err file
  echo "${err}"

  # grep errors
  errGrep=$(grep -w ERROR "${err}")

  # check error
  if [[ ! -z "$errGrep" ]]
  then
    mv "${err}" "${mindData}/typeErr/last/"
  fi

done

####################################################################################################

# run failed due to suffx
# iterate on errors
for err in $(command find "${mindErr}" -type f)
do

  # echo err file
  echo "${err}"

  # grep errors
  errGrep=$(grep -w ERROR "${err}")

  # check error
  if [[ ! -z "$errGrep" ]]
  then
    mv "${err}" "${mindData}/typeErr/patch/"
  fi

done

####################################################################################################
