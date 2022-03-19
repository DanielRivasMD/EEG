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

# loop through generalized files
generalized0=20
generalized1=50
for (( i = ${generalized0}; i < ${generalized1}; i++ ))
do
  xlsxFile=${fls[$i]}
  edfFile=${xlsxFile/xlsx/edf}

  # run julia tool
  julia --st no ${chFFTA3} -f ${edfFile} # -a ${xlsxFile}
done

################################################################################
