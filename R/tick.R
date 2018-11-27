################################################################################

tick2val <- function(uval, ind) {

  N <- length(ind)
  val <- rep(NA, N)

  k <- 1
  for (i in seq_len(N)) {
    val[i] <- uval[k]
    if (isTRUE(ind[i + 1] != (ind[i] + 1L))) k <- k + 1
  }

  if (k != length(uval))
    warning(call. = FALSE, "Something may have gone wrong in tick2val().")

  val
}

################################################################################

get_contours <- function(img_mat) {

  cont.ind1 <- which(rowMeans(img_mat > 0.1) > 0.5)
  cont.ind2 <- which(colMeans(img_mat > 0.1) > 0.5)

  cont.bool1 <- tick2val(c(FALSE, TRUE), cont.ind1)
  cont.bool2 <- tick2val(c(FALSE, TRUE), cont.ind2)

  list(
    ind1.min = cont.ind1[!cont.bool1],
    ind1.max = cont.ind1[cont.bool1],
    ind2.min = cont.ind2[!cont.bool2],
    ind2.max = cont.ind2[cont.bool2]
  )
}

################################################################################

get_inside <- function(img_mat, list_ind_cont) {
  l <- list_ind_cont
  i1.min <- max(l$ind1.min) + 2L
  i1.max <- min(l$ind1.max) - 2L
  i2.min <- max(l$ind2.min) + 2L
  i2.max <- min(l$ind2.max) - 2L
  structure(img_mat[seq(i1.min, i1.max), seq(i2.min, i2.max)],
            offset = c(i1.min, i2.min) - 1L)
}

################################################################################

get_tick_mod <- function(img_mat, list_ind_cont, val_tick_x, val_tick_y) {

  i.x <- max(list_ind_cont$ind1.max) + 2L
  i.y <- min(list_ind_cont$ind2.min) - 2L

  ind.x <- which(img_mat[i.x, ] > 0.1)
  ind.y <- which(img_mat[, i.y] > 0.1)

  w.x <- img_mat[i.x, ind.x]
  w.y <- img_mat[ind.y, i.y]

  x.val <- tick2val(val_tick_x, ind.x)
  y.val <- tick2val(rev(val_tick_y), ind.y)

  suppressWarnings({
    lm.x <- stats::lm(value ~ pos, weights = w.x,
                      data = data.frame(pos = ind.x, value = x.val))
    stopifnot(summary(lm.x)$adj.r.squared > 0.99)

    lm.y <- stats::lm(value ~ pos, weights = w.y,
                      data = data.frame(pos = ind.y, value = y.val))
    stopifnot(summary(lm.y)$adj.r.squared > 0.99)
  })

  list(mod.x = lm.x, mod.y = lm.y)
}

################################################################################
