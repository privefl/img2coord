# Create some images
file <- "inst/extdata/runif1.png"
png(file, width = 600, height = 400)
set.seed(1); y <- c(0, runif(20), 1)
plot(y)
dev.off()

file <- "inst/extdata/runif2.png"
png(file, width = 600, height = 400)
set.seed(2); y <- c(0, runif(40), 1)
plot(y, pch = 20)
dev.off()
