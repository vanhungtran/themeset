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
