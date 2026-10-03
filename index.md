# themeset

`themeset` is an R package for reusable plot templates and color scales.
It provides:

- 49 theme sets, 14 of which bring matching color and fill scales, among
  them journal sets such as `nejm` and `lancet`
- markdown-aware `ggplot2` theme wrappers
- discrete color scales that can be added directly to plots or picked by
  name, from ggsci and from optional palette packages
- templates of 13 journals, with their figure widths, text sizes, panel
  tags and palettes, to draw one figure for several journals, compare
  them and check the result
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

![Line plot of OD600 over incubation time for five strains and a
control, in the simpsons theme.](reference/figures/README-example-1.png)

You can also use a theme and a color scale independently:

``` r

ggplot(example_taxa(), aes(taxon, abundance, fill = condition)) +
  geom_boxplot() +
  theme_nyt() +
  scale_fill_jama()
```

![Box plots of the relative abundance of five taxa in three conditions,
in the nyt theme with the jama
palette.](reference/figures/README-separate-1.png)

[`example_growth()`](https://vanhungtran.github.io/themeset/reference/example_data.md)
and
[`example_taxa()`](https://vanhungtran.github.io/themeset/reference/example_data.md)
are small simulated data sets that come with the package.

## Sets and palettes

``` r

apply_theme_set(p, "nejm")   # the classic theme with the NEJM palette
list_theme_sets()            # the names of the 49 sets
list_color_scales()          # the names of the palettes, by package

# any palette by name, with any theme
ggplot(example_taxa(), aes(taxon, abundance, fill = condition)) +
  geom_boxplot() +
  scale_fill_set("lancet")
```

## A figure for a paper

A figure for a paper is a grid of panels that share one look. The
[multi-panel
article](https://vanhungtran.github.io/themeset/articles/multi-panel-figure.html)
builds this one for print, 183 mm wide with 7 pt text, from the example
data, and restyles the whole figure by changing the name of the set.

![Seven panels in the npg set: four time courses and three dot plots,
with a shared legend.](reference/figures/multi-panel.png)

Seven panels in the npg set: four time courses and three dot plots, with
a shared legend.

## Journal figures

The same figure often has to fit more than one journal.
[`compare_journals()`](https://vanhungtran.github.io/themeset/reference/compare_journals.md)
draws a plot once for each journal, at the width of a column of that
journal and in its theme and palette, side by side and to scale:

``` r

p <- ggplot(od, aes(time, value, color = strain)) +
  geom_errorbar(aes(ymin = value - se, ymax = value + se), width = 2) +
  geom_line() +
  geom_point() +
  labs(x = "Incubation time (hr)", y = "OD600", color = NULL)

journals <- compare_journals(p, c("nature", "science", "cell"), sheet_mm = 250)
journals_size <- attr(journals, "size_mm")
```

``` r

journals
```

![The same line plot at the single-column width of Nature, Science and
Cell Press journals, each in the theme and palette of its
journal.](reference/figures/README-journals-1.png)

[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)
checks a figure against the limits of a journal (the text, the lines,
the panel tags, the height and whether the colors can be told apart),
[`save_journal_figure()`](https://vanhungtran.github.io/themeset/reference/save_journal_figure.md)
saves it at the size of a column, and
[`compare_palettes()`](https://vanhungtran.github.io/themeset/reference/compare_palettes.md)
tells which palettes keep their colors apart for readers with
color-vision deficiency. The numbers of the templates come from the
author guides of the journals, read in October 2026: read the current
guide before you submit. The [article on journal
figures](https://vanhungtran.github.io/themeset/articles/journal-figures.html)
has the details and the sources.

For the figures of one paper,
[`journal_fix()`](https://vanhungtran.github.io/themeset/reference/journal_fix.md)
repairs what
[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)
finds, with small changes, and checks again;
[`match_style()`](https://vanhungtran.github.io/themeset/reference/match_style.md)
gives a figure the theme of another and the same color for each group
the two share; and
[`journal_audit()`](https://vanhungtran.github.io/themeset/reference/journal_audit.md)
checks all the figures for a journal and against each other, for example
a strain that is blue in one figure and red in the next.

## More kinds of figures

The
[gallery](https://vanhungtran.github.io/themeset/articles/figure-gallery.html)
draws a circular network, a circos plot, a four-panel figure, a grouped
dot plot and a composite figure of nine panels with heat maps and an
oncoprint, from simulated data, with the palettes and the journal themes
of `themeset`. The packages that draw them (ggraph, circlize, patchwork,
ComplexHeatmap and ggridges) are suggested, not required.

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
- [Comparing Figures Across
  Journals](https://vanhungtran.github.io/themeset/articles/journal-figures.html)
- [A Gallery of Figure
  Types](https://vanhungtran.github.io/themeset/articles/figure-gallery.html)
- [A Showcase of Themes and
  Colors](https://vanhungtran.github.io/themeset/articles/showcase.html)

The same articles, with their figures, are in the repository as
Markdown, for reading on GitHub:
[articles/](https://vanhungtran.github.io/themeset/articles/).

## Credits

`themeset` does not contain the themes and palettes that it offers. It
calls the packages below by name, and the work is theirs: ggplot2,
ggthemes (Jeffrey B. Arnold), hrbrthemes (Bob Rudis), tvthemes (Ryo
Nakagawara), cowplot (Claus O. Wilke), OlinkAnalyze (Olink), ggsci (Nan
Xiao), flexoki (Christopher T. Kenny, for the Flexoki color scheme of
Steph Ango), ggtext (Claus O. Wilke and Brenton M. Wiernik) and, when
they are installed, wesanderson (Karthik Ram and Hadley Wickham),
biopalette (Yibin Zhou) and ggpalettes (Yaoxiang Li). The journal
figures also use farver (Thomas Lin Pedersen, Berendea Nicolae and
Romain François), the Okabe-Ito palette of Masataka Okabe and Kei Ito,
which base R provides, and, when it is installed, colorspace (Ross
Ihaka, Paul Murrell, Kurt Hornik, Jason C. Fisher, Reto Stauffer, Claus
O. Wilke, Claire D. McWhite and Achim Zeileis). The gallery draws with
igraph (Gábor Csárdi, Tamás Nepusz and others), ggraph and patchwork
(Thomas Lin Pedersen), circlize and ComplexHeatmap (Zuguang Gu) and
ggridges (Claus O. Wilke), which are suggested as well. The journal sets
use palettes that are named after journals; `themeset` is not affiliated
with any journal. The [sources and
credits](https://vanhungtran.github.io/themeset/articles/theme-sets-and-scales.html#sources-and-credits)
section of the article on theme sets and color scales has the details.
