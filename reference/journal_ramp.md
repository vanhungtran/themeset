# Shades of One Color of a Journal

A sequential ramp for groups that have an order, such as doses or
stages: `n` shades of one color of the palette of the journal, from a
light tint to the color itself. The colors of a categorical palette tell
the reader that groups differ, not which end is high.

## Usage

``` r
journal_ramp(journal = "nature", n = 5, color = 1, light = 0.75)
```

## Arguments

- journal:

  The id of a journal (see
  [`journal_templates()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md)),
  or a template made by
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- n:

  How many shades.

- color:

  Which color of the palette to shade, by its position: 1 is the first
  color of
  [`journal_colors()`](https://vanhungtran.github.io/themeset/reference/journal_colors.md).

- light:

  The share of white in the lightest shade, from 0 up to but not
  including 1.

## Value

A character vector of `n` colors, as `"#RRGGBB"`, from the lightest to
the darkest. The darkest is the color of the palette.

## Details

The shades are evenly spaced in the CIE Lab color space, so that each
step looks about as large as the next. The lightest shade is a tint of
the color with the share of white that `light` gives; take a smaller
`light` if the lightest group must be visible as a thin line on white
paper.

## See also

[`journal_colors()`](https://vanhungtran.github.io/themeset/reference/journal_colors.md)
for groups without an order.

## Examples

``` r
journal_ramp("nature", 4)
#> [1] "#F9D2CC" "#F8A797" "#F27C65" "#E64B35"

library(ggplot2)
doses <- data.frame(dose = factor(1:4), response = c(2, 3.5, 5.5, 8))
ggplot(doses, aes(dose, response, fill = dose)) +
  geom_col() +
  scale_fill_manual(values = journal_ramp("nature", 4), guide = "none") +
  journal_theme("nature")
```
