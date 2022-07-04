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
  ((i++))
done < <(ls ${eegDir}/*xlsx)

# loop through healthy files
healthy0=0
healthy1=20
for ((i = ${healthy0}; i < ${healthy1}; i++))
do
  xlsxFile=${fls[$i]}
  edfFile=${xlsxFile/xlsx/edf}

  # run julia tool
  julia --st no ${chFFTA3} -f ${edfFile} -a ${xlsxFile}
done

################################################################################
