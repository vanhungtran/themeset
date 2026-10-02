# --------------------------------------------------------------------------
# File: themeset/R/scale_definitions.R
# --------------------------------------------------------------------------
# All individual color and fill scale functions.

#' Discrete Color and Fill Scales
#'
#' Convenience wrappers around palette scales from supporting packages. These
#' functions can be added directly to a `ggplot2` object.
#'
#' @param ... Additional arguments passed to the underlying scale function.
#' @return A `ggplot2` scale object.
#' @seealso [scale_color_set()] and [scale_fill_set()] to pick any palette by name.
#' @name theme_color_scales
NULL

# ggsci
#' @rdname theme_color_scales
#' @export
scale_color_npg <- function(...) { ggsci::scale_color_npg(...) }
#' @rdname theme_color_scales
#' @export
scale_fill_npg <- function(...) { ggsci::scale_fill_npg(...) }
#' @rdname theme_color_scales
#' @export
scale_color_jama <- function(...) { ggsci::scale_color_jama(...) }
#' @rdname theme_color_scales
#' @export
scale_fill_jama <- function(...) { ggsci::scale_fill_jama(...) }
# tvthemes
#' @rdname theme_color_scales
#' @export
scale_color_avatar <- function(...) { tvthemes::scale_colour_avatar(...) }
#' @rdname theme_color_scales
#' @export
scale_fill_avatar <- function(...) { tvthemes::scale_fill_avatar(...) }
#' @rdname theme_color_scales
#' @export
scale_color_simpsons <- function(...) { tvthemes::scale_colour_simpsons(...) }
#' @rdname theme_color_scales
#' @export
scale_fill_simpsons <- function(...) { tvthemes::scale_fill_simpsons(...) }
# OlinkAnalyze
#' @rdname theme_color_scales
#' @export
scale_color_olink <- function(...) { OlinkAnalyze::olink_color_discrete(...) }
#' @rdname theme_color_scales
#' @export
scale_fill_olink <- function(...) { OlinkAnalyze::olink_fill_discrete(...) }
# ggthemes
#' @rdname theme_color_scales
#' @export
scale_color_fivethirtyeight <- function(...) { ggthemes::scale_color_fivethirtyeight(...) }
#' @rdname theme_color_scales
#' @export
scale_fill_fivethirtyeight <- function(...) { ggthemes::scale_fill_fivethirtyeight(...) }

