################################################################################

# declare paths
eegDir="${HOME}/Factorem/EEG/Data/patientEEG"
chFFTA3="${HOME}/Factorem/electrosignals/mindReaderJL/chFFTA3.jl"

################################################################################

# mount files into array
dAr=("0051ED.edf" "0052MR.edf" "0053MT.edf")

# loop through healthy files
for edfFile in ${dAr[@]}
do
  # run julia tool
  julia --st no ${chFFTA3} -f ${eegDir}/${edfFile}
done

################################################################################
