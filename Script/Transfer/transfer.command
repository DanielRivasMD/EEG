#!/bin/bash

echo ""
echo "Transfering patient data"
echo "--------------------------------------------------"

rsync -zaP ${HOME}/Desktop/EEG_AI_study/* innn@elefant.imbim.uu.se:/data2/collaborations/eeg/patients_raw/
