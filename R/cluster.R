################################################################################

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

get_centers <- function(img_mat_in, points, clusters) {

  do.call("rbind", by(points, clusters, simplify = FALSE, FUN = function(pts) {
    x.group <- pts[, 1]
    y.group <- pts[, 2]
    w.group <- img_mat_in[cbind(x.group, y.group)]
    x.mean <- stats::weighted.mean(x.group, w.group)
    y.mean <- stats::weighted.mean(y.group, w.group)
    c(x.mean, y.mean)
  }))
}

################################################################################

centers <- function(points, clusters) {
  do.call("rbind", by(points, clusters, colMeans, simplify = FALSE))
}

get_clusters <- function(points, K_seq) {

  d <- stats::dist(points)
  hc <- stats::hclust(d)

  stats <- sapply(K_seq, function(k) {
    clusters_k <- stats::cutree(hc, k)
    km <- stats::kmeans(points, centers = centers(points, clusters_k),
                        iter.max = 100)
    c(ineq::Gini(km$size), mean(cluster::silhouette(clusters_k, d)[, 3]))
  })
  stat <- stats[2, ]^2 / stats[1, ]

  K_opt <- K_seq[which.max(stat)]
  centers.init <- centers(points, stats::cutree(hc, K_opt))
  km_opt <- stats::kmeans(points, centers = centers.init, iter.max = 1000)

  structure(km_opt$cluster, stat = stats::setNames(stat, K_seq), K_opt = K_opt)
}

################################################################################
