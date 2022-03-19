################################################################################

# declare paths
eegDir="${HOME}/Factorem/EEG/Data/patientEEG"
chFFTA3="${HOME}/Factorem/electrosignals/mindReaderJL/chFFTA3.jl"

################################################################################

# mount files into array
i=0
while read line
do
  fls[ $i ]="$line"
  (( i++ ))
done < <(ls ${eegDir}/*xlsx)

# loop through focalized files
focalized0=50
focalized1=95
for (( i = ${focalized0}; i < ${focalized1}; i++ ))
do
  xlsxFile=${fls[$i]}
  edfFile=${xlsxFile/xlsx/edf}

  # run julia tool
  julia --st no ${chFFTA3} -f ${edfFile} # -a ${xlsxFile}
done

################################################################################
