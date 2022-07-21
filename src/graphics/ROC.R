####################################################################################################
# receiver operating characteristic (ROC) curves
####################################################################################################

# declarations
source('/Users/drivas/Factorem/EEG/src/config/config.R')

# electrodes
source(paste0(importDir, '/utilitiesR/electrodeID.R'))

####################################################################################################

# load packages
library(magrittr)
library(tidyverse)

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

    # add columns for ggplot
    csv %<>% add_column('True Positive Rate' = csv[['Sensitivity']])
    csv %<>% add_column('False Positive Rate' = 1 - csv[['Specificity']])

    # assign planes
    csv$plane <- NA

    csv[csv[['Electrode']] %in% templeft, 'plane'] <- 'Temporal Left'
    csv[csv[['Electrode']] %in% midleft, 'plane'] <- 'Central Left'
    csv[csv[['Electrode']] %in% tempright, 'plane'] <- 'Temporal Right'
    csv[csv[['Electrode']] %in% midright, 'plane'] <- 'Central Right'
    csv[csv[['Electrode']] %in% mid, 'plane'] <- 'Central'
    csv[csv[['Electrode']] %in% other, 'plane'] <- 'Other'

    # ggplot
    csv %>% ggplot(
      aes(`False Positive Rate`, `True Positive Rate`)
    ) +

    # points
    geom_point(
      aes(
        shape = plane,
        size = 10,
      ),
      show.legend = FALSE,
    ) +

    # in situ labels
    directlabels::geom_dl(
      aes(
        label = plane,
      ),
      method = 'smart.grid',
    ) +

    # limits
    ylim(0, 1) +
    xlim(0, 1) +

    # theme
    theme_classic()

    # save plot
    ggsave(paste0(mindData, '/plot/', str_replace(ƒ, '.csv', '.png')), width = 16, height = 16)

  }

}

####################################################################################################
