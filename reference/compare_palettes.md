# Compare Color Palettes

For each palette, how far apart are its colors? The table gives the
smallest distance between two of the first `n` colors, as seen with
normal vision and as seen with the three kinds of color-vision
deficiency (deuteranopia, protanopia and tritanopia). Two colors that
are close are easy to confuse in a figure, and many journals ask for
figures that readers with a color-vision deficiency can read.

## Usage

``` r
compare_palettes(
  sets = unique(journal_registry()$palette),
  n = 6,
  threshold = 10
)
```

## Arguments

- sets:

  The names of color scale sets (see
  [`list_color_scales()`](https://vanhungtran.github.io/themeset/reference/list_color_scales.md)).
  By default the palettes of the journals in
  [`journal_templates()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- n:

  The number of colors to compare, taken from the start of the palette.
  A palette with fewer colors is compared as it is.

- threshold:

  The distance under which colors count as easy to confuse.

## Value

A data frame with one row per palette: `set`, `n`, the smallest distance
for `normal`, `deutan`, `protan` and `tritan` vision, `worst` (the
smallest of the four) and `confusable` (`worst` below `threshold`).

## Details

The distance is CIEDE2000. A distance below about 10 means that two
colors are easy to confuse; this is a rule of thumb, not a standard. The
simulations need the colorspace package; without it only normal vision
is compared.

## See also

[`journal_colors()`](https://vanhungtran.github.io/themeset/reference/journal_colors.md)
for the colors of a journal.

## Examples

``` r
compare_palettes(c("npg", "okabe_ito"), n = 5)
#>         set n   normal   deutan    protan   tritan     worst confusable
#> 1       npg 5 18.12418 14.45878  9.949975 10.22569  9.949975       TRUE
#> 2 okabe_ito 5 21.72367 11.51763 15.271861 12.06635 11.517632      FALSE
```
