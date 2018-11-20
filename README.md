# img2coord

R package to guess coordinates from a scatter plot (as an image).

## Installation and usage

```
devtools::install_github("privefl/img2coord")
library(img2coord)
?get_coord
```

## Example

### Input image

<center><img src="tmp-png/prs_bc.png" style="width:75%;"></center>

### Code

```
get_coord(
  "tmp-png/prs_bc.png",
  x_ticks = seq(0, 12, 2),
  y_ticks = 52:57 / 100, 
  K_min = 10, 
  K_max = 30
)
```

### Guessed points

<center><img src="tmp-png/prs_bc_guessed.png" style="width:82%;"></center>
