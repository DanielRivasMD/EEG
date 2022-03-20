################################################################################

# declarations
source('/Users/drivas/Factorem/EEG/src/config/config.R')

################################################################################

# load packages
library(circlize)

################################################################################

# read files
x <- read_csv('/Users/drivas/Factorem/MindReader/data/csv/sample.csv')

################################################################################

# extract states
states <- x %>% apply(FUN = table, MARGIN = 2) %>% rownames

################################################################################

# generate colors
colors = structure(seq(length(states)), names = states)

################################################################################

# open plotting device


# plot as discrete values
x %>%
  apply(FUN = as.character, MARGIN = 1) %>%
  as.matrix %>%
  Heatmap(name = 'Predicted\nanomaly\nstates', col = colors, use_raste = F)

# close plotting device


################################################################################
