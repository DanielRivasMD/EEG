#!/bin/bash
set -euo pipefail
# DOC: control errors & handle re runs

####################################################################################################

# declare batches
arr=(annotation bounds inexact last patch)

# iterate on error batches
for bt in ${arr[@]}
do
  # call error controller
  source src/bin/patch/errors.sh $bt
done

####################################################################################################
