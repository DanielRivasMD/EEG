####################################################################################################
# receiver operating characteristic (ROC) curves
####################################################################################################

# declarations
source('/Users/drivas/Factorem/EEG/src/config/config.R')

####################################################################################################

# load packages
require(magrittr)
require(tidyverse)

####################################################################################################

# for (ƒ in list.files(mindScreen)) {
# for (ƒ in list.files(paste0(mindData, '/filterScreen'))) {
for (ι in 1:24) {

  # adjust digits
  if (ι < 10) {
    ƒ <- paste0('chb', '0', ι, '.csv')
  } else {
    ƒ <- paste0('chb', ι, '.csv')
  }

  # log
  print(ƒ)

  # load file
  csv <- read_csv(paste0(
    paste0(mindData, '/filterScreen'), '/', ƒ),
    show_col_types = FALSE,
  )

  # check for non-empty dataframe
  if (dim(csv)[1] > 0) {



  }

}

####################################################################################################
