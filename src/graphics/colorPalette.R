####################################################################################################

# declare rainbow palettes
cool = rainbow(50, start = rgb2hsv(col2rgb('cyan'))[1], end = rgb2hsv(col2rgb('blue'))[1])
warm = rainbow(50, start = rgb2hsv(col2rgb('red'))[1], end = rgb2hsv(col2rgb('yellow'))[1])

# concatenate palettes
cols = c(rev(cool), rev(warm))

# create color palette vector
# customPalette <- c('#FFFFFF', colorRampPalette(cool)(999))
customPalette <- c('#FFFFFF', colorRampPalette(rev(warm))(999))
# customPalette <- c('#FFFFFF', colorRampPalette(cols)(999))

####################################################################################################
