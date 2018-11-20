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

```
$`x`
 [1]  0.01520296  0.06552700  0.12944551  0.20691062  0.30601816  0.44235022  0.64579483
 [8]  0.94394015  1.37816199  2.01197712  2.93945782  4.29281100  6.27131189  9.15847062
[15] 13.37825095

$y
 [1] 0.5690218 0.5697184 0.5688545 0.5672804 0.5669951 0.5662385 0.5641594 0.5626879
 [9] 0.5586839 0.5497832 0.5453550 0.5513962 0.5612470 0.5511975 0.5183790

attr(,"stat")
       10        11        12        13        14        15        16        17        18 
 2.546514  2.971770  3.757665  5.300410  8.340172 12.016414  7.756150  4.688526  3.406553 
       19        20        21        22        23        24        25        26        27 
 2.604751  2.134128  1.802716  1.541735  1.349889  1.229446  1.119539  1.078786  1.136201 
       28        29        30 
 1.266481  1.041151  0.990828 
```

<center><img src="tmp-png/prs_bc_guessed.png" style="width:82%;"></center>
