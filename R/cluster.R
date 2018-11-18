################################################################################

get_K_opt <- function(points, K_list) {

  maxiter <- 500L
  stat <- sapply(K_list, function(k) {

    cat("|", k, "|")

    suppressWarnings(
      km <- cluster::fanny(points, k, tol = 1e-5, maxit = maxiter + 5L,
                           keep.diss = FALSE, keep.data = FALSE)
    )

    iter <- km$convergence[["iterations"]]
    if (iter > 0) maxiter <<- min(maxiter, iter)

    km$coeff[2]
  })
  cat("\n")

  K_list[which.max(stat)]
}

################################################################################

#' Get centers by computing the barycenter of pixels of each cluster
get_centers <- function(img_mat_in, points, K_opt) {

  cluster::fanny(points, K_opt)$clustering %>%
    split(seq_len(nrow(points)), f = .) %>%
    sapply(function(ind) {
      x.group <- points[ind, 1]
      y.group <- points[ind, 2]
      w.group <- img_mat_in[cbind(x.group, y.group)]
      x.mean <- stats::weighted.mean(x.group, w.group)
      y.mean <- stats::weighted.mean(y.group, w.group)
      c(x.mean, y.mean)
    })
}

################################################################################
