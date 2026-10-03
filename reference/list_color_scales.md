# List Available Color Scale Sets

Prints the names of the color scale sets, grouped by the package that
the palettes come from. Use a name with
[`scale_color_set()`](https://vanhungtran.github.io/themeset/reference/color_scale_sets.md)
or
[`scale_fill_set()`](https://vanhungtran.github.io/themeset/reference/color_scale_sets.md).

## Usage

``` r
list_color_scales(package = NULL)
```

## Arguments

- package:

  Only list the sets from this package, for example `"ggsci"`. The
  default lists them all.

## Value

Invisibly, a character vector with the names.

## Details

The palettes of the suggested packages wesanderson, biopalette and
ggpalettes appear, as `package::palette`, only when the package is
installed.

## See also

[color_scale_sets](https://vanhungtran.github.io/themeset/reference/color_scale_sets.md)

## Examples

``` r
list_color_scales("ggsci")
#> Available color scale sets:
#> ggsci: aaas, atlassian, bmj, cosmic, d3, flatui, frontiers, futurama, gephi,
#>     igv, iterm, jama, jco, lancet, locuszoom, nejm, npg, observable, primer,
#>     rickandmorty, startrek, tron, uchicago, ucscgb
```
