################################################################################

pdf("outDir/performance.pdf", width = 12, height = 9)

################################################################################

# margins
defParMar <- par("mar")
par(mar = c(2, defParMar[c(-1, -4)], 5))
par(xpd = NA)

################################################################################

# barplot
barplot(
  t(ssDf[, 'specificity']) * 100,
  # t(ssDf[, c('sensitivity', 'specificity')]) * 100,
  beside = T,
  ylim = c(0, 100),
  xaxt = 'n',
  border = NA,
  col = 'steelblue'
  # col = c('peru', 'steelblue')
)

################################################################################

# # legend
# # sensitivity
# rect(
#   xleft = (par("usr")[2] - 3),
#   ybottom = 89,
#   xright = (par("usr")[2] - 1),
#   ytop = 90,
#   border = NA,
#   col = 'peru'
# )

# text(
#   x = par("usr")[2],
#   y = 90 - 0.5,
#   label = 'Sensitivity',
#   cex = 0.9,
#   adj = 0
# )

# specificity
rect(
  xleft = (par("usr")[2] - 3),
  ybottom = 87,
  xright = (par("usr")[2] - 1),
  ytop = 88,
  border = NA,
  col = 'steelblue'
)

text(
  x = par("usr")[2],
  y = 88 - 0.5,
  label = 'Specificity',
  cex = 0.9,
  adj = 0
)

lines(
  x = c(par("usr")[2] - 3, par("usr")[2] + 7),
  y = c(86, 86),
  lwd = 2,
  col = 'peru'
)

text(
  x = par("usr")[2] - 3.5,
  y = 84 - 0.5,
  label = ' 71%',
  cex = 0.9,
  adj = 0
)

text(
  x = par("usr")[2],
  y = 84 - 0.5,
  label = 'Average',
  cex = 0.9,
  adj = 0
)

text(
  x = par("usr")[2] - 3.5,
  y = 82 - 0.5,
  label = ' 60%',
  cex = 0.9,
  adj = 0
)

text(
  x = par("usr")[2],
  y = 82 - 0.5,
  label = 'Generalized',
  cex = 0.9,
  adj = 0
)

text(
  x = par("usr")[2] - 3.5,
  y = 80 - 0.5,
  label = ' 76%',
  cex = 0.9,
  adj = 0
)

text(
  x = par("usr")[2],
  y = 80 - 0.5,
  label = 'Focalized',
  cex = 0.9,
  adj = 0
)

################################################################################

# bottom bars
# focalized
rect(
  xleft = 1,
  ybottom = -1.5,
  xright = (27 * 2) - 2,
  ytop = -0.5,
  border = NA,
  col = 'magenta3'
)

# generalized
rect(
  xleft = (28 * 2) - 3,
  ybottom = -1.5,
  xright = 40 * 2,
  ytop = -0.5,
  border = NA,
  col = 'springgreen4'
)

################################################################################

# legend
# focalized
rect(
  xleft = (par("usr")[2] - 3),
  ybottom = 99,
  xright = (par("usr")[2] - 1),
  ytop = 100,
  border = NA,
  col = 'magenta3'
)

text(
  x = par("usr")[2],
  y = 100 - 0.5,
  label = 'Focalized',
  cex = 0.9,
  adj = 0
)

# generalized
rect(
  xleft = (par("usr")[2] - 3),
  ybottom = 97,
  xright = (par("usr")[2] - 1),
  ytop = 98,
  border = NA,
  col = 'springgreen4'
)

text(
  x = par("usr")[2],
  y = 98 - 0.5,
  label = 'Generalized',
  cex = 0.9,
  adj = 0
)

################################################################################

dev.off()

################################################################################
