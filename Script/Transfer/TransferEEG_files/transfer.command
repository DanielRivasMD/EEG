#!/bin/bash

rsync -zaP ${HOME}/Escritorio/patients_raw/* innn@elefant.imbim.uu.se:/data2/collaborations/eeg/patients_raw/
