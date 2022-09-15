#!/bin/bash
# set -euo pipefail

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
    source src/runDataset/physionet.sh $(printf "%02d\n" $ix) &
  done
done

####################################################################################################
