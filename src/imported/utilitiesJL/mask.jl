################################################################################

conicRange = range(0, 3, length = 101)
conicMask = [sin(i) * sin(j) for i in conicRange, j in conicRange]
heatmap(conicMask)

################################################################################
