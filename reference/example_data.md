# Example Data

Two small simulated data sets that the examples and vignettes use. They
are built by code, so no data files are involved, and every call returns
the same values.

## Usage

``` r
example_growth()

example_taxa()
```

## Value

A data frame.

`example_growth()` has 144 rows and these columns:

- time:

  Incubation time in hours.

- strain:

  Factor with the six strains, `"Strain A"` to `"Strain E"` and
  `"No bacteria"`.

- measure:

  Factor with the four measures: `"Product A (uM)"`, `"Product B (uM)"`,
  `"Substrate (mM)"` and `"OD600"`.

- value:

  Mean of the measure.

- se:

  Standard error of the mean.

`example_taxa()` has 120 rows and these columns:

- taxon:

  Factor with the five taxa.

- condition:

  Factor with the three conditions, `"Control"`, `"Diet A"` and
  `"Diet B"`.

- abundance:

  Relative abundance in percent.

## Details

- `example_growth()` is a growth experiment: five bacterial strains and
  an uninoculated control, followed over six time points.

- `example_taxa()` is a microbiome comparison: the relative abundance of
  five taxa in eight samples from each of three conditions.

## Examples

``` r
growth <- example_growth()
head(growth)
#>   time   strain        measure value   se
#> 1    0 Strain A Product A (uM)     0  0.0
#> 2    5 Strain A Product A (uM)     0  0.0
#> 3   19 Strain A Product A (uM)    10  1.5
#> 4   26 Strain A Product A (uM)    20  3.0
#> 5   44 Strain A Product A (uM)   150 22.5
#> 6   67 Strain A Product A (uM)   260 39.0

# Growth curve of the five strains and the uninoculated control
od <- subset(growth, measure == "OD600")
tapply(od$value, od$strain, max)
#>    Strain A    Strain B    Strain C    Strain D    Strain E No bacteria 
#>        0.38        0.58        0.52        0.48        0.45        0.14 

taxa <- example_taxa()
tapply(taxa$abundance, list(taxa$taxon, taxa$condition), mean)
#>                 Control  Diet A  Diet B
#> Bacteroides     38.2500 30.5375 45.9875
#> Proteobacteria   7.3000 19.3875  4.2625
#> Clostridium     21.6125 29.8625  9.8250
#> Fusobacteria     4.5875  4.5625  7.4750
#> Bifidobacterium 11.0250  4.7625 22.1625
```
