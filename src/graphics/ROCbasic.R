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

# ROC plotting function
ROCplot <- function(path) {

  # iterate on numbers
  for (ι in 1:24) {

    # adjust digits
    if (ι < 10) {
      ο <- paste0('0', ι)
    } else {
      ο <- paste0(ι)
    }

    # declare file
    ƒ <- paste0('chb', ο, '.csv')

    # log
    print(ƒ)

    if (file.exists(paste0(mindData, '/', 'roc', '/', path, '/', ƒ))) {

      # load file
      csv <- read_csv(paste0(mindData, '/', 'roc', '/', path, '/', ƒ),
        show_col_types = FALSE,
      )

      # check for non-empty dataframe
      if (dim(csv)[1] > 0) {

        # open device
        png(paste0(mindPlot, '/', path, '/', 'chb', ο, '.png'), width = 15, height = 12, units = 'in', res = 900)

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

        # add diagonal line
        lines(
          x = 0:1,
          y = 0:1,
          col = 'red',
        )

        # close device
        dev.off()
      }
    }
  }
}

####################################################################################################

# declare filters
timeThresholds <- c(120, 100, 80, 60, 40, 20)

# iterate on filters
for (ft in timeThresholds) {
  ROCplot(ft)
}

####################################################################################################
