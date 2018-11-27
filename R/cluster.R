################################################################################

get_centers <- function(img_mat_in, points, clusters) {
  do.call("rbind", by(points, clusters, FUN = function(pts) {
    pts <- as.matrix(pts)
    apply(pts, 2, stats::weighted.mean, w = img_mat_in[pts])
  }, simplify = FALSE))
}

################################################################################

centers <- function(points, clusters) {
  do.call("rbind", by(points, clusters, colMeans, simplify = FALSE))
}

################################################################################

get_clusters <- function(points, K_seq) {

  d <- stats::dist(points)
  hc <- flashClust::hclust(d)

  stats <- sapply(K_seq, function(k) {
    clusters_k <- stats::cutree(hc, k)
    c(ineq::Gini(table(clusters_k)),
      mean(cluster::silhouette(clusters_k, d)[, 3]))
  })
  stat <- stats[2, ]^2 / stats[1, ]

  K_opt <- K_seq[which.max(stat)]

  # For some reason, this final step gives more precise results
  centers.init <- centers(points, stats::cutree(hc, K_opt))
  suppressWarnings(
    km_opt <- stats::kmeans(points, centers = centers.init, iter.max = 1000))

  structure(km_opt$cluster, stat = stats::setNames(stat, K_seq), K_opt = K_opt)
}

################################################################################
