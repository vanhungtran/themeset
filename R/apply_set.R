# --------------------------------------------------------------------------
# File: themeset/R/apply_set.R
# --------------------------------------------------------------------------
# The main user-facing function for applying a complete theme set.

#' Apply a Complete Theme and Scale Set to a ggplot
#'
#' This is the primary function of the `themeset` package for local, per-plot
#' theme application. It applies a pre-defined, cohesive set of a theme,
#' color scale, and fill scale to a specific ggplot object.
#'
#' @param plot A ggplot object to modify.
#' @param set The name of the theme set to apply. Run `list_theme_sets()`
#'   to see available options.
#'
#' @return A modified ggplot object.
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' p <- ggplot(od, aes(x = time, y = value, color = strain)) +
#'   geom_line() +
#'   geom_point()
#'
#' apply_theme_set(p, "simpsons")
#'
#' # A journal set: the classic theme with the NEJM palette
#' apply_theme_set(p, "nejm")
apply_theme_set <- function(plot, set) {
  selected_set <- build_theme_set(set)

  plot <- plot + selected_set$theme

  if (!is.null(selected_set$scale_color)) {
    plot <- plot + selected_set$scale_color
  }

  if (!is.null(selected_set$scale_fill)) {
    plot <- plot + selected_set$scale_fill
  }

  plot
}

#' Set a Global Theme and Scales for an R Session
#'
#' Sets a theme, along with its corresponding default color and fill scales,
#' for all subsequent ggplot2 plots in the current R session.
#'
#' @param set The name of the theme set to apply globally. Run list_theme_sets() for options.
#' @return Invisibly returns the list of theme components that were set.
#' @export
#' @seealso [themeset::reset_global_theme()]
#' @examples
#' \dontrun{
#' # This will set the fivethirtyeight theme AND its color scales globally
#' set_global_theme("fivethirtyeight")
#'
#' # This plot will now automatically use the theme and scales
#' ggplot(subset(example_taxa(), taxon == "Bacteroides"),
#'        aes(x = condition, y = abundance, fill = condition)) +
#'   geom_boxplot()
#'
#' reset_global_theme()
#' }
set_global_theme <- function(set) {
  selected_set <- build_theme_set(set)

  # 1. Set the plot theme globally
  ggplot2::theme_set(selected_set$theme)

  # 2. Set the default color and fill scales globally via options
  if (!is.null(selected_set$scale_color)) {
    options(ggplot2.discrete.colour = selected_set$scale_color$palette(3))
  }

  if (!is.null(selected_set$scale_fill)) {
    options(ggplot2.discrete.fill = selected_set$scale_fill$palette(3))
  }

  message("Global theme and default scales set to '", set, "'.")
  invisible(selected_set)
}

#' Reset the Global ggplot2 Theme and Scales
#'
#' Resets the global theme to `theme_gray()` and unsets the global default
#' color and fill scales, restoring the ggplot2 defaults.
#'
#' @export
reset_global_theme <- function() {
  # 1. Reset the theme to the ggplot2 default
  ggplot2::theme_set(ggplot2::theme_gray())

  # 2. Reset the global options for scales by setting them to NULL
  options(
    ggplot2.discrete.colour = NULL,
    ggplot2.discrete.fill = NULL
  )

  message("Global ggplot2 theme and scales have been reset to their defaults.")
}


#' List Available Theme Sets
#'
#' Prints the names of the theme sets available to use with `apply_theme_set`.
#' The sets that bring their own color and fill scales come first; the others
#' change only the theme.
#'
#' @return A character vector of available theme set names.
#' @seealso [list_color_scales()] for the color scales
#' @export
list_theme_sets <- function() {
  theme_sets <- names(theme_set_builders())
  cat("Available theme sets:\n")
  print(theme_sets)
  invisible(theme_sets)
}
