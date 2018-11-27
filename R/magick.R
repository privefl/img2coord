################################################################################

#' @importFrom magick %>%
#' @export
magick::`%>%`

################################################################################

#' Read an image
#' @param file Path to image.
#' @export
img_read <- function(file) {
  magick::image_read(file)
}

################################################################################

#' Resize an image
#' @param img Magick image.
#' @param scale Ratio to use for rescaling (the number of pixels).
#' @export
img_scale <- function(img, scale) {
  geom <- magick::geometry_size_percent(100 * sqrt(scale))
  magick::image_scale(img, geometry = geom)
}

################################################################################

img2mat <- function(img) {
  mat <- drop(as.numeric(magick::image_data(img, channels = "gray")))
  round(`if`(mean(mat > 0.99) > 0.5, 1 - mat, mat), 6)
}

################################################################################
