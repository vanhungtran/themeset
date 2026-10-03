# Panel Tags of a Journal

The letters that label the panels of a figure, in the case that the
journal prints: lowercase for Nature and Nature Communications, capitals
for the others.

## Usage

``` r
journal_tags(journal = "nature", n = 26)
```

## Arguments

- journal:

  The id of a journal (see
  [`journal_templates()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md)),
  or a template made by
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- n:

  How many tags, at most 26.

## Value

A character vector.

## Examples

``` r
journal_tags("nature", 4)
#> [1] "a" "b" "c" "d"
journal_tags("science", 4)
#> [1] "A" "B" "C" "D"
```
