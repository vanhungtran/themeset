# Custom Plot Themes

Custom themes included with the package that can be added directly to a
`ggplot2` plot.

## Usage

``` r
theme_nyt(gridline_x = TRUE, gridline_y = TRUE)

theme_midnight(base_size = 11, base_family = "")

theme_royal(base_size = 11, base_family = "")

theme_deepblue(base_size = 11, base_family = "")
```

## Arguments

- gridline_x, gridline_y:

  For `theme_nyt()`: if `TRUE` (the default), draw the major gridlines
  of the x or y axis as thin dashed grey lines; otherwise omit them.

- base_size, base_family:

  For `theme_midnight()`, `theme_royal()` and `theme_deepblue()`: base
  font size (in points) and font family, passed on to
  [`ggplot2::theme_gray()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

## Value

A `ggplot2` theme object.

## Details

`theme_midnight()`, `theme_royal()` and `theme_deepblue()` are dark
themes. With ggplot2 4.0 or later they also set the default color of
points, lines, bars and text to a light one, so a layer without a color
mapping, such as
[`geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html),
is visible on the dark panel.
