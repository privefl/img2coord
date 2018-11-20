# Create image file
{
  file <- tempfile(fileext = ".png")
  png(file, width = 600, height = 400)
  plot(runif(20))
  dev.off()
}

# Inputs
{
  file <- "tmp-png/prs_bc.png"
  x.ticks <- seq(0, 30, 5)
  y.ticks <- rev(1:5)
}

# Get image as sparse matrix
{
  img <- imager::grayscale(imager::load.image(file))
  plot(img, rescale = FALSE, axes = FALSE)
  img_mat <- Matrix::Matrix(round(1 - as.matrix(img), 14), sparse = TRUE)
  stopifnot(class(img_mat) == "dgCMatrix")
  dim(img_mat)
  Matrix::image(img_mat)
}

# Get contour and inside
{
  (list.contour <- img2coord:::get_contours(img_mat))
  img_mat_in <- img2coord:::get_inside(img_mat, list.contour)
}

library(Matrix)
ind <- which(img_mat_in != 0, arr.ind = TRUE)
ind

clusters <- img2coord:::get_clusters(ind)

centers <- img2coord:::get_centers(img_mat_in, ind, clusters)
plot(ind, pch = 20)
points(t(centers), col = "red", pch = 20, lwd = 2)



# ticks to values
mods <- img2coord:::get_tick_mod(img_mat, list.contour,
                                 val_tick_x = seq(0, 12, 2),
                                 val_tick_y = seq(0, 300, 100))


pos <- sweep(t(centers), 2, attr(img_mat_in, "offset"), '+')
points(pos, pch = 20, col = "red")
x <- predict(mods$mod.x, data.frame(pos = pos[, 1]))
y <- predict(mods$mod.y, data.frame(pos = pos[, 2]))

res <- data.frame(x, y)
as.list(res[order(res$x), ])
