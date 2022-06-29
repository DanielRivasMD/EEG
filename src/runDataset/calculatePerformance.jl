####################################################################################################

# declarations
begin
  include( "/Users/drivas/Factorem/EEG/src/config/config.jl" )
end;

####################################################################################################

# TODO: read annotation
if haskey(shArgs, "annotation") && haskey(shArgs, "annotDir")
  annotFile = annotationReader(
    string(shArgs["annotDir"], shArgs["annotation"]),
  )
end

####################################################################################################

# TODO: calibrate annotations
if haskey(annotFile, replace(shArgs["input"], ".edf" => ""))
  labelAr = annotationCalibrator(
    annotFile[replace(shArgs["input"], ".edf" => "")];
    # BUG: annotation probably offset for calling wrong function
    startTime = startTime,
    recordFreq = recordFreq,
    signalLength = size(edfDf, 1),
    shParams = shArgs,
  )
end

####################################################################################################

# TODO: load hmm

####################################################################################################

# TODO: calculate accuracy
sensitivitySpecificity(hmmDc, labelAr)

####################################################################################################
