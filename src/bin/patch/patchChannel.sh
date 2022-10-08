#!/bin/bash
set -euo pipefail
# DOC: patch wrongly label channel from edf files

####################################################################################################

# config
source "${HOME}/Factorem/EEG/src/config/config.sh"

####################################################################################################

# patch models
mv -v "${mindHMM}/chb12_28_01_model.csv" "${mindHMM}/chb12_28_O1_model.csv"
mv -v "${mindHMM}/chb12_29_01_model.csv" "${mindHMM}/chb12_29_O1_model.csv"

# patch tracebacks
mv -v "${mindHMM}/chb12_28_01_traceback.csv" "${mindHMM}/chb12_28_O1_traceback.csv"
mv -v "${mindHMM}/chb12_29_01_traceback.csv" "${mindHMM}/chb12_29_O1_traceback.csv"

####################################################################################################
