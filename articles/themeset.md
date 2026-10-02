Introduction to themeset
================

- [Overview](#overview)
  - [Example Data](#example-data)
  - [Function Reference](#function-reference)
- [1. Quick Start](#1-quick-start)
- [2. Browsing the Available Sets](#2-browsing-the-available-sets)
- [3. Using Themes and Scales
  Separately](#3-using-themes-and-scales-separately)
- [4. Setting a Theme for the Whole
  Session](#4-setting-a-theme-for-the-whole-session)
- [Getting Help](#getting-help)

``` r
library(ggplot2)
library(themeset)
```

## Overview

A **theme set** is a ggplot2 theme bundled with the discrete color and
fill scales that go with it. `themeset` ships 39 of them under short
names such as `"simpsons"`, `"fivethirtyeight"` or `"minimal"`, and a
few functions to apply a set to one plot or to every plot in your
session.

Four sets carry their own scales: `simpsons`, `avatar`, `olink` and
`fivethirtyeight`. The other 35 change only the theme.

The pieces are also exported on their own, so you can mix and match:

- discrete color and fill scales (`scale_color_npg()`,
  `scale_fill_jama()`, …)
- markdown-enabled versions of the base ggplot2 themes
  (`md_theme_minimal()`, …)
- a few custom themes (`theme_nyt()`, `theme_midnight()`, …)

This vignette is a short tour. The other articles go deeper: [Theme Sets
and Color Scales](theme-sets-and-scales.md), [Markdown-Enabled
Themes](markdown-themes.md), [Global and Custom
Themes](global-and-custom-themes.md) and [A Multi-Panel
Figure](multi-panel-figure.md).

### Example Data

The examples use two small simulated data sets that come with the
package as code, so there are no data files. `example_growth()` is a
growth experiment: five bacterial strains and an uninoculated control,
followed over 67 hours and measured four ways. `example_taxa()` compares
the relative abundance of five taxa in three conditions.

``` r
head(example_growth(), 3)
#>   time   strain        measure value  se
#> 1    0 Strain A Product A (uM)     0 0.0
#> 2    5 Strain A Product A (uM)     0 0.0
#> 3   19 Strain A Product A (uM)    10 1.5
head(example_taxa(), 3)
#>         taxon condition abundance
#> 1 Bacteroides   Control      51.1
#> 2 Bacteroides   Control      45.1
#> 3 Bacteroides   Control      25.7
```

### Function Reference

| Category | Function | Description |
|----|----|----|
| **Theme sets** | `apply_theme_set()` | Add a set’s theme, color scale and fill scale to one plot |
|  | `set_global_theme()` | Make a set the default for every plot in the session |
|  | `reset_global_theme()` | Go back to ggplot2’s default theme and palettes |
|  | `list_theme_sets()` | Print the names of the 39 available sets |
| **Color scales** | `scale_color_npg()`, `scale_fill_npg()` | Discrete scales; also `jama`, `avatar`, `simpsons`, `olink` and `fivethirtyeight` |
|  | `list_color_scales()` | Print the names of the scale families |
| **Themes** | `md_theme_minimal()` and seven more | Markdown-enabled versions of the base ggplot2 themes |
|  | `theme_nyt()` | Minimal theme with dashed gridlines and bold titles |
|  | `theme_midnight()`, `theme_royal()`, `theme_deepblue()` | Dark themes |
| **Example data** | `example_growth()`, `example_taxa()` | Simulated growth curves and taxon abundances |

------------------------------------------------------------------------

## 1. Quick Start

`apply_theme_set()` takes a plot and the name of a set. The plot shows
the optical density of five strains and an uninoculated control over
time:

``` r
od <- subset(example_growth(), measure == "OD600")

p <- ggplot(od, aes(time, value, color = strain)) +
  geom_errorbar(aes(ymin = value - se, ymax = value + se), width = 1.5) +
  geom_line() +
  geom_point(size = 2) +
  labs(title = "Growth of five strains", x = "Incubation time (hr)", y = "OD600", color = NULL)

apply_theme_set(p, "simpsons")
```

![](themeset_files/figure-gfm/quick-1.png)<!-- -->

The theme, the color scale and the fill scale of the `simpsons` set were
all added to `p`. The result is an ordinary ggplot object, so you can
keep adding layers to it or save it with `ggsave()`.

Change the name to change the whole look:

``` r
apply_theme_set(p, "avatar")
```

![](themeset_files/figure-gfm/quick_other-1.png)<!-- -->

An unknown name is an error that points back to the list of sets:

``` r
apply_theme_set(p, "nope")
#> Error: Set 'nope' not found. Run list_theme_sets() for available options.
```

------------------------------------------------------------------------

## 2. Browsing the Available Sets

``` r
list_theme_sets()
#> Available theme sets:
#>  [1] "simpsons"        "avatar"          "olink"           "fivethirtyeight"
#>  [5] "nyt"             "midnight"        "royal"           "deepblue"       
#>  [9] "bw"              "classic"         "dark"            "light"          
#> [13] "linedraw"        "minimal"         "base"            "calc"           
#> [17] "clean"           "economist"       "economist_white" "excel"          
#> [21] "excel_new"       "few"             "foundation"      "gdocs"          
#> [25] "hc"              "igray"           "map_gg"          "pander"         
#> [29] "par"             "solarized"       "solarized_2"     "solid"          
#> [33] "stata"           "tufte"           "wsj"             "ipsum"          
#> [37] "ipsum_rc"        "cowplot"         "minimal_grid"
```

The first four are the complete sets. Every other name selects a theme
only. The [Theme Sets and Color Scales](theme-sets-and-scales.md)
article shows what they look like and which package each one comes from.

The color scales can be listed too:

``` r
list_color_scales()
#> Available color scale sets:
#> [1] "avatar"          "fivethirtyeight" "jama"            "npg"            
#> [5] "olink"           "simpsons"
```

------------------------------------------------------------------------

## 3. Using Themes and Scales Separately

Nothing forces you to go through a set. Themes and scales are ordinary
ggplot2 components and can be combined freely:

``` r
taxa <- example_taxa()

ggplot(taxa, aes(taxon, abundance, fill = condition)) +
  geom_boxplot() +
  labs(x = NULL, y = "Relative abundance (%)", fill = NULL) +
  theme_nyt() +
  scale_fill_jama()
```

![](themeset_files/figure-gfm/separate-1.png)<!-- -->

------------------------------------------------------------------------

## 4. Setting a Theme for the Whole Session

`set_global_theme()` makes a set the default. Plots created afterwards
use its theme and, for sets that have scales, its colors, without any
extra code:

``` r
set_global_theme("fivethirtyeight")

ggplot(subset(taxa, taxon == "Proteobacteria"), aes(condition, abundance, fill = condition)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "This plot has no theme or scale of its own", x = NULL, y = "Relative abundance (%)")
```

![](themeset_files/figure-gfm/global-1.png)<!-- -->

`reset_global_theme()` returns to ggplot2’s defaults:

``` r
reset_global_theme()
```

The [Global and Custom Themes](global-and-custom-themes.md) article
covers what exactly is changed, and the limits of the global palettes.

------------------------------------------------------------------------

## Getting Help

``` r
?apply_theme_set
?set_global_theme
?theme_color_scales
?ggplot2_md_themes
?custom_themes
?example_data
```
