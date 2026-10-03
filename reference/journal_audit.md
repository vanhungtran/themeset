# Audit the Figures of a Paper

Checks every figure of a paper against a journal with
[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md),
and then checks that the figures agree with each other.

## Usage

``` r
journal_audit(figures, journal = "nature", column = "single")
```

## Arguments

- figures:

  A list of figures: each a ggplot object or a list of panels. The names
  of the list name the figures in the table; without names they are
  numbered.

- journal:

  The journal, as in
  [`journal_template()`](https://vanhungtran.github.io/themeset/reference/journal_templates.md).

- column:

  The column that the figures are drawn at: one for all, or one per
  figure.

## Value

A data frame of class `journal_audit` with the columns `figure`,
`check`, `status`, `value`, `limit` and `note`. The attribute `overall`
has the worst status, and the attribute `colors` has the color of every
group in every figure (`figure`, `aesthetic`, `group` and `color`).

## Details

The figures are compared on:

- **group colors**: a group, such as a strain or a treatment, has the
  same color in every figure that shows it. A group that is blue in
  Figure 1 and red in Figure 3 gives a warning.

- **tick labels** and **axis titles**: the text of the axes has one size
  in all the figures.

- **font family**: the figures use one font family.

The result has one row per check: the rows of each figure where
[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)
did not pass, and the rows that compare the figures, whose `figure` is
`"all"`.
[`match_style()`](https://vanhungtran.github.io/themeset/reference/match_style.md)
gives a figure the style and the colors of another one, and
[`journal_fix()`](https://vanhungtran.github.io/themeset/reference/journal_fix.md)
repairs what the journal does not allow.

## See also

[`journal_check()`](https://vanhungtran.github.io/themeset/reference/journal_check.md)
for one figure.

## Examples

``` r
library(ggplot2)
od <- subset(example_growth(), measure == "OD600")
growth <- ggplot(od, aes(time, value, color = strain)) +
  geom_line() +
  labs(x = "Incubation time (hr)", y = "OD600", color = NULL)
last <- subset(od, time == max(time))
final <- ggplot(last, aes(strain, value, fill = strain)) +
  geom_col() +
  labs(x = NULL, y = "Final OD600", fill = NULL)

figures <- list(
  "Figure 1" = apply_journal(growth, "nature"),
  "Figure 2" = apply_journal(final, "nature", palette = "okabe_ito")
)
journal_audit(figures, "nature")
#> Audit of 2 figure(s) for Nature: warn
#> figure    check         status  value                 limit                    note
#> Figure 1  colors        warn    8.0                   >= 10 (CIEDE2000)        6 colors; closest pair with deutan vision; palette = "okabe_ito" is made for this
#> Figure 2  journal       pass    all checks pass       Nature                   
#> all       group colors  warn    6 of 6 groups differ  one color per group      No bacteria: #8491B4 (Figure 1), #D55E00 (Figure 2); Strain A: #E64B35 (Figure 1), #E69F00 (Figure 2); Strain B: #4DBBD5 (Figure 1), #56B4E9 (Figure 2); Strain C: #00A087 (Figure 1), #009E73 (Figure 2); Strain D: #3C5488 (Figure 1), #F0E442 (Figure 2); Strain E: #F39B7F (Figure 1), #0072B2 (Figure 2)
#> all       tick labels   pass    5.6 pt                the same in all figures  
#> all       axis titles   pass    7.0 pt                the same in all figures  
#> all       font family   pass    default               the same in all figures  

# the second figure in the colors of the first
figures[["Figure 2"]] <- match_style(figures[["Figure 2"]], figures[["Figure 1"]])
journal_audit(figures, "nature")
#> Audit of 2 figure(s) for Nature: warn
#> figure    check         status  value            limit                    note
#> Figure 1  colors        warn    8.0              >= 10 (CIEDE2000)        6 colors; closest pair with deutan vision; palette = "okabe_ito" is made for this
#> Figure 2  colors        warn    8.0              >= 10 (CIEDE2000)        6 colors; closest pair with deutan vision; palette = "okabe_ito" is made for this
#> all       group colors  pass    6 shared groups  one color per group      
#> all       tick labels   pass    5.6 pt           the same in all figures  
#> all       axis titles   pass    7.0 pt           the same in all figures  
#> all       font family   pass    default          the same in all figures  
```
