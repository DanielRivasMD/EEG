#!/bin/bash

echo ""
echo "Transfering patient data"
echo "--------------------------------------------------"

rsync -zaP ${HOME}/Desktop/AI_EEG/* innn@elefant.imbim.uu.se:/data2/collaborations/eeg/patients_raw/
