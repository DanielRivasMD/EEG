#!/bin/bash

echo ""
echo "Starting to set up"
echo "--------------------------------------------------"

echo ""
echo "Changing directory to Escritorio"
echo "--------------------------------------------------"
cd ${HOME}/Escritorio/

echo ""
echo "Creating folder for EEG patient data"
echo "--------------------------------------------------"
mkdir -p AI_EEG/{patients_raw,source}

echo ""
echo ""
echo "--------------------------------------------------"
mv -v ${HOME}/Descargas/Transfer/TransferEEG_files/transfer.command ${HOME}/Escritorio/AI_EEG/source/
