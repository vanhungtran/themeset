# A Theme in the Style of a Journal

A theme that follows the template of a journal: the L-shaped axes and
white background of
[`theme_classic()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
the body text size of the journal, axis and legend text that is not
below the smallest size it allows, thin lines, a frameless legend and
panel tags in the style of the journal.

## Usage

``` r
journal_theme(journal = "nature", base_family = "", markdown = FALSE)
```

## Arguments

- journal:

  The id of a journal (see
  [`journal_templates()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md)),
  or a template made by
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- base_family:

  The font family. Many journals ask for Arial or Helvetica, and
  `"sans"` stands for one of the two on many systems.

- markdown:

  If `TRUE`, the titles, the x axis title, the legend title and the
  strips render markdown, as in the theme sets, so that a title can have
  italic species names or an exponent. The default is plain text, which
  is what a figure with labels from your data needs: a label such as
  `<LOD>` is read as markup. See
  [`md_theme_classic()`](https://vanhungtran.github.io/themeset/reference/ggplot2_md_themes.md)
  for what stays plain.

## Value

A `ggplot2` theme.

## Details

With ggplot2 4.0 or later the size of the text and the lines also sets
the default size of text, lines and points in the layers, so a
[`geom_line()`](https://ggplot2.tidyverse.org/reference/geom_path.html)
has the right width without an argument.

Draw the figure at the size that the journal prints it, with
[`save_journal_figure()`](https://vanhungtran.github.io/themeset/reference/save_journal_figure.md),
so that a text size of 7 pt is 7 pt on the page.

## See also

[`apply_journal()`](https://vanhungtran.github.io/themeset/reference/apply_journal.md)
to add the palette as well.

## Examples

``` r
library(ggplot2)
od <- subset(example_growth(), measure == "OD600")
ggplot(od, aes(time, value, color = strain)) +
  geom_line() +
  labs(x = "Incubation time (hr)", y = "OD600", color = NULL) +
  journal_theme("nature")
```
