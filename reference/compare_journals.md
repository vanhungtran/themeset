# Compare One Figure in Several Journals

Draws the same figure once for each journal, every copy at the width of
a column of that journal, side by side on one page. The page is to
scale, so you see what a journal's width does to the figure: how much
room the data have, and how large the text is next to them.

## Usage

``` r
compare_journals(
  plot,
  journals = c("nature", "science", "cell", "pnas"),
  column = "single",
  aspect = 0.75,
  height = NULL,
  ncol = NULL,
  sheet_mm = 260,
  title = NULL
)
```

## Arguments

- plot:

  A ggplot object, or a function that takes the template of a journal
  and returns a figure.

- journals:

  The journals to compare: ids (see
  [`journal_templates()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md))
  or templates made with
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- column:

  The width to draw: `"single"`, `"onehalf"` or `"double"`, the columns
  of the journal, or a width in mm that is the same for all. A journal
  without that column is drawn at its nearest one, and a journal that
  gives no widths at a generic width.

- aspect:

  The height of a copy as a fraction of its width.

- height:

  A height in mm for all the copies; replaces `aspect`.

- ncol:

  The number of copies in a row. By default as many as fit in
  `sheet_mm`.

- sheet_mm:

  The width in mm that a row of copies may fill.

- title:

  A title for the page.

## Value

A ggplot object, with the attribute `size_mm`.

## Details

Each copy gets the theme and the palette of its journal, as in
[`apply_journal()`](https://vanhungtran.github.io/themeset/reference/apply_journal.md).
The height of every copy is its width times `aspect`, so that the copies
have the same shape; give `height` to fix it instead.

`plot` can also be a function. It is called once for each journal with
the template of the journal, which has the size that the figure is drawn
at in `width_mm` and `height_mm`, and returns the figure: a ggplot, or
several assembled with
[`cowplot::plot_grid()`](https://wilkelab.org/cowplot/reference/plot_grid.html).
This is how you compare a figure of several panels, whose layout depends
on the width.

The page is a ggplot object with an attribute `size_mm`, its width and
height in mm. The text on it is in points, so it has the size it says
only when the page is saved at that size: use
[`save_journal_figure()`](https://vanhungtran.github.io/themeset/reference/save_journal_figure.md),
or [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
with `width` and `height` in mm. On a screen, the page is scaled to the
window.

## See also

[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)
to check a figure against the limits of a journal.

## Examples

``` r
library(ggplot2)
od <- subset(example_growth(), measure == "OD600")
p <- ggplot(od, aes(time, value, color = strain)) +
  geom_line() +
  labs(x = "Incubation time (hr)", y = "OD600", color = NULL)

sheet <- compare_journals(p, c("nature", "science", "cell"))
attr(sheet, "size_mm")
#>  width height 
#> 251.00  83.75 
```
