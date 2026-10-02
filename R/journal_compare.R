# --------------------------------------------------------------------------
# File: themeset/R/journal_compare.R
# --------------------------------------------------------------------------
# Comparing the templates of journals: one figure in several journals, their
# palettes, and saving a figure at the size of a journal.

#' Compare One Figure in Several Journals
#'
#' Draws the same figure once for each journal, every copy at the width of a
#' column of that journal, side by side on one page. The page is to scale, so you
#' see what a journal's width does to the figure: how much room the data have, and
#' how large the text is next to them.
#'
#' Each copy gets the theme and the palette of its journal, as in
#' [apply_journal()]. The height of every copy is its width times `aspect`, so
#' that the copies have the same shape; give `height` to fix it instead.
#'
#' `plot` can also be a function. It is called once for each journal with the
#' template of the journal, which has the size that the figure is drawn at in
#' `width_mm` and `height_mm`, and returns the figure: a ggplot, or several
#' assembled with `cowplot::plot_grid()`. This is how you compare a figure of
#' several panels, whose layout depends on the width.
#'
#' The page is a ggplot object with an attribute `size_mm`, its width and height
#' in mm. The text on it is in points, so it has the size it says only when the
#' page is saved at that size: use [save_journal_figure()], or `ggsave()` with
#' `width` and `height` in mm. On a screen, the page is scaled to the window.
#'
#' @param plot A ggplot object, or a function that takes the template of a
#'   journal and returns a figure.
#' @param journals The journals to compare: ids (see [journal_templates()]) or
#'   templates made with [journal_template()].
#' @param column The width to draw: `"single"`, `"onehalf"` or `"double"`, the
#'   columns of the journal, or a width in mm that is the same for all. A journal
#'   without that column is drawn at its nearest one, and a journal that gives no
#'   widths at a generic width.
#' @param aspect The height of a copy as a fraction of its width.
#' @param height A height in mm for all the copies; replaces `aspect`.
#' @param ncol The number of copies in a row. By default as many as fit in
#'   `sheet_mm`.
#' @param sheet_mm The width in mm that a row of copies may fill.
#' @param title A title for the page.
#' @return A ggplot object, with the attribute `size_mm`.
#' @seealso [journal_check()] to check a figure against the limits of a journal.
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' p <- ggplot(od, aes(time, value, color = strain)) +
#'   geom_line() +
#'   labs(x = "Incubation time (hr)", y = "OD600", color = NULL)
#'
#' sheet <- compare_journals(p, c("nature", "science", "cell"))
#' attr(sheet, "size_mm")
compare_journals <- function(plot, journals = c("nature", "science", "cell", "pnas"),
                             column = "single", aspect = 0.75, height = NULL,
                             ncol = NULL, sheet_mm = 260, title = NULL) {
  if (!is.function(plot) && !inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object or a function that returns a figure.", call. = FALSE)
  }
  if (inherits(journals, "journal_template")) journals <- list(journals)
  specs <- lapply(journals, journal_template)
  width <- vapply(specs, journal_width, numeric(1), column = column)
  tall <- if (is.null(height)) width * aspect else rep(as.numeric(height), length(specs))

  # One figure per journal, at its size
  figures <- Map(function(spec, w, h) {
    spec$width_mm <- w
    spec$height_mm <- h
    if (is.function(plot)) plot(spec) else apply_journal(plot, spec)
  }, specs, width, tall)

  # The page, in mm
  gutter <- 6
  margin <- 4
  caption <- 9
  heading <- if (is.null(title)) 0 else 8

  # Fill the rows from left to right
  rows <- list()
  row <- integer()
  used <- 0
  for (i in seq_along(specs)) {
    need <- width[i] + if (length(row)) gutter else 0
    full <- if (is.null(ncol)) used + need > sheet_mm - 2 * margin else length(row) >= ncol
    if (length(row) && full) {
      rows[[length(rows) + 1L]] <- row
      row <- integer()
      used <- 0
      need <- width[i]
    }
    row <- c(row, i)
    used <- used + need
  }
  rows[[length(rows) + 1L]] <- row

  row_width <- vapply(rows, function(r) sum(width[r]) + gutter * (length(r) - 1L), numeric(1))
  row_height <- vapply(rows, function(r) caption + max(tall[r]), numeric(1))
  page_w <- 2 * margin + max(row_width)
  page_h <- 2 * margin + heading + sum(row_height) + gutter * (length(rows) - 1L)

  page <- cowplot::ggdraw(xlim = c(0, page_w), ylim = c(0, page_h))
  top <- page_h - margin
  if (!is.null(title)) {
    page <- page + cowplot::draw_label(title, x = margin, y = top, hjust = 0, vjust = 1,
                                       fontface = "bold", size = 8)
    top <- top - heading
  }
  for (r in seq_along(rows)) {
    left <- margin
    for (i in rows[[r]]) {
      spec <- specs[[i]]
      detail <- sprintf("%s mm%s, %s pt text, %s", format(width[i]),
                        if (isTRUE(spec$sizes)) "" else " (generic)", format(spec$text_pt), spec$palette)
      bottom <- top - caption - tall[i]
      page <- page +
        cowplot::draw_label(spec$name, x = left, y = top, hjust = 0, vjust = 1, fontface = "bold", size = 7) +
        cowplot::draw_label(detail, x = left, y = top - 3.6, hjust = 0, vjust = 1, size = 6, colour = "grey35") +
        cowplot::draw_plot(figures[[i]], x = left, y = bottom, width = width[i], height = tall[i]) +
        ggplot2::annotate("rect", xmin = left, xmax = left + width[i], ymin = bottom, ymax = bottom + tall[i],
                          fill = NA, colour = "grey75", linewidth = 0.2)
      left <- left + width[i] + gutter
    }
    top <- top - row_height[r] - gutter
  }
  attr(page, "size_mm") <- c(width = page_w, height = page_h)
  page
}

# The smallest distance between two of the colors, in CIEDE2000, as seen with
# normal vision or as simulated for a color-vision deficiency
min_color_distance <- function(colors, vision = c("normal", "deutan", "protan", "tritan")) {
  vision <- match.arg(vision)
  if (length(colors) < 2L) return(NA_real_)
  rgb <- farver::decode_colour(colors)
  if (vision != "normal") {
    if (!requireNamespace("colorspace", quietly = TRUE)) return(NA_real_)
    simulate <- switch(vision, deutan = colorspace::deutan, protan = colorspace::protan,
                       tritan = colorspace::tritan)
    rgb <- farver::decode_colour(simulate(farver::encode_colour(rgb, from = "rgb")))
  }
  distance <- farver::compare_colour(rgb, rgb, from_space = "rgb", method = "cie2000")
  min(distance[upper.tri(distance)])
}

#' Compare Color Palettes
#'
#' For each palette, how far apart are its colors? The table gives the smallest
#' distance between two of the first `n` colors, as seen with normal vision and as
#' seen with the three kinds of color-vision deficiency (deuteranopia,
#' protanopia and tritanopia). Two colors that are close are easy to confuse in a
#' figure, and many journals ask for figures that readers with a color-vision
#' deficiency can read.
#'
#' The distance is CIEDE2000. A distance below about 10 means that two colors are
#' easy to confuse; this is a rule of thumb, not a standard. The simulations need
#' the colorspace package; without it only normal vision is compared.
#'
#' @param sets The names of color scale sets (see [list_color_scales()]). By
#'   default the palettes of the journals in [journal_templates()].
#' @param n The number of colors to compare, taken from the start of the palette.
#'   A palette with fewer colors is compared as it is.
#' @param threshold The distance under which colors count as easy to confuse.
#' @return A data frame with one row per palette: `set`, `n`, the smallest
#'   distance for `normal`, `deutan`, `protan` and `tritan` vision, `worst` (the
#'   smallest of the four) and `confusable` (`worst` below `threshold`).
#' @seealso [journal_colors()] for the colors of a journal.
#' @export
#' @examples
#' compare_palettes(c("npg", "okabe_ito"), n = 5)
compare_palettes <- function(sets = unique(journal_registry()$palette), n = 6, threshold = 10) {
  rows <- lapply(sets, function(set) {
    scale <- scale_color_set(set)
    k <- min(n, palette_size(scale))
    colors <- unname(scale$palette(k))
    colors <- colors[seq_len(min(k, length(colors)))]   # a fixed vector of colors ignores k
    data.frame(
      set = set, n = length(colors),
      normal = min_color_distance(colors, "normal"),
      deutan = min_color_distance(colors, "deutan"),
      protan = min_color_distance(colors, "protan"),
      tritan = min_color_distance(colors, "tritan"),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  out$worst <- apply(out[, c("normal", "deutan", "protan", "tritan")], 1L,
                     function(x) if (all(is.na(x))) NA_real_ else min(x, na.rm = TRUE))
  out$confusable <- out$worst < threshold
  out
}

#' Save a Figure at the Size of a Journal
#'
#' Saves a plot, in the file format given by the extension of the file name, at
#' the width of a column of a journal. Text and lines then have the size that the
#' template of the journal says: 7 pt is 7 pt on the page.
#'
#' A figure made by [compare_journals()] is saved at the size of its page, and
#' `journal`, `column` and `height` are ignored. Use a vector format (`.pdf`)
#' where the journal asks for one; a `.png` is for previews and for the
#' journals that take bitmaps.
#'
#' @inheritParams compare_journals
#' @param plot A ggplot object, or the page made by [compare_journals()].
#' @param filename The file name, with the extension of the format.
#' @param journal The journal, as in [journal_template()]. Not needed for a page
#'   made by [compare_journals()].
#' @param height The height in mm. By default 0.75 times the width. A warning
#'   says if it is more than the journal allows.
#' @param dpi The resolution of bitmaps, in dots per inch.
#' @param ... Passed on to [ggplot2::ggsave()].
#' @return The file name, invisibly.
#' @seealso [journal_check()]
#' @export
#' @examples
#' \dontrun{
#' p <- apply_journal(my_plot, "nature")
#' save_journal_figure(p, "figure1.pdf", journal = "nature", column = "double")
#' }
save_journal_figure <- function(plot, filename, journal = NULL, column = "single",
                                height = NULL, dpi = 300, ...) {
  size <- attr(plot, "size_mm")
  if (!is.null(size)) {
    width <- unname(size[1])
    height <- unname(size[2])
  } else {
    if (is.null(journal)) {
      stop("Give the `journal` to save the figure for, or save a page made by compare_journals().", call. = FALSE)
    }
    spec <- journal_template(journal)
    width <- journal_width(spec, column)
    height <- if (is.null(height)) width * 0.75 else as.numeric(height)
    if (!is.na(spec$max_height_mm) && height > spec$max_height_mm) {
      warning("The height of ", format(height), " mm is more than the ", format(spec$max_height_mm),
              " mm that ", spec$name, " allows.", call. = FALSE)
    }
  }

  extension <- tolower(sub("^.*\\.", "", filename))
  device <- if (extension == "pdf" && isTRUE(capabilities("cairo"))) {
    grDevices::cairo_pdf
  } else if (extension == "png" && requireNamespace("ragg", quietly = TRUE)) {
    ragg::agg_png
  }
  ggplot2::ggsave(filename, plot, width = width, height = height, units = "mm",
                  dpi = dpi, device = device, ...)
  invisible(filename)
}
