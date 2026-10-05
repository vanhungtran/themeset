# themeset 1.8.5

* The two articles on figure sets have new colors, made with `hcl()` of base R from
  a hue, a chroma and a lightness: a deep teal, an orchid and a gold for groups, a
  steel blue and a brick red for the two directions of a heat map, a gold, an
  olive, a rose, a brown and a light steel for the categories that belong to no
  group, a blush, a dusty rose and a rosy taupe for routes, and one cool slate for
  ordered quantities. The colors of one set stay at least 16 apart (CIEDE2000) with
  normal vision and with each kind of color-vision deficiency, and both articles
  pass `journal_audit()`. The flow chart has pale shadows, the heat maps have white
  numbers on their deep tiles, and the plots in the first article have a
  background without an outline.

# themeset 1.8.4

* The figures of "A Figure Set for a Reporting Study" are checked as PDF files,
  which finds what `journal_audit()` cannot see: text on a line or on another text.
  They now have labels of 6 pt, no grid line behind a number, the categories written
  as upright numbers, and a plot background without an outline. Each figure has a
  full legend: a title sentence, a clause for each panel and the definitions. The
  third figure shows the reports of each drug in place of the number of signals.
* The heat maps of the two articles on figure sets use the named color
  `"firebrick"` for values above the reference.

# themeset 1.8.3

* A new article, "A Figure Set for a Reporting Study", draws five figures from
  simulated data for a study of reports of drugs and events: a flow chart of the
  cases, reports with routes, a bubble matrix and time to the event, a heat map
  of reporting odds ratios with a hierarchical tree, a contrast with a reference
  drug, and a forest plot of grouped estimates. The reporting odds ratios and
  their confidence intervals are computed from the simulated counts. The figures
  share one color contract and pass `journal_audit()` for Nature. The panels are
  laid out with patchwork, which is suggested.

# themeset 1.8.2

## Fixes

* The set `economist_white` no longer calls `ggthemes::theme_economist_white()`
  with ggthemes 7.0.0 or later, where it is deprecated and `theme_economist()`
  draws the same white panel. Before, building the set gave a deprecation
  warning with the new ggthemes.

# themeset 1.8.1

* A new article, "A Figure Set for a Reanalysis", draws seven figures from
  simulated data: heat maps and statements, an atlas of cells, a reference
  against its reanalysis gene by gene, a mechanism, quality control and proteins,
  a scorecard whose numbers are computed from the figures before it, and images.
  The figures share one color contract (a color for each group, for a verdict and
  for a direction), are in the theme of Nature at 183 mm, and are checked together
  with `journal_audit()`. The panels are laid out with patchwork, which is
  suggested.

# themeset 1.8.0

## Repairing figures

* `journal_fix()` repairs what `journal_check()` finds, and checks the figure
  again, until the checks pass or nothing more can be changed. Text that is
  too small or too large gets the size of the limit, lines thinner than 0.25 pt
  get 0.25 pt, panel tags get the case of the journal, and colors that are hard
  to tell apart are replaced by the Okabe-Ito palette if, and only if, that
  makes them easier to tell apart. The plot keeps its own style otherwise, and
  the attribute `fixes` lists every change.

## The figures of one paper

* `match_style()` draws a plot in the style of a reference plot: its theme, and
  its color for each group that the two plots share. New groups get a color of
  the palette of the reference that no group of the reference uses.
* `journal_audit()` checks a list of figures against a journal, and the figures
  against each other: a group that has a different color in two figures, axis
  text of different sizes, and different font families.
* The article "Comparing Figures Across Journals" has two new sections, on
  repairing a figure and on the figures of one paper.
* A new article, "A Showcase of Themes and Colors", draws one plot in twelve
  theme sets, ranks twelve palettes by how well readers with color-vision
  deficiency can tell their colors apart, draws one figure with each of the
  twelve palettes and as readers with color-vision deficiency see three of
  them, and sets the plot in four journals.

# themeset 1.7.2

* The gallery has a fifth figure: a composite of nine panels in the theme of
  Nature, 183 by 170 mm, that puts heat maps and an oncoprint from ComplexHeatmap
  next to ggplot2 panels with patchwork. It needs ComplexHeatmap (Bioconductor)
  and ggridges, which are suggested.
* `journal_check()` compares the colors of each panel with each other, and
  reports the panel with the closest pair. Before, the colors of all the panels
  of a list were compared together, which warned about two similar colors that
  were in different panels, each with its own legend.

# themeset 1.7.1

* A new article, "A Gallery of Figure Types", draws four kinds of figure from
  simulated data and styles them with `themeset`: a circular network (ggraph), a
  circos plot (circlize), a four-panel figure in the theme of a journal
  (patchwork) and a grouped dot plot. The packages that draw them are suggested,
  not required.
* `save_journal_figure()` writes a PDF with the standard `pdf()` device where
  R cannot load the cairo library, as on a macOS without XQuartz. Before, no file
  was written there.

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
