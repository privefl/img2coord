################################################################################

#' Get coordinates from image of points
#'
#' @param input Path to image or directly a Magick image.
#' @param x_ticks Values of all ticks of the x axis.
#' @param y_ticks Values of all ticks of the y axis.
#' @param K Number of points in the image.
#'   Use `K_min` and `K_max` if you only know an interval.
#' @param K_min Minimum number of points in the image.
#' @param K_max Maximum number of points in the image.
#' @param max_pixels Maximum number of pixels representing points.
#' @param plot Whether to plot centers on the image? Default is `TRUE`.
#'
#' @return A list of coordinates. There is also an attribute "stat" which was
#'   used to guess the number of points in the image.
#' @export
#'
#' @import ggplot2
#'
#' @examples
#' # Create some image
#' file <- tempfile(fileext = ".png")
#' png(file, width = 600, height = 400)
#' plot(y <- c(0, runif(20), 1))
#' dev.off()
#'
#' # Get coordinates
#' (coord <- get_coord(file, seq(5, 20, 5), seq(0, 1, 0.2),
#'                     K_min = 10, K_max = 30))
#' round(coord$x, 2)
#' plot(coord$y, y, pch = 20, cex = 1.5); abline(0, 1, col = "red")
#'
#' # When the image is too large, you can downsize it
#' (coord2 <- file %>% img_read() %>% img_scale(0.7) %>%
#'     get_coord(seq(5, 20, 5), seq(0, 1, 0.2), K_min = 10, K_max = 30))
#' round(coord2$x, 2)
#' plot(coord2$y, y, pch = 20, cex = 1.5); abline(0, 1, col = "red")
#'
get_coord <- function(input, x_ticks, y_ticks, K, K_min = K, K_max = K,
                      max_pixels = 10e3, plot = TRUE) {

  # Get image as matrix
  img <- `if`(inherits(input, "magick-image"), input, img_read(input))
  img_mat <- img2mat(img)

  # Get contour and inside
  list.contour <- get_contours(img_mat)
  img_mat_in <- get_inside(img_mat, list.contour)

  # Get points
  ind <- which(img_mat_in > 0, arr.ind = TRUE)
  if (nrow(ind) > max_pixels) {
    stop(call. = FALSE, sprintf(
      "Detected more than %d pixels associated with points (%d).%s%s%s",
      max_pixels, nrow(ind),
      "\n  Make sure you have a white background with no grid (only points).",
      "\n  You can change 'max_pixels', but it could become time/memory consuming.",
      "\n  You can also downsize the image using `img_scale()`."))
  }

  # Get clusters and centers
  clusters <- get_clusters(ind, seq(K_min, K_max))
  centers <- get_centers(img_mat_in, ind, clusters)
  pos <- sweep(centers, 2, attr(img_mat_in, "offset"), '+')

  # Initial image with guessed centers
  p <- magick::image_ggplot(img) +
    geom_point(aes(col, row), data = as.data.frame(pos), color = "red") +
    ggtitle(sprintf("%d points", attr(clusters, "K_opt"))) +
    theme(plot.title = element_text(size = rel(1.5), hjust = 0.5))
  if (plot) print(p)

  # ticks to values
  mods <- get_tick_mod(img_mat, list.contour, x_ticks, y_ticks)
  x <- stats::predict(mods$mod.x, data.frame(pos = pos[, 2]))
  y <- stats::predict(mods$mod.y, data.frame(pos = pos[, 1]))

  res <- data.frame(x, y)
  structure(as.list(res[order(res$x), ]), stat = attr(clusters, "stat"))
}

################################################################################
