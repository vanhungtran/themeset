# Markdown-Enabled ggplot2 Themes

A collection of standard `{ggplot2}` themes with markdown support
enabled. These can be added to a plot using the `+` operator.

## Usage

``` r
md_theme_gray(...)

md_theme_grey(...)

md_theme_bw(...)

md_theme_linedraw(...)

md_theme_light(...)

md_theme_dark(...)

md_theme_minimal(...)

md_theme_classic(...)
```

## Arguments

- ...:

  Additional arguments passed to the original theme function.

## Value

A markdown-enabled `{ggplot2}` theme object.

## Details

The titles, captions, axis titles, legend titles and facet strips render
markdown. The tick labels of the axes and the labels of the legends stay
plain: they come from your data, and a label such as `<LOD>` would be
read as markup. Markdown legend labels would also make a continuous
color bar as long as the canvas is high. To use markdown in the tick
labels or in the labels of a discrete legend, switch the element on for
that plot, for example
`theme(legend.text = ggtext::element_markdown())`.
