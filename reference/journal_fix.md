# Repair a Figure for a Journal

Changes what
[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)
finds wrong with a plot, and checks it again, until the checks pass or
there is nothing left that can be changed. The changes are kept small: a
text that is too small is raised to the smallest size that the journal
allows and no further, and the rest of the plot is left as it is. To
give a plot the whole style of a journal, use
[`apply_journal()`](https://vanhungtran.github.io/themeset/reference/apply_journal.md)
instead.

## Usage

``` r
journal_fix(
  plot,
  journal = "nature",
  column = "single",
  height = NULL,
  fix = c("text", "lines", "tags", "colors"),
  rounds = 3,
  quiet = TRUE
)
```

## Arguments

- plot:

  A ggplot object, or a list of them, for a figure of several panels.
  Each panel is repaired on its own.

- journal:

  The journal, as in
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- column:

  The column that the figure is drawn at, for the width in the table.

- height:

  The height of the figure in mm, to check against the limit of the
  journal.

- fix:

  What to repair: any of `"text"`, `"lines"`, `"tags"` and `"colors"`.

- rounds:

  The largest number of rounds of repair and check.

- quiet:

  If `FALSE`, a message lists the changes.

## Value

The plot, or the list of panels, with the changes. The attribute `fixes`
is a data frame with a row per change (`round`, `panel`, `check`,
`target`, `before` and `after`), and the attribute `check` is the result
of
[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)
on the repaired figure.

## Details

What is repaired:

- **text**: a text element of the theme, or a text layer with a size you
  gave, that is smaller than the smallest size of the journal, or larger
  than the largest, gets the size of the limit.

- **lines**: a line of the theme or of a layer that is thinner than 0.25
  pt gets 0.25 pt. A width that is mapped to data is left alone and
  reported.

- **tags**: a panel tag of one letter in the wrong case is changed to
  the case that the journal prints.

- **colors**: when two colors are hard to tell apart, the discrete color
  and fill scales are replaced by the Okabe-Ito palette, but only if
  that makes the closest pair easier to tell apart, and only for eight
  groups or fewer.

The height is not changed: give it to
[`save_journal_figure()`](https://vanhungtran.github.io/themeset/reference/save_journal_figure.md).

## See also

[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md),
[`journal_audit()`](https://vanhungtran.github.io/themeset/reference/journal_audit.md)
for the figures of a paper.

## Examples

``` r
library(ggplot2)
od <- subset(example_growth(), measure == "OD600")
p <- ggplot(od, aes(time, value, color = strain)) +
  geom_line(linewidth = 0.05) +
  labs(x = "Incubation time (hr)", y = "OD600", color = NULL, tag = "A") +
  theme_classic(base_size = 4)

journal_check(p, "nature")
#> Check against Nature: fail
#> check          status  value      limit              note
#> width          info    89 mm                         single column
#> height         info    not given  <= 170 mm          
#> smallest text  fail    3.2 pt     >= 5 pt            axis.text.x
#> largest text   pass    4.0 pt     <= 7 pt            axis.title.x
#> panel tags     warn    A          lowercase          Nature prints lowercase tags
#> thinnest line  fail    0.14 pt    >= 0.25 pt         layer 1 (GeomLine)
#> colors         warn    3.9        >= 10 (CIEDE2000)  6 colors; closest pair with protan vision; palette = "okabe_ito" is made for this

fixed <- journal_fix(p, "nature")
attr(fixed, "fixes")
#>   round panel  check             target  before            after
#> 1     1     1   text        axis.text.x  3.2 pt           5.0 pt
#> 2     1     1   text        axis.text.y  3.2 pt           5.0 pt
#> 3     1     1   text       axis.title.x  4.0 pt           5.0 pt
#> 4     1     1   text       axis.title.y  4.0 pt           5.0 pt
#> 5     1     1   text        legend.text  3.2 pt           5.0 pt
#> 6     1     1  lines layer 1 (GeomLine) 0.14 pt          0.25 pt
#> 7     1     1   tags           plot.tag       A                a
#> 8     1     1 colors             colour     3.9 11.5 (okabe_ito)
attr(fixed, "check")
#> Check against Nature: pass
#> check          status  value      limit              note
#> width          info    89 mm                         single column
#> height         info    not given  <= 170 mm          
#> smallest text  pass    5.0 pt     >= 5 pt            axis.text.x
#> largest text   pass    5.0 pt     <= 7 pt            axis.text.x
#> panel tags     pass    a          lowercase          
#> thinnest line  pass    0.25 pt    >= 0.25 pt         layer 1 (GeomLine)
#> colors         pass    11.5       >= 10 (CIEDE2000)  6 colors; closest pair with deutan vision
```
