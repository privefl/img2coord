file <- tempfile(fileext = ".png")
png(file, width = 600, height = 400)
plot(sqrt(1:30))
dev.off()

library(imager)
(img <- imager::load.image(file))
plot(img)
dim(img2 <- as.matrix(grayscale(img)))

library(Matrix)
img3 <- Matrix(round(1 - img2, 14), sparse = TRUE)
image(img3)
dim(img3)

row <- rowMeans(img3 != 0)
col <- colMeans(img3 != 0)
which(row > 0.5)
which(col > 0.5)

img4 <- img3[62:568, 62:325]
image(img4)
ind <- which(img4 != 0, arr.ind = TRUE)
ind

plot(ind)

K <- 20:40
maxiter <- 500L
system.time(
  val2 <- sapply(K, function(k) {
    cat("|", k, "|")
    km <- cluster::fanny(ind, k,
                         keep.diss = FALSE, keep.data = FALSE, tol = 1e-5,
                         maxit = maxiter + 5L)
    iter <- km$convergence[["iterations"]]
    if (iter > 0) {
      maxiter <<- min(maxiter, iter)
    }
    # plot(ind, main = k, pch = 20)
    # points(km$centers, col = "red", pch = 20, lwd = 3)
    c(km$coeff, iter)
  })
) # 101 -> 21 (keeps & tol) -> 10 (maxit)
val2

# plot(K, val2[1, ], pch = 20, ylim = c(0.5, 1))  ## bof
plot(K, val2[2, ], pch = 20)  ## nice
K_max <- K[which.max(val2[2, ])]
abline(v = K_max)

plot(ind, pch = 20)

km_opt <- cluster::fanny(ind, K_max)
groups <- as.factor(km_opt$clustering)
i.groups <- split(1:nrow(ind), groups)
centers <- sapply(i.groups, function(i) {
  x.group <- ind[i, 1]
  y.group <- ind[i, 2]
  p.group <- img4[cbind(x.group, y.group)]
  x.mean <- weighted.mean(x.group, p.group)
  y.mean <- weighted.mean(y.group, p.group)
  c(x.mean, y.mean)
})
points(t(centers), col = "red", pch = 20, lwd = 2)

# ticks
which(row > 0.5)
which(col > 0.5)
(ind.y <- which(img3[57, ] != 0))
(ind.x <- which(img3[, 329] != 0))

x.ticks <- seq(0, 30, 5)
y.ticks <- rev(1:5)

tick2val <- function(ticks, ind) {
  N <- length(ind)
  val <- rep(NA_real_, N)
  k <- 1
  for (i in seq_len(N)) {
    val[i] <- ticks[k]
    if (isTRUE(ind[i + 1] != (ind[i] + 1L))) k <- k + 1
  }
  val
}

x.val <- tick2val(x.ticks, ind.x)
y.val <- tick2val(y.ticks, ind.y)
lm.x <- lm(value ~ pos, weights = img3[ind.x, 329],
           data = data.frame(pos = ind.x, value = x.val))
summary(lm.x)
stopifnot(summary(lm.x)$adj.r.squared > 0.99)

lm.y <- lm(value ~ pos, weights = img3[57, ind.y],
           data = data.frame(pos = ind.y, value = y.val))
stopifnot(summary(lm.y)$adj.r.squared > 0.99)

predict(lm.x, data.frame(pos = centers[1, ] + 61))
predict(lm.y, data.frame(pos = centers[2, ] + 61))

plot(img)
points(t(centers) + 61, pch = 20, col = "red")
