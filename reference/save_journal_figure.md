# Save a Figure at the Size of a Journal

Saves a plot, in the file format given by the extension of the file
name, at the width of a column of a journal. Text and lines then have
the size that the template of the journal says: 7 pt is 7 pt on the
page.

## Usage

``` r
save_journal_figure(
  plot,
  filename,
  journal = NULL,
  column = "single",
  height = NULL,
  dpi = 300,
  ...
)
```

## Arguments

- plot:

  A ggplot object, or the page made by
  [`compare_journals()`](https://vanhungtran.github.io/themeset/reference/compare_journals.md).

- filename:

  The file name, with the extension of the format.

- journal:

  The journal, as in
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).
  Not needed for a page made by
  [`compare_journals()`](https://vanhungtran.github.io/themeset/reference/compare_journals.md).

- column:

  The width to draw: `"single"`, `"onehalf"` or `"double"`, the columns
  of the journal, or a width in mm that is the same for all. A journal
  without that column is drawn at its nearest one, and a journal that
  gives no widths at a generic width.

- height:

  The height in mm. By default 0.75 times the width. A warning says if
  it is more than the journal allows.

- dpi:

  The resolution of bitmaps, in dots per inch.

- ...:

  Passed on to
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

## Value

The file name, invisibly.

## Details

A figure made by
[`compare_journals()`](https://vanhungtran.github.io/themeset/reference/compare_journals.md)
is saved at the size of its page, and `journal`, `column` and `height`
are ignored. Use a vector format (`.pdf`) where the journal asks for
one; a `.png` is for previews and for the journals that take bitmaps.

A `.pdf` is written with the cairo device, which embeds the fonts, when
R can use it, and with the standard
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device otherwise (on
macOS cairo needs XQuartz). A `.png` is written with the ragg package
when it is installed.

## See also

[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)

## Examples

``` r
if (FALSE) { # \dontrun{
p <- apply_journal(my_plot, "nature")
save_journal_figure(p, "figure1.pdf", journal = "nature", column = "double")
} # }
```
