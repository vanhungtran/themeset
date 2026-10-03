# Set a Global Theme and Scales for an R Session

Sets a theme, along with its corresponding default color and fill
scales, for all subsequent ggplot2 plots in the current R session.

## Usage

``` r
set_global_theme(set)
```

## Arguments

- set:

  The name of the theme set to apply globally. Run list_theme_sets() for
  options.

## Value

Invisibly returns the list of theme components that were set.

## See also

[`reset_global_theme()`](https://vanhungtran.github.io/themeset/reference/reset_global_theme.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# This will set the fivethirtyeight theme AND its color scales globally
set_global_theme("fivethirtyeight")

# This plot will now automatically use the theme and scales
ggplot(subset(example_taxa(), taxon == "Bacteroides"),
       aes(x = condition, y = abundance, fill = condition)) +
  geom_boxplot()

reset_global_theme()
} # }
```
