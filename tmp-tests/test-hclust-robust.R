library(doParallel)
registerDoParallel(cl <- makeCluster(4))
test <- foreach (n = sample(5:100, 10e3, TRUE), .combine = 'rbind') %dopar% {

  # Create image file
  {
    file <- tempfile(fileext = ".png")
    png(file, width = 600, height = 400)
    plot(runif(n))
    dev.off()
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

  hc <- hclust(dist(ind))
  x <- hc$height
  max <- sapply(seq_along(x), function(i) {
    y <- head(x, i)
    quantile(y, 0.75) + 1 * IQR(y)
  })
  max2 <- sapply(seq_along(x), function(i) {
    y <- head(x, i)
    quantile(y, 0.75) + 1.5 * IQR(y)
  })

  c(min(which(cumsum(rev(x > max)) != seq_along(x))) - n,
    min(which(cumsum(rev(x > max2)) != seq_along(x))) - n)
}
table(test[, 1])
#     0     1     2     3     4     5     6     7     8     9
# 82036  9337  5057  2219   886   318    94    34    13     6
table(test[, 2])
#     0     1     2
# 99732   265     3


stopCluster(cl)

