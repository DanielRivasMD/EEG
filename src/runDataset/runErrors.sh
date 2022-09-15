#!/bin/bash
# set -euo pipefail

####################################################################################################

# declare batches
arr=(annotation bounds inexact)

# iterate on error batches
for bt in ${arr[@]}
do
  # call error controller
  source src/runDataset/errors.sh $bt
done

####################################################################################################
