# Apply the Template of a Journal to a Plot

Adds the theme of a journal,
[`journal_theme()`](https://vanhungtran.github.io/themeset/reference/journal_theme.md),
and its palette to a plot, as
[`apply_theme_set()`](https://vanhungtran.github.io/themeset/reference/apply_theme_set.md)
does for a theme set.

## Usage

``` r
apply_journal(plot, journal = "nature", palette = NULL, markdown = FALSE)
```

## Arguments

- plot:

  A ggplot object.

- journal:

  The id of a journal (see
  [`journal_templates()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md)),
  or a template made by
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- palette:

  The name of a color scale set to use instead of the palette of the
  journal (see
  [`list_color_scales()`](https://vanhungtran.github.io/themeset/reference/list_color_scales.md)),
  for example `"okabe_ito"`. `NA` keeps the colors of the plot and adds
  only the theme, which is what you want for a continuous color scale.

- markdown:

  Passed on to
  [`journal_theme()`](https://vanhungtran.github.io/themeset/reference/journal_theme.md):
  `TRUE` renders markdown in the titles, the x axis title, the legend
  title and the strips.

## Value

A ggplot object.

## See also

[`compare_journals()`](https://vanhungtran.github.io/themeset/reference/compare_journals.md)
to see one plot in several journals.

## Examples

``` r
library(ggplot2)
od <- subset(example_growth(), measure == "OD600")
p <- ggplot(od, aes(time, value, color = strain)) +
  geom_line() +
  labs(x = "Incubation time (hr)", y = "OD600", color = NULL)

apply_journal(p, "science")


# the same plot with the Okabe-Ito palette
apply_journal(p, "science", palette = "okabe_ito")
```
