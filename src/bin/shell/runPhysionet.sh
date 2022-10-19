#!/bin/bash
set -euo pipefail
# DOC: control model training on physionet through
# control MindReader ReadMind.jl

####################################################################################################

# declare batches
arr=(1..6 7..12 13..18 19..24)

# iterate on patient batches
for bt in ${arr[@]}
do
  # iterate on patients
  for ix in {$bt}
  do
    # call physionet controller
    source src/bin/shell/physionet.sh $(printf "%02d\n" $ix) &
  done
done

####################################################################################################
