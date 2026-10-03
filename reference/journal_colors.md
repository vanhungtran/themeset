# The Colors of a Journal

The palette that goes with a journal: the colors that
[`apply_journal()`](https://vanhungtran.github.io/themeset/reference/apply_journal.md)
uses.

## Usage

``` r
journal_colors(journal = "nature", n = NULL)
```

## Arguments

- journal:

  The id of a journal (see
  [`journal_templates()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md)),
  or a template made by
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- n:

  How many colors. By default all the colors of the palette; a warning
  says if the palette has fewer than you ask for.

## Value

A character vector of colors, as `"#RRGGBB"`.

## See also

[`compare_palettes()`](https://vanhungtran.github.io/themeset/reference/compare_palettes.md)
to compare palettes, also for readers with color-vision deficiency.

## Examples

``` r
journal_colors("nature", 4)
#> [1] "#E64B35" "#4DBBD5" "#00A087" "#3C5488"
journal_colors("science", 4)
#> [1] "#3B4992" "#EE0000" "#008B45" "#631879"
```
