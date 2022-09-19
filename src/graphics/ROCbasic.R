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

    # new device
    quartz()

    # plot
    plot(
      x = (1 - csv[['Specificity']]),
      y = csv[['Sensitivity']],
      pch = 16,
      col = 'navyblue',
      xlim = c(0, 1),
      ylim = c(0, 1),
      las = 1,
      xlab = 'False Positive Rate',
      ylab = 'True Positive Rate',
      main = 'Receiver Operating Characteristic (ROC) curve',
      sub = ƒ %>% str_replace('.csv', ''),
    )

    lines(
      x = 0:1,
      y = 0:1,
      col = 'red',
    )
  }
}

####################################################################################################
