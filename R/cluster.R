################################################################################

#' Regroup points in clusters by using hclust()
get_clusters <- function(points) {

  hc <- stats::hclust(stats::dist(points))

  x <- hc$height
  max <- sapply(seq_along(x), function(i) {
    y <- head(x, i)
    quantile(y, 0.75) + 1.5 * IQR(y)
  })

  K <- min(which(cumsum(rev(x > max)) != seq_along(x)))

  stats::cutree(hc, K)
}

################################################################################

#' Get centers by computing the barycenter of pixels of each cluster
get_centers <- function(img_mat_in, points, clusters) {

    sapply(split(seq_len(nrow(points)), f = clusters), function(ind) {
      x.group <- points[ind, 1]
      y.group <- points[ind, 2]
      w.group <- img_mat_in[cbind(x.group, y.group)]
      x.mean <- stats::weighted.mean(x.group, w.group)
      y.mean <- stats::weighted.mean(y.group, w.group)
      c(x.mean, y.mean)
    })
}

################################################################################
