
<!-- README.md is generated from README.Rmd. Please edit that file -->

# themeset

`themeset` is an R package for reusable plot templates and color scales.
It provides:

- complete theme sets that combine a theme with matching color and fill
  scales
- markdown-aware `ggplot2` theme wrappers
- standalone color scale helpers that can be added directly to plots
- a few custom themes for publication and presentation work

## Installation

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("vanhungtran/themeset")
```

Or install from a local copy of the project root:

``` r
install.packages(".", repos = NULL, type = "source")
```

## Example

``` r
library(ggplot2)
library(themeset)

# Simulated growth curves of five strains and an uninoculated control
od <- subset(example_growth(), measure == "OD600")

p <- ggplot(od, aes(time, value, color = strain)) +
  geom_line() +
  geom_point(size = 2)

apply_theme_set(p, "simpsons")
```

<img src="man/figures/README-example-1.png" alt="Line plot of OD600 over incubation time for five strains and a control, in the simpsons theme." width="100%" />

You can also use a theme and a color scale independently:

``` r
ggplot(example_taxa(), aes(taxon, abundance, fill = condition)) +
  geom_boxplot() +
  theme_nyt() +
  scale_fill_jama()
```

<img src="man/figures/README-separate-1.png" alt="Box plots of the relative abundance of five taxa in three conditions, in the nyt theme with the jama palette." width="100%" />

`example_growth()` and `example_taxa()` are small simulated data sets
that come with the package.

## A figure for a paper

A figure for a paper is a grid of panels that share one look. The
[multi-panel
article](https://vanhungtran.github.io/themeset/articles/multi-panel-figure.html)
builds this one for print, 183 mm wide with 7 pt text, from the example
data, and restyles the whole figure by changing the name of the set.

<figure>
<img src="man/figures/multi-panel.png"
alt="Seven panels in the classic set: four time courses and three dot plots, with a shared legend." />
<figcaption aria-hidden="true">Seven panels in the classic set: four
time courses and three dot plots, with a shared legend.</figcaption>
</figure>

## Documentation

Tutorials and the function reference are on the package website,
<https://vanhungtran.github.io/themeset/>:

- [Introduction to
  themeset](https://vanhungtran.github.io/themeset/articles/themeset.html)
- [Theme Sets and Color
  Scales](https://vanhungtran.github.io/themeset/articles/theme-sets-and-scales.html)
- [Markdown-Enabled
  Themes](https://vanhungtran.github.io/themeset/articles/markdown-themes.html)
- [Global and Custom
  Themes](https://vanhungtran.github.io/themeset/articles/global-and-custom-themes.html)
- [A Multi-Panel
  Figure](https://vanhungtran.github.io/themeset/articles/multi-panel-figure.html)

The same articles, with their figures, are in the repository as
Markdown, for reading on GitHub: [articles/](articles/).
