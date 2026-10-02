# --------------------------------------------------------------------------
# File: themeset/R/example_data.R
# --------------------------------------------------------------------------
# Small simulated data sets for the examples, tests and vignettes.

#' Example Data
#'
#' Two small simulated data sets that the examples and vignettes use. They are
#' built by code, so no data files are involved, and every call returns the same
#' values.
#'
#' * `example_growth()` is a growth experiment: five bacterial strains and an
#'   uninoculated control, followed over six time points.
#' * `example_taxa()` is a microbiome comparison: the relative abundance of five
#'   taxa in eight samples from each of three conditions.
#'
#' @return A data frame.
#'
#'   `example_growth()` has 144 rows and these columns:
#'   \describe{
#'     \item{time}{Incubation time in hours.}
#'     \item{strain}{Factor with the six strains, `"Strain A"` to `"Strain E"`
#'       and `"No bacteria"`.}
#'     \item{measure}{Factor with the four measures: `"Product A (uM)"`,
#'       `"Product B (uM)"`, `"Substrate (mM)"` and `"OD600"`.}
#'     \item{value}{Mean of the measure.}
#'     \item{se}{Standard error of the mean.}
#'   }
#'
#'   `example_taxa()` has 120 rows and these columns:
#'   \describe{
#'     \item{taxon}{Factor with the five taxa.}
#'     \item{condition}{Factor with the three conditions, `"Control"`,
#'       `"Diet A"` and `"Diet B"`.}
#'     \item{abundance}{Relative abundance in percent.}
#'   }
#' @name example_data
#' @examples
#' growth <- example_growth()
#' head(growth)
#'
#' # Growth curve of the five strains and the uninoculated control
#' od <- subset(growth, measure == "OD600")
#' tapply(od$value, od$strain, max)
#'
#' taxa <- example_taxa()
#' tapply(taxa$abundance, list(taxa$taxon, taxa$condition), mean)
NULL

#' @rdname example_data
#' @export
example_growth <- function() {
  strains <- c("Strain A", "Strain B", "Strain C", "Strain D", "Strain E", "No bacteria")
  time <- c(0, 5, 19, 26, 44, 67)

  # One row per strain, one column per time point
  means <- list(
    "Product A (uM)" = rbind(
      c(0, 0, 10, 20, 150, 260),
      c(0, 0, 40, 100, 210, 390),
      c(0, 0, 30, 80, 280, 380),
      c(0, 0, 50, 150, 330, 550),
      c(0, 0, 15, 40, 110, 140),
      rep(0, 6)
    ),
    "Product B (uM)" = rbind(
      c(0, 0, 70, 80, 210, 280),
      c(0, 0, 160, 180, 250, 340),
      c(0, 0, 80, 180, 220, 290),
      c(0, 0, 100, 105, 320, 380),
      c(0, 0, 50, 90, 130, 160),
      rep(0, 6)
    ),
    "Substrate (mM)" = rbind(
      c(3.3, 3.0, 2.6, 2.0, 1.4, 0.2),
      c(3.2, 2.9, 2.3, 2.1, 1.7, 0.7),
      c(3.1, 2.9, 2.7, 1.9, 1.5, 0.9),
      c(3.3, 2.8, 2.6, 2.2, 1.6, 0.1),
      c(3.0, 2.8, 2.5, 2.2, 2.1, 2.0),
      c(3.1, 2.9, 2.7, 2.8, 2.9, 2.7)
    ),
    "OD600" = rbind(
      c(0.10, 0.12, 0.35, 0.25, 0.35, 0.38),
      c(0.10, 0.20, 0.58, 0.48, 0.42, 0.58),
      c(0.10, 0.15, 0.45, 0.52, 0.50, 0.35),
      c(0.10, 0.13, 0.48, 0.35, 0.38, 0.25),
      c(0.10, 0.40, 0.45, 0.32, 0.26, 0.23),
      c(0.10, 0.11, 0.12, 0.13, 0.14, 0.12)
    )
  )

  growth <- do.call(rbind, lapply(names(means), function(measure) {
    data.frame(
      time = rep(time, times = length(strains)),
      strain = rep(strains, each = length(time)),
      measure = measure,
      value = as.vector(t(means[[measure]])),
      stringsAsFactors = FALSE
    )
  }))

  # Standard errors: 15% of the value for the products (the control has a small
  # floor), and fixed values for the substrate and the optical density
  growth$se <- with(growth, ifelse(
    measure == "Substrate (mM)", 0.2,
    ifelse(measure == "OD600", 0.05,
           0.15 * value + ifelse(strain == "No bacteria", 0.05, 0))
  ))

  growth$strain <- factor(growth$strain, levels = strains)
  growth$measure <- factor(growth$measure, levels = names(means))
  growth
}

#' @rdname example_data
#' @export
example_taxa <- function() {
  taxa <- c("Bacteroides", "Proteobacteria", "Clostridium", "Fusobacteria", "Bifidobacterium")
  conditions <- c("Control", "Diet A", "Diet B")

  # Mean relative abundance (%) in the control, and the factor by which each diet
  # changes it
  baseline <- c(35, 8, 22, 4, 10)
  change <- rbind(
    "Control" = c(1.0, 1.0, 1.0, 1.0, 1.0),
    "Diet A"  = c(0.7, 2.4, 1.6, 1.2, 0.5),
    "Diet B"  = c(1.2, 0.6, 0.5, 2.0, 2.3)
  )

  samples <- expand.grid(
    sample = 1:8, condition = conditions, taxon = taxa,
    stringsAsFactors = FALSE
  )
  mu <- baseline[match(samples$taxon, taxa)] *
    change[cbind(match(samples$condition, conditions), match(samples$taxon, taxa))]

  # Normal noise from a small fixed generator (Park-Miller), so the values do not
  # depend on R's random number stream and the caller's seed is left alone
  state <- 20240601
  u <- numeric(nrow(samples))
  for (i in seq_along(u)) {
    state <- (48271 * state) %% 2147483647
    u[i] <- state / 2147483647
  }
  abundance <- round(pmax(mu * (1 + 0.25 * stats::qnorm(u)), 0), 1)

  data.frame(
    taxon = factor(samples$taxon, levels = taxa),
    condition = factor(samples$condition, levels = conditions),
    abundance = abundance
  )
}
