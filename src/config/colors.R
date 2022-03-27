################################################################################

# color names
colorLabs <- c('black', 'tomato', 'lightsalmon', 'goldenrod', 'darkolivegreen', 'lightseagreen', 'darkslategray', 'steelblue', 'slateblue', 'lavender')

################################################################################

# RGB
rgbColors <- matrix(
  data = c(
    c(0, 0, 0),
    c(255, 99, 71),
    c(255, 160, 122),
    c(218, 165, 32),
    c(85, 107, 47),
    c(32, 178, 170),
    c(47, 79, 79),
    c(70, 130, 180),
    c(106, 90, 205),
    c(230, 230, 250)
  ),
  nrow = 3,
) %>% t

colnames(rgbColors) <- c('r', 'g', 'b')
rownames(rgbColors) <- colorLabs

################################################################################

# HEX
hexColors <- matrix(
  data = c(
    '#000000', '#ff6347', '#ffa07a', '#daa520', '#556b2f', '#20b2aa', '#2f4f4f', '#4682b4', '#6a5acd', '#e6e6fa'
  ),
  ncol = 1,
)

colnames(hexColors) <- c('hex')
rownames(hexColors) <- colorLabs

################################################################################

# HEX
heatNo <- 4
hexColors <- matrix(
  data = c('#000000', heat.colors(heatNo)),
  ncol = 1,
)

colnames(hexColors) <- c('hex')
rownames(hexColors) <- c('black', paste0('heat', heatNo:1))

################################################################################
