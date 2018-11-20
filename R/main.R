################################################################################

#' Get coordinates from image of points
#'
#' @param file Path to image.
#' @param x_ticks
#' @param y_ticks
#' @param K Number of points in the image.
#'   Use `K_min` and `K_max` if you only know an interval.
#' @param K_min Minimum number of points in the image.
#' @param K_max Maximum number of points in the image.
#'
#' @return A list of coordinates. There is also an attribute "stat" which was
#'   used to guess the number of points in the image.
#' @export
#'
#' @import Matrix
#'
#' @examples
#' # Create some image
#' file <- tempfile(fileext = ".png")
#' png(file, width = 600, height = 400)
#' plot(y <- c(0, runif(20), 1))
#' dev.off()
#'
#' # Get coordinates
#' (coord <- img2coord(file, seq(5, 20, 5), seq(0, 1, 0.2),
#'                     K_min = 10, K_max = 30))
#' round(coord$x, 1)
#' plot(coord$y, y, pch = 20, cex = 1.5); abline(0, 1, col = "red")
#'
img2coord <- function(file, x_ticks, y_ticks, K, K_min = K, K_max = K) {

  # Get image as sparse matrix
  img <- imager::grayscale(imager::load.image(file))

  img_mat <- Matrix(round(1 - as.matrix(img), 14), sparse = TRUE)
  stopifnot(class(img_mat) == "dgCMatrix")

  # Get contour and inside
  list.contour <- get_contours(img_mat)
  img_mat_in <- get_inside(img_mat, list.contour)

  # Get points
  ind <- which(img_mat_in != 0, arr.ind = TRUE)

  # Get clusters and centers
  clusters <- get_clusters(ind, seq(K_min, K_max))
  centers <- get_centers(img_mat_in, ind, clusters)

  # ticks to values
  mods <- get_tick_mod(img_mat, list.contour, x_ticks, y_ticks)

  plot(img, rescale = FALSE, axes = FALSE,
       main = sprintf("%d points", attr(clusters, "K_opt")))
  pos <- sweep(centers, 2, attr(img_mat_in, "offset"), '+')
  points(pos, pch = 20, col = "red")

  x <- predict(mods$mod.x, data.frame(pos = pos[, 1]))
  y <- predict(mods$mod.y, data.frame(pos = pos[, 2]))

  res <- data.frame(x, y)
  structure(as.list(res[order(res$x), ]), stat = attr(clusters, "stat"))
}

################################################################################