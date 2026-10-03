# Install and Load R Packages from Multiple Sources

This function iterates through a vector of package names. If a package
is not installed, it attempts to install it from CRAN, then
Bioconductor. If still not found, it will search GitHub for a repository
with that name and prompt the user to interactively select from the top
results for installation.

## Usage

``` r
install_and_load(packages)
```

## Arguments

- packages:

  A character vector or list of package names. To install directly from
  GitHub without searching, use the 'username/reponame' format.

## Value

Loads the requested packages into the current session. Prints status
messages and continues processing even if one package fails.

## Examples

``` r
# packages <- c("ggplot2", "limma", "tidyverse/dplyr", "hrbrthemes")
# install_and_load(packages)
```
