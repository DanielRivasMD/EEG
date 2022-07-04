################################################################################

# # basic R
# plot(
#   0,
#   type = 'n',
#   main = 'PCA',
#   xlim = c(-0.5, 0.5),
#   ylim = c(-0.5, 0.5),
#   xlab = '',
#   ylab = ''
# )
#
# for (c in seq_along(states)) {
#   points(xr[seq(from = c, to = dim(xr)[1], by = length(states)), ], pch = seq_along(electrodeID), col = c)
# }

################################################################################

# ggplot
# pacman::p_load(ggplot2)

# auto track index
ix <- length(gls) + 1

xr <- data.frame(PCA1 = as.numeric(unlist(xr[, 1])), PCA2 = as.numeric(unlist(xr[, 2])), electrode = unlist(xr[, 3]), state = as.character(unlist(xr[, 4])))

# pdf('pca_plot.pdf', width = 12, height = 9)

gls[[ix]] <- ggplot(xr, aes(x = PCA1, y = PCA2)) +
geom_point(aes(color = state, shape = electrode)) +
scale_shape_manual(name = 'Electrode', values = 1:21) +
scale_colour_manual(name = 'States', values=c('1' = 'black', '2' = 'firebrick', '3' = 'red', '4' = 'forestgreen', '5' = 'hotpink', '6' = 'blue')) +
ggtitle(ko) +
xlim(c(-0.5, 0.5)) +
ylim(c(-0.5, 0.5)) +
theme_minimal()

# ggplot(xr, aes(x = PCA1, y = PCA2)) +
# geom_point(aes(color = state, shape = electrode)) +
# scale_shape_manual(values = 1:21) +
# scale_colour_manual(name = 'States', values=c('1' = 'black', '2' = 'firebrick', '3' = 'red', '4' = 'forestgreen', '5' = 'hotpink', '6' = 'blue')) +
# theme_minimal()

# dev.off()

################################################################################
