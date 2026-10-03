# Check a Figure Against a Journal

Checks a plot against the limits of a journal: the size of the smallest
and of the largest text, the thinnest line, the panel tags, the height,
and whether the colors can be told apart. The result is a table with one
row per check, which you can keep next to the figure, as a record of how
it was made.

## Usage

``` r
journal_check(plot, journal = "nature", column = "single", height = NULL)
```

## Arguments

- plot:

  A ggplot object, or a list of them, for a figure of several panels.
  The worst value over the panels is reported. A figure assembled with
  [`cowplot::plot_grid()`](https://wilkelab.org/cowplot/reference/plot_grid.html)
  has no text of its own: pass its panels as a list.

- journal:

  The journal, as in
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- column:

  The column that the figure is drawn at, for the width in the table.

- height:

  The height of the figure in mm, to check against the limit of the
  journal.

## Value

A data frame of class `journal_check` with the columns `check`, `status`
(`"pass"`, `"warn"`, `"fail"` or `"info"`), `value`, `limit` and `note`.
The attribute `overall` has the worst status.

## Details

The checks read the plot and its theme, not the picture. They cover the
text of the axes, the titles, the legends and the strips, text layers
with a size you gave, the lines of the layers, of the axes and of the
grid, and the colors that the layers draw. They do not look for text
that overlaps or panels that are not aligned: look at the figure for
those.

The colors are compared as in
[`compare_palettes()`](https://vanhungtran.github.io/themeset/reference/compare_palettes.md):
the smallest CIEDE2000 distance between two of them, with normal vision
and with the simulated deficiencies. A pair below 10 gives a warning.
Greys, black and white are left out, and a panel with more than twelve
colors, which has a gradient, is not compared. For a list of panels the
colors are compared within each panel, since each panel has its own
legend, and the panel with the closest pair is reported.

The height is checked only if you give it; a plot has no width or height
of its own, which come from the journal and from how you save it.

## See also

[`journal_theme()`](https://vanhungtran.github.io/themeset/reference/journal_theme.md),
[`save_journal_figure()`](https://vanhungtran.github.io/themeset/reference/save_journal_figure.md)

## Examples

``` r
library(ggplot2)
od <- subset(example_growth(), measure == "OD600")
p <- ggplot(od, aes(time, value, color = strain)) +
  geom_line() +
  labs(x = "Incubation time (hr)", y = "OD600", color = NULL)

journal_check(apply_journal(p, "nature"), "nature", height = 60)
#> Check against Nature: warn
#> check          status  value    limit              note
#> width          info    89 mm                       single column
#> height         pass    60 mm    <= 170 mm          
#> smallest text  pass    5.6 pt   >= 5 pt            axis.text.x
#> largest text   pass    7.0 pt   <= 7 pt            axis.title.x
#> thinnest line  pass    0.75 pt  >= 0.25 pt         layer 1 (GeomLine)
#> colors         warn    8.0      >= 10 (CIEDE2000)  6 colors; closest pair with deutan vision; palette = "okabe_ito" is made for this

# the default theme has text that is too large for Nature
journal_check(p, "nature")
#> Check against Nature: fail
#> check          status  value      limit              note
#> width          info    89 mm                         single column
#> height         info    not given  <= 170 mm          
#> smallest text  pass    8.8 pt     >= 5 pt            axis.text.x
#> largest text   fail    11.0 pt    <= 7 pt            axis.title.x
#> thinnest line  pass    1.42 pt    >= 0.25 pt         layer 1 (GeomLine)
#> colors         warn    3.9        >= 10 (CIEDE2000)  6 colors; closest pair with protan vision; palette = "okabe_ito" is made for this
```
