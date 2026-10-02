# --------------------------------------------------------------------------
# File: themeset/R/theme_definitions.R
# --------------------------------------------------------------------------
# All individual theme functions (wrappers and custom).

# `%+replace%` is used unqualified below and in `as_md_theme()` (utils.R).
#' @importFrom ggplot2 %+replace%
NULL

# ggplot2 4.0 and later take the default color of points, lines, bars and text
# from the theme (`element_geom()`). A theme that does not set it leaves them
# black, which disappears on a dark background. A dark theme therefore names the
# color of its ink; its paper is the panel background. Older versions of ggplot2
# have no such element, and the theme is returned as it is.
light_geoms <- function(theme, ink) {
  if (!"element_geom" %in% getNamespaceExports("ggplot2")) return(theme)
  paper <- tryCatch(ggplot2::calc_element("panel.background", theme)$fill, error = function(e) NULL)
  if (is.null(paper) || length(paper) != 1L || is.na(paper)) return(theme)
  element_geom <- getExportedValue("ggplot2", "element_geom")
  theme + ggplot2::theme(geom = element_geom(ink = ink, paper = paper))
}

#' Markdown-Enabled ggplot2 Themes
#'
#' A collection of standard `{ggplot2}` themes with markdown support enabled.
#' These can be added to a plot using the `+` operator.
#'
#' The titles, captions, axis titles, legend titles and facet strips render
#' markdown. The tick labels of the axes and the labels of the legends stay plain:
#' they come from your data, and a label such as `<LOD>` would be read as markup.
#' Markdown legend labels would also make a continuous color bar as long as the
#' canvas is high. To use markdown in the tick labels or in the labels of a
#' discrete legend, switch the element on for that plot, for example
#' `theme(legend.text = ggtext::element_markdown())`.
#'
#' @param ... Additional arguments passed to the original theme function.
#' @return A markdown-enabled `{ggplot2}` theme object.
#' @name ggplot2_md_themes
NULL

#' @rdname ggplot2_md_themes
#' @export
md_theme_gray <- function(...) { as_md_theme(ggplot2::theme_gray(...)) }
#' @rdname ggplot2_md_themes
#' @export
md_theme_grey <- function(...) { as_md_theme(ggplot2::theme_grey(...)) }
#' @rdname ggplot2_md_themes
#' @export
md_theme_bw <- function(...) { as_md_theme(ggplot2::theme_bw(...)) }
#' @rdname ggplot2_md_themes
#' @export
md_theme_linedraw <- function(...) { as_md_theme(ggplot2::theme_linedraw(...)) }
#' @rdname ggplot2_md_themes
#' @export
md_theme_light <- function(...) { as_md_theme(ggplot2::theme_light(...)) }
#' @rdname ggplot2_md_themes
#' @export
md_theme_dark <- function(...) { as_md_theme(ggplot2::theme_dark(...)) }
#' @rdname ggplot2_md_themes
#' @export
md_theme_minimal <- function(...) { as_md_theme(ggplot2::theme_minimal(...)) }
#' @rdname ggplot2_md_themes
#' @export
md_theme_classic <- function(...) { as_md_theme(ggplot2::theme_classic(...)) }

# --- Internal Theme Definitions ---
# ggthemes
md_theme_base <- function(...) { as_md_theme(ggthemes::theme_base(...)) }
md_theme_calc <- function(...) { as_md_theme(ggthemes::theme_calc(...)) }
md_theme_clean <- function(...) { as_md_theme(ggthemes::theme_clean(...)) }
md_theme_economist <- function(...) { as_md_theme(ggthemes::theme_economist(...)) }
md_theme_economist_white <- function(...) { as_md_theme(ggthemes::theme_economist_white(...)) }
md_theme_excel <- function(...) { as_md_theme(ggthemes::theme_excel(...)) }
md_theme_excel_new <- function(...) { as_md_theme(ggthemes::theme_excel_new(...)) }
md_theme_few <- function(...) { as_md_theme(ggthemes::theme_few(...)) }
md_theme_fivethirtyeight <- function(...) { as_md_theme(ggthemes::theme_fivethirtyeight(...)) }
md_theme_foundation <- function(...) { as_md_theme(ggthemes::theme_foundation(...)) }
md_theme_gdocs <- function(...) { as_md_theme(ggthemes::theme_gdocs(...)) }
md_theme_hc <- function(...) { as_md_theme(ggthemes::theme_hc(...)) }
md_theme_igray <- function(...) { as_md_theme(ggthemes::theme_igray(...)) }
md_theme_map_gg <- function(...) { as_md_theme(ggthemes::theme_map(...)) }
md_theme_pander <- function(...) { as_md_theme(ggthemes::theme_pander(...)) }
md_theme_par <- function(...) { as_md_theme(ggthemes::theme_par(...)) }
md_theme_solarized <- function(...) { as_md_theme(ggthemes::theme_solarized(...)) }
md_theme_solarized_2 <- function(...) { as_md_theme(ggthemes::theme_solarized_2(...)) }
#md_theme_solid <- function(...) { as_md_theme(ggthemes::theme_solid(...)) }
md_theme_stata <- function(...) { as_md_theme(ggthemes::theme_stata(...)) }
md_theme_tufte <- function(...) { as_md_theme(ggthemes::theme_tufte(...)) }
md_theme_wsj <- function(...) { as_md_theme(ggthemes::theme_wsj(...)) }
# hrbrthemes
md_theme_ipsum <- function(...) { as_md_theme(hrbrthemes::theme_ipsum(...)) }
md_theme_ipsum_rc <- function(...) { as_md_theme(hrbrthemes::theme_ipsum_rc(...)) }
# tvthemes
md_theme_avatar <- function(...) { as_md_theme(tvthemes::theme_avatar(...)) }
md_theme_simpsons <- function(...) { as_md_theme(tvthemes::theme_simpsons(...)) }
# cowplot
md_theme_cowplot <- function(...) { as_md_theme(cowplot::theme_cowplot(...)) }
md_theme_minimal_grid <- function(...) { as_md_theme(cowplot::theme_minimal_grid(...)) }
# OlinkAnalyze
md_theme_olink <- function(...) { as_md_theme(OlinkAnalyze::set_plot_theme(...)) }
# flexoki (the dark theme also needs light default geoms)
md_theme_flexoki_light <- function(...) { as_md_theme(flexoki::theme_flexoki_light(...)) }
md_theme_flexoki_dark <- function(...) {
  light_geoms(as_md_theme(flexoki::theme_flexoki_dark(...)), ink = "grey88")
}

#' Custom Plot Themes
#'
#' Custom themes included with the package that can be added directly to a
#' `ggplot2` plot.
#'
#' `theme_midnight()`, `theme_royal()` and `theme_deepblue()` are dark themes.
#' With ggplot2 4.0 or later they also set the default color of points, lines,
#' bars and text to a light one, so a layer without a color mapping, such as
#' `geom_point()`, is visible on the dark panel.
#'
#' @param gridline_x,gridline_y For `theme_nyt()`: if `TRUE` (the default), draw
#'   the major gridlines of the x or y axis as thin dashed grey lines;
#'   otherwise omit them.
#' @param base_size,base_family For `theme_midnight()`, `theme_royal()` and
#'   `theme_deepblue()`: base font size (in points) and font family, passed on
#'   to [ggplot2::theme_gray()].
#' @return A `ggplot2` theme object.
#' @name custom_themes
NULL

# Custom
#' @rdname custom_themes
#' @export
theme_nyt <- function(gridline_x = TRUE, gridline_y = TRUE) {
  gridline <- ggplot2::element_line(linetype = "dashed", linewidth = 0.15, color = "#999999")
  gridline_x <- if (isTRUE(gridline_x)) gridline else ggplot2::element_blank()
  gridline_y <- if (isTRUE(gridline_y)) gridline else ggplot2::element_blank()
  # Use "sans" as a safe default font. "Libre Franklin" is preferred but
  # requires the user to install it on their system.
  ggplot2::theme_minimal(base_family = "sans") +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 18, face = "bold", color = "#333333", margin = ggplot2::margin(b = 10)),
      plot.subtitle = ggplot2::element_text(size = 14, color = "#999999", margin = ggplot2::margin(b = 10)),
      plot.caption = ggplot2::element_text(size = 13, color = "#777777", margin = ggplot2::margin(t = 15), hjust = 0),
      axis.text = ggplot2::element_text(size = 11, color = "#333333"),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = gridline_x,
      panel.grid.major.y = gridline_y
    )
}
#' @rdname custom_themes
#' @export
theme_midnight <- function(base_size = 11, base_family = "") {
  midnight <- ggplot2::theme_gray(base_size = base_size, base_family = base_family) %+replace%
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#1A202C", color = NA),
      panel.background = ggplot2::element_rect(fill = "#2D3748", color = NA),
      legend.background = ggplot2::element_rect(fill = "#1A202C", color = NA),
      plot.title = ggplot2::element_text(color = "#F7FAFC", size = 18, face = "bold"),
      plot.subtitle = ggplot2::element_text(color = "#A0AEC0", size = 12),
      axis.text = ggplot2::element_text(color = "#E2E8F0"),
      axis.title = ggplot2::element_text(color = "#E2E8F0", face = "bold"),
      legend.text = ggplot2::element_text(color = "#E2E8F0"),
      legend.title = ggplot2::element_text(color = "#F7FAFC", face = "bold"),
      panel.grid.major = ggplot2::element_line(color = "#4A5568", linewidth = 0.2),
      panel.grid.minor = ggplot2::element_blank()
    )
  light_geoms(midnight, ink = "#E2E8F0")
}
#' @rdname custom_themes
#' @export
theme_royal <- function(base_size = 11, base_family = "") {
  royal <- ggplot2::theme_gray(base_size = base_size, base_family = base_family) %+replace%
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#2d004d", color = NA),
      panel.background = ggplot2::element_rect(fill = "#4a148c", color = NA),
      legend.background = ggplot2::element_rect(fill = "#2d004d", color = NA),
      plot.title = ggplot2::element_text(color = "#ffd700", size = 18, face = "bold"),
      plot.subtitle = ggplot2::element_text(color = "#f0e68c", size = 12),
      axis.text = ggplot2::element_text(color = "#ffffff"),
      axis.title = ggplot2::element_text(color = "#ffffff", face = "bold"),
      legend.text = ggplot2::element_text(color = "#ffffff"),
      legend.title = ggplot2::element_text(color = "#ffd700", face = "bold"),
      panel.grid.major = ggplot2::element_line(color = "#7b1fa2", linewidth = 0.2),
      panel.grid.minor = ggplot2::element_blank()
    )
  light_geoms(royal, ink = "#ffffff")
}
#' @rdname custom_themes
#' @export
theme_deepblue <- function(base_size = 11, base_family = "") {
  deepblue <- ggplot2::theme_gray(base_size = base_size, base_family = base_family) %+replace%
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#001f3f", color = NA),
      panel.background = ggplot2::element_rect(fill = "#003366", color = NA),
      legend.background = ggplot2::element_rect(fill = "#001f3f", color = NA),
      plot.title = ggplot2::element_text(color = "#FFFFFF", size = 18, face = "bold"),
      plot.subtitle = ggplot2::element_text(color = "#DDDDDD", size = 12),
      axis.text = ggplot2::element_text(color = "#FFFFFF"),
      axis.title = ggplot2::element_text(color = "#FFFFFF", face = "bold"),
      legend.text = ggplot2::element_text(color = "#FFFFFF"),
      legend.title = ggplot2::element_text(color = "#FFFFFF", face = "bold"),
      panel.grid.major = ggplot2::element_line(color = "#00509E", linewidth = 0.2),
      panel.grid.minor = ggplot2::element_blank()
    )
  light_geoms(deepblue, ink = "#FFFFFF")
}
