file <- "inst/extdata/plot.gif"
img <- img_read(file) %>% img_scale(0.2)
mat <- drop(as.numeric(magick::image_data(img, channels = "gray")))
mat2 <- img2coord:::img2mat(img)
dim(mat)
table(mat)
