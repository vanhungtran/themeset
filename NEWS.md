# themeset 1.7.0

## Journal figures

* `journal_templates()` and `journal_template()` hold the figure templates of 13
  journals: the widths of their columns, the smallest and the largest text, the
  size and case of the panel tags, and the palette. Seven journals (Nature,
  Nature Communications, Science, Cell Press, PNAS, PLOS and Elsevier) give
  sizes; for NEJM, The Lancet, JAMA, BMJ, JCO and Frontiers only the palette is
  specific. The numbers come from the author guides, read in October 2026, and a
  template can be changed or made from scratch.
* `journal_theme()` and `apply_journal()` give a plot the theme and the palette
  of a journal. `journal_colors()` returns the palette, `journal_ramp()` shades of
  one of its colors for groups that have an order, and `journal_tags()` the panel
  tags in the case that the journal prints.
* `compare_journals()` draws one plot, or a function that builds a figure, once
  for each journal, side by side and to scale, on one page.
* `compare_palettes()` compares palettes by the smallest distance between two of
  their colors, also as simulated for color-vision deficiency.
* `journal_check()` checks a figure against a journal: the smallest and largest
  text, the thinnest line, the panel tags, the height and the colors, in a table.
* `save_journal_figure()` saves a figure, or a page of `compare_journals()`, at
  the size of a column.
* The new color scale set `okabe_ito` is the Okabe-Ito palette of base R.
* A new article, "Comparing Figures Across Journals".

## Changes

* The labels of a legend are now plain text in the markdown themes
  (`md_theme_*()`) and in the theme sets built on them, as the tick labels
  already were. With markdown labels a continuous color bar grew with the size of
  the canvas, and overflowed a panel that was drawn into a larger figure. The
  legend title is still markdown. To use markdown in the labels of a discrete
  legend, add `theme(legend.text = ggtext::element_markdown())`.

# themeset 1.6.0

## New sets

* Eight journal sets, `npg`, `aaas`, `nejm`, `lancet`, `jama`, `jco`, `bmj` and
  `frontiers`: the classic theme with the palette of the same name from ggsci.
* `flexoki_light` and `flexoki_dark`, built on the flexoki package.
* There are now 49 sets, 14 of which bring their own color and fill scales.

## New scales

* `scale_color_set()` and `scale_fill_set()` pick a discrete color or fill scale
  by name. All the discrete palettes of ggsci are available, and so are the
  palettes of wesanderson, biopalette and ggpalettes, as `package::palette`,
  when those suggested packages are installed.
* `list_color_scales()` groups the names by package and has a `package`
  argument.

## Fixes

* The dark themes `theme_midnight()`, `theme_royal()` and `theme_deepblue()`, and
  the `flexoki_dark` set, draw the default color of points, lines, bars and text
  in a light color. Before, a layer without a color mapping was black on the dark
  panel (ggplot2 4.0 or later).

## Internal changes

* `apply_theme_set()` and `set_global_theme()` build only the set that is asked
  for. Building all of them took more than a second on every call.

# themeset 1.5.0

First public release: theme sets, markdown-enabled themes, color scales,
example data, and the package website.
