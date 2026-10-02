# --------------------------------------------------------------------------
# File: themeset/R/journal_fix.R
# --------------------------------------------------------------------------
# Repairing a figure so that it passes the checks of journal_check().

# A layer with some of its fixed aesthetics changed. Layers are ggproto objects,
# which are environments: changing one in place would change the plot it came from.
layer_with <- function(layer, ...) {
  new <- ggplot2::ggproto(NULL, layer)
  new$aes_params <- utils::modifyList(layer$aes_params, list(...))
  new
}

# A theme that sets one element, given by its name
theme_element <- function(name, element) {
  do.call(ggplot2::theme, stats::setNames(list(element), name))
}

# The discrete color and fill scales of a plot, by aesthetic, or NULL where the
# aesthetic is not mapped or its scale is continuous
discrete_scales <- function(plot) {
  built <- tryCatch(ggplot2::ggplot_build(plot), error = function(e) NULL)
  if (is.null(built)) return(list())
  scales <- list()
  for (aesthetic in c("colour", "fill")) {
    scale <- built$plot$scales$get_scales(aesthetic)
    # A scale that was added but has no data mapped to it is empty
    if (!is.null(scale) && inherits(scale, "ScaleDiscrete") && !scale$is_empty()) scales[[aesthetic]] <- scale
  }
  scales
}

# The smallest distance between two colors of a plot, over the simulated visions
worst_color_distance <- function(plot) {
  colors <- drawn_colors(plot)
  if (length(colors) < 2L || length(colors) > 12L) return(NA_real_)
  distance <- vapply(c("normal", "deutan", "protan", "tritan"),
                     function(v) min_color_distance(colors, v), numeric(1))
  if (all(is.na(distance))) NA_real_ else min(distance, na.rm = TRUE)
}

# One round of repairs on one panel. Returns the panel and a log of what changed.
fix_panel <- function(plot, spec, fix) {
  log <- list()
  note <- function(check, target, before, after) {
    log[[length(log) + 1L]] <<- data.frame(check = check, target = target, before = before,
                                           after = after, stringsAsFactors = FALSE)
  }
  pt <- function(x) sprintf("%.1f pt", x)

  if ("text" %in% fix) {
    sizes <- text_sizes(plot)
    low <- spec$min_text_pt
    high <- if (is.na(spec$max_text_pt)) Inf else spec$max_text_pt
    for (name in unique(names(sizes))) {
      size <- min(sizes[names(sizes) == name])
      if (size >= low - 1e-6 && max(sizes[names(sizes) == name]) <= high + 1e-6) next
      if (name == "text layer") {
        for (i in seq_along(plot$layers)) {
          layer <- plot$layers[[i]]
          if (!inherits(layer$geom, c("GeomText", "GeomLabel")) || is.null(layer$aes_params$size)) next
          in_pt <- identical(layer$geom_params$size.unit, "pt")
          old <- if (in_pt) layer$aes_params$size else layer$aes_params$size * ggplot2::.pt
          new <- min(max(old, low), high)
          if (abs(new - old) < 1e-6) next
          plot$layers[[i]] <- layer_with(layer, size = if (in_pt) new else new / ggplot2::.pt)
          note("text", paste0("layer ", i, " (", class(layer$geom)[1], ")"), pt(old), pt(new))
        }
      } else {
        new <- min(max(size, low), high)
        plot <- plot + theme_element(name, ggplot2::element_text(size = new))
        note("text", name, pt(size), pt(new))
      }
    }
  }

  if ("lines" %in% fix) {
    widths <- line_widths(plot)
    thin <- widths[widths < min_line_pt - 1e-6]
    for (name in names(thin)) {
      new_mm <- min_line_pt / ggplot2::.pt
      if (startsWith(name, "layer ")) {
        i <- as.integer(sub("^layer ([0-9]+).*$", "\\1", name))
        layer <- plot$layers[[i]]
        if ("linewidth" %in% c(names(plot$mapping), names(layer$mapping))) {
          note("lines", name, sprintf("%.2f pt", thin[[name]]), "not changed: the width is mapped to data")
          next
        }
        plot$layers[[i]] <- layer_with(layer, linewidth = new_mm)
      } else {
        plot <- plot + theme_element(name, ggplot2::element_line(linewidth = new_mm))
      }
      note("lines", name, sprintf("%.2f pt", thin[[name]]), sprintf("%.2f pt", min_line_pt))
    }
  }

  if ("tags" %in% fix) {
    built <- tryCatch(ggplot2::ggplot_build(plot), error = function(e) NULL)
    tag <- if (is.null(built)) plot$labels$tag else built$plot$labels$tag
    if (!is.null(tag) && !inherits(tag, "waiver") && grepl("^[A-Za-z]$", tag)) {
      new <- if (spec$tag == "lower") tolower(tag) else toupper(tag)
      if (!identical(new, tag)) {
        plot <- plot + ggplot2::labs(tag = new)
        note("tags", "plot.tag", tag, new)
      }
    }
  }

  if ("colors" %in% fix) {
    before <- worst_color_distance(plot)
    scales <- discrete_scales(plot)
    if (!is.na(before) && before < 10 && length(scales)) {
      candidate <- plot
      for (aesthetic in names(scales)) {
        old <- scales[[aesthetic]]
        if (length(old$get_limits()) > 8L) next   # more groups than Okabe-Ito has colors
        scale <- if (aesthetic == "colour") scale_color_set("okabe_ito") else scale_fill_set("okabe_ito")
        if (!inherits(old$name, "waiver")) scale$name <- old$name
        candidate <- suppressMessages(candidate + scale)
      }
      after <- worst_color_distance(candidate)
      # Keep the new colors only if they can be told apart better than the old ones
      if (!is.na(after) && after > before) {
        plot <- candidate
        note("colors", paste(names(scales), collapse = ", "), sprintf("%.1f", before),
             sprintf("%.1f (okabe_ito)", after))
      }
    }
  }

  list(plot = plot, log = if (length(log)) do.call(rbind, log) else NULL)
}

#' Repair a Figure for a Journal
#'
#' Changes what [journal_check()] finds wrong with a plot, and checks it again,
#' until the checks pass or there is nothing left that can be changed. The
#' changes are kept small: a text that is too small is raised to the smallest
#' size that the journal allows and no further, and the rest of the plot is
#' left as it is. To give a plot the whole style of a journal, use
#' [apply_journal()] instead.
#'
#' What is repaired:
#' * **text**: a text element of the theme, or a text layer with a size you gave,
#'   that is smaller than the smallest size of the journal, or larger than the
#'   largest, gets the size of the limit.
#' * **lines**: a line of the theme or of a layer that is thinner than 0.25 pt
#'   gets 0.25 pt. A width that is mapped to data is left alone and reported.
#' * **tags**: a panel tag of one letter in the wrong case is changed to the case
#'   that the journal prints.
#' * **colors**: when two colors are hard to tell apart, the discrete color and
#'   fill scales are replaced by the Okabe-Ito palette, but only if that makes
#'   the closest pair easier to tell apart, and only for eight groups or fewer.
#'
#' The height is not changed: give it to [save_journal_figure()].
#'
#' @inheritParams journal_check
#' @param plot A ggplot object, or a list of them, for a figure of several
#'   panels. Each panel is repaired on its own.
#' @param fix What to repair: any of `"text"`, `"lines"`, `"tags"` and
#'   `"colors"`.
#' @param rounds The largest number of rounds of repair and check.
#' @param quiet If `FALSE`, a message lists the changes.
#' @return The plot, or the list of panels, with the changes. The attribute
#'   `fixes` is a data frame with a row per change (`round`, `panel`, `check`,
#'   `target`, `before` and `after`), and the attribute `check` is the result of
#'   [journal_check()] on the repaired figure.
#' @seealso [journal_check()], [journal_audit()] for the figures of a paper.
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' p <- ggplot(od, aes(time, value, color = strain)) +
#'   geom_line(linewidth = 0.05) +
#'   labs(x = "Incubation time (hr)", y = "OD600", color = NULL, tag = "A") +
#'   theme_classic(base_size = 4)
#'
#' journal_check(p, "nature")
#'
#' fixed <- journal_fix(p, "nature")
#' attr(fixed, "fixes")
#' attr(fixed, "check")
journal_fix <- function(plot, journal = "nature", column = "single", height = NULL,
                        fix = c("text", "lines", "tags", "colors"), rounds = 3, quiet = TRUE) {
  spec <- journal_template(journal)
  fix <- match.arg(fix, several.ok = TRUE)
  single <- inherits(plot, "ggplot")
  panels <- if (single) list(plot) else plot
  if (!is.list(panels) || !length(panels) || !all(vapply(panels, inherits, logical(1), "ggplot"))) {
    stop("`plot` must be a ggplot object or a list of them.", call. = FALSE)
  }
  if (!is.numeric(rounds) || length(rounds) != 1L || is.na(rounds) || rounds < 1) {
    stop("`rounds` must be a number of rounds, 1 or more.", call. = FALSE)
  }

  log <- list()
  check <- suppressWarnings(journal_check(panels, spec, column = column, height = height))
  for (round in seq_len(rounds)) {
    if (identical(attr(check, "overall"), "pass")) break
    changed <- FALSE
    for (k in seq_along(panels)) {
      result <- fix_panel(panels[[k]], spec, fix)
      panels[[k]] <- result$plot
      if (!is.null(result$log)) {
        log[[length(log) + 1L]] <- cbind(round = round, panel = k, result$log)
        changed <- changed || any(!startsWith(result$log$after, "not changed"))
      }
    }
    if (!changed) break
    check <- suppressWarnings(journal_check(panels, spec, column = column, height = height))
  }

  fixes <- if (length(log)) {
    do.call(rbind, log)
  } else {
    data.frame(round = integer(), panel = integer(), check = character(), target = character(),
               before = character(), after = character(), stringsAsFactors = FALSE)
  }
  fixes <- fixes[!duplicated(fixes[c("panel", "check", "target", "after")]), , drop = FALSE]
  rownames(fixes) <- NULL
  if (!quiet) {
    if (nrow(fixes)) {
      message(paste0("panel ", fixes$panel, ", ", fixes$target, ": ", fixes$before, " -> ", fixes$after,
                     collapse = "\n"))
    } else {
      message("Nothing to change.")
    }
  }
  out <- if (single) panels[[1]] else panels
  attr(out, "fixes") <- fixes
  attr(out, "check") <- check
  out
}
