# Create image file
{
  file <- tempfile(fileext = ".png")
  png(file, width = 600, height = 400)
  plot(runif(30))
  dev.off()
}

# Inputs
{
  K <- 30
  x.ticks <- seq(0, 30, 5)
  y.ticks <- rev(1:5)
}

# Get image as sparse matrix
{
  img_mat <- img2coord:::img2Matrix(file)
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

K_opt <- img2coord:::get_K_opt(ind, K)

centers <- img2coord:::get_centers(img_mat_in, ind, K_opt)
plot(ind, pch = 20)
points(t(centers), col = "red", pch = 20, lwd = 2)

# ticks to values
mods <- img2coord:::get_tick_mod(img_mat, list.contour, x.ticks, y.ticks)

offset <- attr(img_mat_in, "offset")
x <- predict(mods$mod.x, data.frame(pos = centers[1, ] + offset[1]))
y <- predict(mods$mod.y, data.frame(pos = centers[2, ] + offset[2]))

res <- data.frame(x, y)
as.list(res[order(res$x), ])
