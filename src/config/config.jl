####################################################################################################

# project
projDir = string(homedir(), "/Factorem/EEG")
mindDir = string(homedir(), "/Factorem/MindReader")

####################################################################################################

# data
dataDir = string(projDir, "/data")

# external
externalDir = "/Volumes/G/EEG"

# database
database = string(externalDir, "/physionet.org/files/chbmit/1.0.0")

# source
srcDir = string(projDir, "/src")
binDir = string(srcDir, "/bin")
configDir = string(srcDir, "/config")
importDir = string(srcDir, "/imported")
annotationDir = string(srcDir, "/annotation")
utilDir = string(srcDir, "/utilities")
graphDir = string(srcDir, "/graphics")

####################################################################################################

# data
mindData = string(mindDir, "/data")
mindCM = string(mindData, "/confusionMt")
mindCSV = string(mindData, "/csv")
mindEvent = string(mindData, "/event")
mindHMM = string(mindData, "/hmm")
mindLabel = string(mindData, "/label")
mindLog = string(mindData, "/log")
mindErr = string(mindData, "/err")
mindROC = string(mindData, "/roc")
mindPlot = string(mindData, "/plot")
mindHeatmap = string(mindData, "/heatmap")

####################################################################################################
