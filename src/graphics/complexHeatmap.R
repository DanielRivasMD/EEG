################################################################################

# declarations
source('/Users/drivas/Factorem/EEG/src/config/config.R')

################################################################################

# load packages

################################################################################

# load colors
source(paste0(configDir, '/colors.R'))

################################################################################

# read files
anomalyHm <- read_csv(paste0(mindCSV, '/sample.csv'))
states <- anomalyHm %>% apply(FUN = table, MARGIN = 2) %>% rownames

################################################################################

# open plotting device
jpeg(file = paste0(mindPlot, '/sample.jpg'), width = 8000, height = 3000, pointsize = 100, quality = 100)
# pdf(file = paste0(mindPlot, '/sample.pdf'), width = 16, height = 12)

# # backup plotting area
# defParMar <- par('mar')

# # expand plotting area
# par(mar = c(defParMar[-4], 5))                              # expand on the right
# par(mar = c(defParMar[1:2], 10, defParMar[4]))              # expand on top

# plot with image
anomalyHm[1:1000, ] %>%
  as.matrix %>%
  image(
    col = hexColors,
    xaxt = 'n',
    yaxt = 'n',
    xlab = 'Time along recording',
  )

# y axis labels
axis(
  2,
  las = 1,
  at = seq(from = 0, to = 1, length.out = length(names(anomalyHm))),
  labels = names(anomalyHm),
  tick = FALSE,
)

# # activate outside plotting area
# par(xpd = NA)

# # annotations rectangles
# annotScale <- 1 / length(states)

# for(ix in seq_along(states)) {

#   # annotation rectangles
#   rect(
#     xleft = (par('usr')[2] * 1.04),
#     ybottom = (par('usr')[4] * (ix - 0.9) * annotScale),
#     xright = (par('usr')[2] * 1.07),
#     ytop = (par('usr')[4] * (ix) * annotScale),
#     border = NA,
#     col = rgb(
#       red = rgbColors[ix, 'r'],
#       green = rgbColors[ix, 'g'],
#       blue = rgbColors[ix, 'b'],
#       max = 255,
#       alpha = 255,
#     )
#   )

#   # annotation text
#   text(
#     x = (par('usr')[2] * 1.08),
#     y = (par('usr')[4] * (ix - 0.5) * annotScale),
#     label = paste0('State: ', states[ix]),
#     cex = 0.7,
#     adj = 0,
#   )

# }

# # reset plotting area
# par(mar = defParMar)

# close plotting device
dev.off()

################################################################################
