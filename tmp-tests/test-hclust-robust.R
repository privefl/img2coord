library(doParallel)
registerDoParallel(cl <- makeCluster(4))
test <- foreach(n = sample(10:100, 100, TRUE), .combine = 'c') %do% {

  # Create image file
  {
    file <- tempfile(fileext = ".png")
    png(file, width = 600, height = 400)
    plot(runif(n))
    dev.off()
  }

  # Get image as sparse matrix
  {
    img <- imager::grayscale(imager::load.image(file))
    # plot(img, rescale = FALSE, axes = FALSE)
    img_mat <- Matrix::Matrix(round(1 - as.matrix(img), 14), sparse = TRUE)
    stopifnot(class(img_mat) == "dgCMatrix")
    dim(img_mat)
    # Matrix::image(img_mat)
  }

  # Get contour and inside
  {
    (list.contour <- img2coord:::get_contours(img_mat))
    img_mat_in <- img2coord:::get_inside(img_mat, list.contour)
  }

  library(Matrix)
  ind <- which(img_mat_in != 0, arr.ind = TRUE)
  ind

  clusters <- img2coord:::get_clusters(ind, 5:110)

  length(unique(clusters)) - n
}
table(test[, 1])
#     0     1     2     3     4     5     6     7     8     9
# 82036  9337  5057  2219   886   318    94    34    13     6
table(test[, 2])
#     0     1     2
# 99732   265     3


stopCluster(cl)

