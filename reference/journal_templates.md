# Journal Templates

The figure templates of the journals that `themeset` knows: the widths
of their columns, the limits for the size of the text, the style of the
panel tags and the palette to use.

## Usage

``` r
journal_templates()

journal_template(journal = "nature", ...)
```

## Arguments

- journal:

  The id of a journal (see `journal_templates()`), or a template made by
  `journal_template()`.

- ...:

  Fields to change, for example `text_pt = 6`, or all the fields of a
  new journal: `single_mm`, `onehalf_mm`, `double_mm`, `max_height_mm`,
  `text_pt`, `min_text_pt`, `max_text_pt`, `tag_pt`, `tag` (`"lower"` or
  `"upper"`), `palette` (the name of a color scale set) and `name`.

## Value

`journal_templates()`: a data frame with one row per journal.
`journal_template()`: a list of class `journal_template`.

## Details

`journal_templates()` lists them all as a data frame.
`journal_template()` returns one of them, as an object that the other
journal functions accept in place of the name of the journal. Changing a
field of it makes a template of your own, and a new name with the fields
of your journal makes one from scratch.

## Where the numbers come from

They come from the author guides of the journals, read in October 2026;
the `guide` field has the address of each guide. Journals change their
guides, so read the current one before you submit, and note that a
journal can have more than one guide, with numbers that differ a little:
Science, for example, has one for the first submission and one for the
final figures. Some journals do not give a number: the field is then
`NA`, and `themeset` falls back on generic values (85, 114 and 174 mm
wide, 7 pt text, panel tags of body size plus one point in capital
letters). The journals that redraw the figures of authors (NEJM, The
Lancet, JAMA, BMJ, JCO and Frontiers here) have `sizes = FALSE`: only
their palette is specific.

Nature states the size of its panel tags (8 pt, bold, lowercase) and so
does the figure guide of Science (10 pt, bold, capitals). For the other
journals the case of the tags is the one that the journal prints, and
the size is a convention.

The palettes of the journals are the palettes of ggsci that take their
inspiration from them, and `themeset` is not affiliated with any
journal. ggsci has no palette for Cell Press, PNAS, PLOS and Elsevier,
so they get the Okabe-Ito palette, which was designed to be told apart
by readers with color-vision deficiency and which the guide of Nature
lists.

## See also

[`journal_theme()`](https://vanhungtran.github.io/themeset/reference/journal_theme.md),
[`apply_journal()`](https://vanhungtran.github.io/themeset/reference/apply_journal.md),
[`compare_journals()`](https://vanhungtran.github.io/themeset/reference/compare_journals.md)

## Examples

``` r
journal_templates()[, c("journal", "single_mm", "double_mm", "text_pt", "palette")]
#>      journal single_mm double_mm text_pt   palette
#> 1     nature        89     183.0       7       npg
#> 2   natcomms        88     180.0       7       npg
#> 3    science        57     184.0       7      aaas
#> 4       cell        85     174.0       7 okabe_ito
#> 5       pnas        87     178.0       7 okabe_ito
#> 6       plos        NA     190.5       8 okabe_ito
#> 7   elsevier        90     190.0       7 okabe_ito
#> 8       nejm        NA        NA      NA      nejm
#> 9     lancet        NA        NA      NA    lancet
#> 10      jama        NA        NA      NA      jama
#> 11       bmj        NA        NA      NA       bmj
#> 12       jco        NA        NA      NA       jco
#> 13 frontiers        NA        NA      NA frontiers

journal_template("nature")
#> Journal template: Nature (nature)
#>   widths:  single 89 mm, one and a half -, double 183 mm
#>   height:  at most 170 mm
#>   text:    7 pt, at least 5 pt, at most 7 pt
#>   tags:    8 pt, bold, lowercase
#>   palette: npg
#>   guide:   https://research-figure-guide.nature.com/figures/building-and-exporting-figure-panels/

# Nature, with a smaller text size
journal_template("nature", text_pt = 6)
#> Journal template: Nature (nature)
#>   widths:  single 89 mm, one and a half -, double 183 mm
#>   height:  at most 170 mm
#>   text:    6 pt, at least 5 pt, at most 7 pt
#>   tags:    8 pt, bold, lowercase
#>   palette: npg
#>   guide:   https://research-figure-guide.nature.com/figures/building-and-exporting-figure-panels/

# A journal of your own
journal_template("my_journal", single_mm = 80, double_mm = 165, palette = "npg")
#> Journal template: my_journal (my_journal)
#>   widths:  single 80 mm, one and a half -, double 165 mm
#>   height:  no limit given
#>   text:    7 pt, at least 5 pt
#>   tags:    8 pt, bold, uppercase
#>   palette: npg
```
