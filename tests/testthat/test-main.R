################################################################################

context("test-main")

RMSE <- function(y1, y2) mean((y1 - y2)^2)

################################################################################

test_that("works with 'runif1.png'", {
  file <- system.file("extdata", "runif1.png", package = "img2coord")
  set.seed(1); y <- c(0, runif(20), 1)
  expect_warning(get_coord(file, seq(5, 20, 5), 1:5 / 5, K_min = 15, K_max = 25),
                 "Something may have gone wrong in tick2val().", fixed = TRUE)
  test <- get_coord(file, seq(5, 20, 5), 0:5 / 5, K_min = 15, K_max = 25)
  expect_length(test$x, length(y))
  expect_lt(RMSE(test$x, seq_along(y)), 1e-5)
  expect_lt(RMSE(test$y, y), 1e-7)
})

################################################################################

test_that("works with 'runif2.png'", {
  file <- system.file("extdata", "runif2.png", package = "img2coord")
  set.seed(2); y <- c(0, runif(40), 1)
  expect_warning(get_coord(file, seq(0, 40, 10), 1:5 / 5, K_min = 30, K_max = 50),
                 "Something may have gone wrong in tick2val().", fixed = TRUE)
  test <- get_coord(file, seq(0, 40, 10), 0:5 / 5, K_min = 30, K_max = 50)
  expect_length(test$x, length(y))
  expect_lt(RMSE(test$x, seq_along(y)), 1e-5)
  expect_lt(RMSE(test$y, y), 1e-7)
})

################################################################################

test_that("works with 'plot.gif'", {
  file <- system.file("extdata", "plot.gif", package = "img2coord")
  expect_is(img_read(file), "magick-image")
  # tick are inside -> won't work
  # get_coord(file, 1:8, seq(100, 300, 100), K_min = 10, K_max = 25)
})

################################################################################

test_that("works with 'squares.png'", {
  file <- system.file("extdata", "squares.png", package = "img2coord")
  expect_error(
    get_coord(file, seq(0, 20, 5), seq(94, 102, 2), K_min = 40, K_max = 80),
    "Detected more than")
  test <- file %>% img_read() %>% img_scale(0.25) %>%
    get_coord(seq(0, 20, 5), seq(94, 102, 2), K_min = 40, K_max = 80)
  x <- 0:60 / 3
  expect_length(test$x, length(x))
  expect_lt(RMSE(test$x, x), 1e-4)
  test2 <- file %>% img_read() %>% img_scale(0.2) %>%
    get_coord(seq(0, 20, 5), seq(94, 102, 2), K_min = 40, K_max = 80)
  expect_lt(RMSE(test2$x, x), 1e-4)
  expect_lt(RMSE(test2$y, test$y), 1e-5)
})

################################################################################
