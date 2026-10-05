# Apply a Complete Theme and Scale Set to a ggplot

This is the primary function of the `themeset` package for local,
per-plot theme application. It applies a pre-defined, cohesive set of a
theme, color scale, and fill scale to a specific ggplot object.

## Usage

``` r
apply_theme_set(plot, set)
```

## Arguments

- plot:

  A ggplot object to modify.

- set:

  The name of the theme set to apply. Run
  [`list_theme_sets()`](https://vanhungtran.github.io/themeset/reference/list_theme_sets.md)
  to see available options.

## Value

A modified ggplot object.

## Examples

``` r
library(ggplot2)
od <- subset(example_growth(), measure == "OD600")
p <- ggplot(od, aes(x = time, y = value, color = strain)) +
  geom_line() +
  geom_point()

apply_theme_set(p, "simpsons")


# A journal set: the classic theme with the NEJM palette
apply_theme_set(p, "nejm")
```
