################################################################################

using MultivariateStats, RDatasets, Plots

################################################################################

plotly() # using plotly for 3D-interacive graphing

################################################################################

# load iris dataset
iris = dataset("datasets", "iris")

################################################################################

# split half to training set
Xtr = convert(Array, iris[1:2:end,1:4])'
Xtr_labels = convert(Array, iris[1:2:end,5])

# split other half to testing set
Xte = convert(Array, iris[2:2:end,1:4])'
Xte_labels = convert(Array, iris[2:2:end,5])

################################################################################

# suppose Xtr and Xte are training and testing data matrix,
# with each observation in a column

# train a PCA model, allowing up to 3 dimensions
M = fit(PCA, Xtr; maxoutdim = 3)

# apply PCA model to testing set
Yte = MultivariateStats.transform(M, Xte)

# reconstruct testing observations (approximately)
Xr = reconstruct(M, Yte)

################################################################################

# group results by testing set labels for color coding
setosa = Yte[:, Xte_labels .== "setosa"]
versicolor = Yte[:, Xte_labels .== "versicolor"]
virginica = Yte[:, Xte_labels .== "virginica"]

################################################################################

# visualize first 3 principal components in 3D interacive plot
p = scatter(setosa[1, :], setosa[2, :], setosa[3, :], marker = :circle, linewidth = 0)
scatter!(versicolor[1, :], versicolor[2, :], versicolor[3, :], marker = :circle, linewidth = 0)
scatter!(virginica[1, :], virginica[2, :], virginica[3, :], marker = :circle, linewidth = 0)
plot!(p, xlabel = "PC1", ylabel = "PC2", zlabel = "PC3")

################################################################################
