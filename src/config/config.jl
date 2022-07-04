####################################################################################################

begin

  ####################################################################################################

  # project
  projDir = "/Users/drivas/Factorem/EEG"
  mindDir = "/Users/drivas/Factorem/MindReader"

  ####################################################################################################

  # data
  dataDir = string(projDir, "/data")

# source
  srcDir = string(projDir, "/src")
  binDir = string(srcDir, "/bin")
  configDir = string(srcDir, "/config")
  runDataset = string(srcDir, "/runDataset")
  annotationDir = string(srcDir, "/annotation")
  utilDir = string(srcDir, "/utilities")
  graphDir = string(srcDir, "/graphics")

  ####################################################################################################

  # data
  mindData = string(mindDir, "/data")
  mindCSV = string(mindData, "/csv")
  mindHMM = string(mindData, "/hmm")
  mindScreen = string(mindData, "/screen")
  mindPlot = string(mindData, "/plot")

  ####################################################################################################

end;

####################################################################################################
