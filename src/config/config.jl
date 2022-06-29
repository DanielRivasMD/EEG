####################################################################################################

begin

  ####################################################################################################

  # project
  projDir = "/Users/drivas/Factorem/EEG"
  mindDir = "/Users/drivas/Factorem/MindReader"

  ####################################################################################################

  # source
  binDir = string(projDir, "/src/bin")
  configDir = string(projDir, "/src/config")
  runDataset = string(projDir, "/src/runDataset")
  annotationDir = string(projDir, "/src/annotation")
  utilDir = string(projDir, "/src/utilities")
  graphDir = string(projDir, "/src/graphics")

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
