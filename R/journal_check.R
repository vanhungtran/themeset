# --------------------------------------------------------------------------
# File: themeset/R/journal_check.R
# --------------------------------------------------------------------------
# Checking a figure against the limits of a journal.

# The theme that a plot is drawn with: its own, completed with the active one
effective_theme <- function(plot) {
  theme <- plot$theme
  if (is.null(theme) || !length(theme)) return(ggplot2::theme_get())
  if (isTRUE(attr(theme, "complete"))) theme else ggplot2::theme_get() + theme
}

# The size in points of the text that a plot draws, named by where it comes from
text_sizes <- function(plot) {
  theme <- effective_theme(plot)
  built <- tryCatch(ggplot2::ggplot_build(plot), error = function(e) NULL)
  labels <- if (is.null(built)) plot$labels else built$plot$labels
  has <- function(name) !is.null(labels[[name]])

  mapped <- c("colour", "fill", "size", "shape", "linetype", "alpha")
  layer_mappings <- unlist(lapply(plot$layers, function(layer) names(layer$mapping)))
  mapped <- intersect(mapped, c(names(plot$mapping), layer_mappings))
  mapped <- sub("^color$", "colour", mapped)

  elements <- c("axis.text.x", "axis.text.y")
  if (has("x")) elements <- c(elements, "axis.title.x")
  if (has("y")) elements <- c(elements, "axis.title.y")
  for (name in c("title", "subtitle", "caption")) {
    if (has(name)) elements <- c(elements, paste0("plot.", name))
  }
  if (length(mapped) && !identical(theme$legend.position, "none")) {
    elements <- c(elements, "legend.text")
    if (any(vapply(mapped, has, logical(1)))) elements <- c(elements, "legend.title")
  }
  if (!inherits(plot$facet, "FacetNull")) elements <- c(elements, "strip.text.x", "strip.text.y")

  sizes <- vapply(elements, function(element) {
    el <- tryCatch(ggplot2::calc_element(element, theme), error = function(e) NULL)
    if (is.null(el) || inherits(el, "element_blank") || is.null(el$size)) NA_real_ else as.numeric(el$size)
  }, numeric(1))

  # Text layers with a size that was chosen: geom_text(size = ) is in mm unless size.unit says pt
  for (layer in plot$layers) {
    if (inherits(layer$geom, c("GeomText", "GeomLabel")) && !is.null(layer$aes_params$size)) {
      pt <- if (identical(layer$geom_params$size.unit, "pt")) layer$aes_params$size else layer$aes_params$size * ggplot2::.pt
      sizes <- c(sizes, stats::setNames(pt, "text layer"))
    }
  }
  sizes[!is.na(sizes)]
}

# The width in points of the lines that a plot draws, named by where they come from
line_widths <- function(plot) {
  theme <- effective_theme(plot)
  built <- tryCatch(ggplot2::ggplot_build(plot), error = function(e) NULL)
  widths <- numeric()
  if (!is.null(built)) {
    for (i in seq_along(built$data)) {
      mm <- built$data[[i]]$linewidth
      mm <- mm[!is.na(mm) & mm > 0]   # 0 means no line
      if (length(mm)) {
        widths <- c(widths, stats::setNames(min(mm) * ggplot2::.pt, paste0("layer ", i, " (", class(plot$layers[[i]]$geom)[1], ")")))
      }
    }
  }
  for (element in c("axis.line.x", "axis.line.y", "axis.ticks.x", "axis.ticks.y", "panel.grid.major")) {
    el <- tryCatch(ggplot2::calc_element(element, theme), error = function(e) NULL)
    if (inherits(el, "ggplot2::element_line") || inherits(el, "element_line")) {
      if (!is.null(el$linewidth) && !is.na(el$linewidth) && el$linewidth > 0) {
        widths <- c(widths, stats::setNames(el$linewidth * ggplot2::.pt, element))
      }
    }
  }
  widths
}

# The distinct colors that the layers of a plot draw, without the greys
drawn_colors <- function(plot) {
  built <- tryCatch(ggplot2::ggplot_build(plot), error = function(e) NULL)
  if (is.null(built)) return(character())
  colors <- unlist(lapply(built$data, function(d) c(as.character(d$colour), as.character(d$fill))))
  colors <- unique(colors[!is.na(colors) & colors != "transparent"])
  if (!length(colors)) return(character())
  rgb <- farver::decode_colour(colors)
  chromatic <- (apply(rgb, 1L, max) - apply(rgb, 1L, min)) > 8
  unique(farver::encode_colour(rgb[chromatic, , drop = FALSE], from = "rgb"))
}

#' Check a Figure Against a Journal
#'
#' Checks a plot against the limits of a journal: the size of the smallest and
#' of the largest text, the thinnest line, the panel tags, the height, and
#' whether the colors can be told apart. The result is a table with one row per
#' check, which you can keep next to the figure, as a record of how it was made.
#'
#' The checks read the plot and its theme, not the picture. They cover the
#' text of the axes, the titles, the legends and the strips, text layers with a
#' size you gave, the lines of the layers, of the axes and of the grid, and the
#' colors that the layers draw. They do not look for text that overlaps or panels
#' that are not aligned: look at the figure for those.
#'
#' The colors are compared as in [compare_palettes()]: the smallest CIEDE2000
#' distance between two of them, with normal vision and with the simulated
#' deficiencies. A pair below 10 gives a warning. Greys, black and white are left
#' out, and a panel with more than twelve colors, which has a gradient, is not
#' compared. For a list of panels the colors are compared within each panel, since
#' each panel has its own legend, and the panel with the closest pair is reported.
#'
#' The height is checked only if you give it; a plot has no width or height of
#' its own, which come from the journal and from how you save it.
#'
#' @inheritParams compare_journals
#' @param plot A ggplot object, or a list of them, for a figure of several
#'   panels. The worst value over the panels is reported. A figure assembled with
#'   `cowplot::plot_grid()` has no text of its own: pass its panels as a list.
#' @param journal The journal, as in [journal_template()].
#' @param column The column that the figure is drawn at, for the width in the
#'   table.
#' @param height The height of the figure in mm, to check against the limit of the
#'   journal.
#' @return A data frame of class `journal_check` with the columns `check`,
#'   `status` (`"pass"`, `"warn"`, `"fail"` or `"info"`), `value`, `limit` and
#'   `note`. The attribute `overall` has the worst status.
#' @seealso [journal_theme()], [save_journal_figure()]
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' p <- ggplot(od, aes(time, value, color = strain)) +
#'   geom_line() +
#'   labs(x = "Incubation time (hr)", y = "OD600", color = NULL)
#'
#' journal_check(apply_journal(p, "nature"), "nature", height = 60)
#'
#' # the default theme has text that is too large for Nature
#' journal_check(p, "nature")
journal_check <- function(plot, journal = "nature", column = "single", height = NULL) {
  spec <- journal_template(journal)
  plots <- if (inherits(plot, "ggplot")) list(plot) else plot
  if (!is.list(plots) || !length(plots) || !all(vapply(plots, inherits, logical(1), "ggplot"))) {
    stop("`plot` must be a ggplot object or a list of them.", call. = FALSE)
  }
  # cowplot::plot_grid() and compare_journals() put the panels in as drawings: nothing to read
  assembled <- vapply(plots, function(p) {
    any(vapply(p$layers, function(layer) inherits(layer$geom, "GeomDrawGrob"), logical(1)))
  }, logical(1))
  if (any(assembled)) {
    warning("A figure assembled with cowplot::plot_grid() has no text of its own to check. ",
            "Pass its panels as a list: journal_check(list(a, b, c), \"", spec$journal, "\").", call. = FALSE)
  }
  width <- journal_width(spec, column)

  rows <- list()
  add <- function(check, status, value, limit = "", note = "") {
    rows[[length(rows) + 1L]] <<- data.frame(check = check, status = status, value = value,
                                             limit = limit, note = note, stringsAsFactors = FALSE)
  }
  pt <- function(x) sprintf("%.1f pt", x)

  # Size
  add("width", "info", paste0(format(width), " mm"), "",
      if (is.numeric(column)) "given" else paste(column, "column"))
  limit_height <- if (is.na(spec$max_height_mm)) "" else paste0("<= ", format(spec$max_height_mm), " mm")
  if (is.null(height)) {
    add("height", "info", "not given", limit_height)
  } else if (is.na(spec$max_height_mm)) {
    add("height", "info", paste0(format(height), " mm"), "the journal gives no limit")
  } else {
    add("height", if (height <= spec$max_height_mm) "pass" else "fail", paste0(format(height), " mm"), limit_height)
  }

  # Text
  sizes <- unlist(lapply(plots, text_sizes))
  if (length(sizes)) {
    smallest <- min(sizes)
    add("smallest text", if (smallest >= spec$min_text_pt - 1e-6) "pass" else "fail",
        pt(smallest), paste0(">= ", format(spec$min_text_pt), " pt"), names(sizes)[which.min(sizes)])
    if (!is.na(spec$max_text_pt)) {
      largest <- max(sizes)
      add("largest text", if (largest <= spec$max_text_pt + 1e-6) "pass" else "fail",
          pt(largest), paste0("<= ", format(spec$max_text_pt), " pt"), names(sizes)[which.max(sizes)])
    }
  }

  # Panel tags
  tags <- unlist(lapply(plots, function(p) {
    built <- tryCatch(ggplot2::ggplot_build(p), error = function(e) NULL)
    tag <- if (is.null(built)) p$labels$tag else built$plot$labels$tag
    if (is.null(tag) || inherits(tag, "waiver")) NULL else as.character(tag)
  }))
  if (length(tags)) {
    letters_only <- tags[grepl("^[A-Za-z]$", tags)]
    wrong_case <- if (spec$tag == "lower") grepl("[A-Z]", letters_only) else grepl("[a-z]", letters_only)
    add("panel tags", if (any(wrong_case)) "warn" else "pass",
        paste(tags, collapse = " "), paste0(spec$tag, "case"),
        if (any(wrong_case)) paste0(spec$name, " prints ", spec$tag, "case tags") else "")
  }

  # Lines
  lines <- unlist(lapply(plots, line_widths))
  if (length(lines)) {
    thinnest <- min(lines)
    add("thinnest line", if (thinnest >= min_line_pt - 1e-6) "pass" else "fail",
        sprintf("%.2f pt", thinnest), paste0(">= ", format(min_line_pt), " pt"), names(lines)[which.min(lines)])
  }

  # Colors: compared within a panel, since each panel has its own legend
  panel_colors <- lapply(plots, drawn_colors)
  counts <- lengths(panel_colors)
  comparable <- panel_colors[counts >= 2L & counts <= 12L]
  many <- any(counts > 12L)
  if (!length(comparable)) {
    add("colors", "info", paste(max(counts), if (many) "colors" else "color(s)"), "",
        if (many) "a gradient or many colors: not compared" else "nothing to compare")
  } else {
    visions <- c("normal", "deutan", "protan", "tritan")
    by_panel <- vapply(comparable, function(colors) {
      vapply(visions, function(v) min_color_distance(colors, v), numeric(1))
    }, numeric(length(visions)))
    distance <- apply(by_panel, 1L, function(x) if (all(is.na(x))) NA_real_ else min(x, na.rm = TRUE))
    worst <- min(distance, na.rm = TRUE)
    note <- sprintf("%s%d colors; closest pair with %s vision", if (length(comparable) > 1L) "up to " else "",
                    max(lengths(comparable)), visions[which.min(replace(distance, is.na(distance), Inf))])
    if (many) note <- paste0(note, "; a panel with a gradient or many colors is not compared")
    if (anyNA(distance)) note <- paste0(note, "; install colorspace to simulate color-vision deficiency")
    if (worst < 10) note <- paste0(note, "; palette = \"okabe_ito\" is made for this")
    add("colors", if (worst >= 10) "pass" else "warn", sprintf("%.1f", worst), ">= 10 (CIEDE2000)", note)
  }

  out <- do.call(rbind, rows)
  status <- out$status
  structure(out, class = c("journal_check", "data.frame"),
            journal = spec$journal, name = spec$name,
            overall = if ("fail" %in% status) "fail" else if ("warn" %in% status) "warn" else "pass")
}

#' @export
print.journal_check <- function(x, ...) {
  columns <- c("check", "status", "value", "limit", "note")
  if (!all(columns %in% names(x))) return(NextMethod())   # a table that was cut down
  name <- attr(x, "name", exact = TRUE)
  overall <- attr(x, "overall", exact = TRUE)
  cat("Check against ", if (is.null(name)) "a journal" else name,
      if (!is.null(overall)) paste0(": ", overall), "\n", sep = "")
  cells <- as.matrix(as.data.frame(x)[columns[1:4]])
  widths <- pmax(nchar(colnames(cells)), apply(nchar(cells), 2L, max))
  pad <- function(text) paste(sprintf("%-*s", widths, text), collapse = "  ")
  cat(pad(colnames(cells)), "  note\n", sep = "")
  for (i in seq_len(nrow(cells))) cat(pad(cells[i, ]), "  ", x$note[i], "\n", sep = "")
  invisible(x)
}
