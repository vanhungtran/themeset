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
apply_theme_set <- function(plot, set) {
  theme_set_list <- get_theme_set_list()

  if (!set %in% names(theme_set_list)) {
    stop("Set '", set, "' not found. Run list_theme_sets() for available options.", call. = FALSE)
  }

  selected_set <- theme_set_list[[set]]

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
  theme_set_list <- get_theme_set_list()

  if (!set %in% names(theme_set_list)) {
    stop("Set '", set, "' not found. Run list_theme_sets() for available options.", call. = FALSE)
  }

  selected_set <- theme_set_list[[set]]

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
#'
#' @return A character vector of available theme set names.
#' @export
list_theme_sets <- function() {
  theme_set_list <- get_theme_set_list()
  theme_sets <- names(theme_set_list)
  cat("Available theme sets:\n")
  print(theme_sets)
  invisible(theme_sets)
}

#' List Available Color Scale Sets
#'
#' Prints the names of the exported discrete color and fill scale sets.
#'
#' @return A character vector of available scale set names.
#' @export
list_color_scales <- function() {
  color_scales <- names(get_color_scale_list())
  cat("Available color scale sets:\n")
  print(color_scales)
  invisible(color_scales)
}

# Internal function to build and return the list of theme sets.
get_theme_set_list <- function() {
  list(
    # Sets with themes and matching scales
    simpsons = list(
      theme = md_theme_simpsons(),
      scale_color = scale_color_simpsons(),
      scale_fill = scale_fill_simpsons()
    ),
    avatar = list(
      theme = md_theme_avatar(),
      scale_color = scale_color_avatar(),
      scale_fill = scale_fill_avatar()
    ),
    olink = list(
      theme = md_theme_olink(),
      scale_color = scale_color_olink(),
      scale_fill = scale_fill_olink()
    ),
    fivethirtyeight = list(
      theme = md_theme_fivethirtyeight(),
      scale_color = scale_color_fivethirtyeight(),
      scale_fill = scale_fill_fivethirtyeight()
    ),
    # Theme-only sets
    nyt = list(theme = theme_nyt()),
    midnight = list(theme = theme_midnight()),
    royal = list(theme = theme_royal()),
    deepblue = list(theme = theme_deepblue()),
    bw = list(theme = md_theme_bw()),
    classic = list(theme = md_theme_classic()),
    dark = list(theme = md_theme_dark()),
    light = list(theme = md_theme_light()),
    linedraw = list(theme = md_theme_linedraw()),
    minimal = list(theme = md_theme_minimal()),
    base = list(theme = md_theme_base()),
    calc = list(theme = md_theme_calc()),
    clean = list(theme = md_theme_clean()),
    economist = list(theme = md_theme_economist()),
    economist_white = list(theme = md_theme_economist_white()),
    excel = list(theme = md_theme_excel()),
    excel_new = list(theme = md_theme_excel_new()),
    few = list(theme = md_theme_few()),
    foundation = list(theme = md_theme_foundation()),
    gdocs = list(theme = md_theme_gdocs()),
    hc = list(theme = md_theme_hc()),
    igray = list(theme = md_theme_igray()),
    map_gg = list(theme = md_theme_map_gg()),
    pander = list(theme = md_theme_pander()),
    par = list(theme = md_theme_par()),
    solarized = list(theme = md_theme_solarized()),
    solarized_2 = list(theme = md_theme_solarized_2()),
    solid = list(theme = ggthemes::theme_solid()),
    stata = list(theme = md_theme_stata()),
    tufte = list(theme = md_theme_tufte()),
    wsj = list(theme = md_theme_wsj()),
    ipsum = list(theme = md_theme_ipsum()),
    ipsum_rc = list(theme = md_theme_ipsum_rc()),
    cowplot = list(theme = md_theme_cowplot()),
    minimal_grid = list(theme = md_theme_minimal_grid())
  )
}

get_color_scale_list <- function() {
  list(
    avatar = list(
      color = scale_color_avatar,
      fill = scale_fill_avatar
    ),
    fivethirtyeight = list(
      color = scale_color_fivethirtyeight,
      fill = scale_fill_fivethirtyeight
    ),
    jama = list(
      color = scale_color_jama,
      fill = scale_fill_jama
    ),
    npg = list(
      color = scale_color_npg,
      fill = scale_fill_npg
    ),
    olink = list(
      color = scale_color_olink,
      fill = scale_fill_olink
    ),
    simpsons = list(
      color = scale_color_simpsons,
      fill = scale_fill_simpsons
    )
  )
}
