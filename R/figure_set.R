# --------------------------------------------------------------------------
# File: themeset/R/figure_set.R
# --------------------------------------------------------------------------
# The figures of one paper as a set: one style for all, and the same color for
# the same group in every figure.

# The color that each group of a discrete color or fill scale gets, as a data
# frame with the columns aesthetic, group and color
group_colors <- function(plot) {
  scales <- discrete_scales(plot)
  rows <- lapply(names(scales), function(aesthetic) {
    scale <- scales[[aesthetic]]
    groups <- scale$get_limits()
    groups <- groups[!is.na(groups)]
    if (!length(groups)) return(NULL)
    colors <- scale$map(groups)
    keep <- !is.na(colors)
    if (!any(keep)) return(NULL)
    data.frame(aesthetic = aesthetic, group = as.character(groups[keep]),
               color = farver::encode_colour(farver::decode_colour(colors[keep])),
               stringsAsFactors = FALSE)
  })
  rows <- rows[!vapply(rows, is.null, logical(1))]
  if (!length(rows)) return(data.frame(aesthetic = character(), group = character(), color = character()))
  do.call(rbind, rows)
}

# The colors of the palette of a discrete scale, as many as it gives up to `n`
scale_palette <- function(scale, n) {
  colors <- tryCatch(suppressWarnings(unname(scale$palette(n))), error = function(e) NULL)
  colors <- colors[!is.na(colors)]
  if (!length(colors)) return(character())
  unique(farver::encode_colour(farver::decode_colour(colors)))
}

#' Match the Style of a Reference Figure
#'
#' Draws a plot in the style of another one: the theme of the reference, and its
#' colors for the groups that the two plots share. A group that is, for example,
#' blue in the reference is blue in the plot as well, so that the figures of a
#' paper agree with each other. Groups that the reference does not have get the
#' colors of its palette that are still free.
#'
#' The theme of the reference replaces the theme of the plot as a whole. The
#' discrete color and fill scales of the plot are replaced by manual scales that
#' keep their name and guide; continuous scales are left alone. The labels, the
#' layers and the data of the plot do not change.
#'
#' @param plot A ggplot object.
#' @param reference The ggplot object whose style to take.
#' @param theme If `TRUE`, take the theme of the reference.
#' @param colors If `TRUE`, take the colors of the reference for the groups of
#'   discrete color and fill scales.
#' @return A ggplot object.
#' @seealso [journal_audit()] to find the groups that have different colors in
#'   the figures of a paper.
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' reference <- ggplot(od, aes(time, value, color = strain)) +
#'   geom_line() +
#'   labs(x = "Incubation time (hr)", y = "OD600", color = NULL) +
#'   scale_color_set("npg") +
#'   journal_theme("nature")
#'
#' # The last time point of three strains only, in the default style
#' last <- subset(od, time == max(time) & strain %in% unique(od$strain)[c(2, 4, 5)])
#' p <- ggplot(last, aes(strain, value, fill = strain)) +
#'   geom_col() +
#'   labs(x = NULL, y = "Final OD600")
#'
#' match_style(p, reference)
match_style <- function(plot, reference, theme = TRUE, colors = TRUE) {
  if (!inherits(plot, "ggplot") || !inherits(reference, "ggplot")) {
    stop("`plot` and `reference` must be ggplot objects.", call. = FALSE)
  }
  if (isTRUE(theme)) plot <- plot + effective_theme(reference)
  if (!isTRUE(colors)) return(plot)

  known <- group_colors(reference)
  if (!nrow(known)) return(plot)
  reference_scales <- discrete_scales(reference)
  scales <- discrete_scales(plot)
  for (aesthetic in names(scales)) {
    old <- scales[[aesthetic]]
    groups <- as.character(old$get_limits())
    groups <- groups[!is.na(groups)]
    if (!length(groups)) next

    # The color of a group in the same aesthetic of the reference comes first
    same <- known[known$aesthetic == aesthetic, ]
    other <- known[known$aesthetic != aesthetic, ]
    lookup <- c(stats::setNames(same$color, same$group),
                stats::setNames(other$color, other$group)[!other$group %in% same$group])
    values <- stats::setNames(unname(lookup[groups]), groups)

    missing <- is.na(values)
    if (any(missing)) {
      source <- reference_scales[[aesthetic]]
      if (is.null(source)) source <- reference_scales[[1]]
      wanted <- sum(missing) + length(unique(known$color))
      # Not a color that a group of the reference has, in this plot or not
      taken <- c(values, known$color)
      free <- setdiff(scale_palette(source, wanted), taken)
      if (length(free) < sum(missing)) {
        free <- c(free, setdiff(scale_palette(scale_color_set("okabe_ito"), 8L), c(taken, free)))
      }
      if (length(free) < sum(missing)) {
        stop("The reference has too few colors for the ", sum(missing), " new group(s) of the ",
             aesthetic, " scale.", call. = FALSE)
      }
      values[missing] <- free[seq_len(sum(missing))]
    }
    scale <- ggplot2::scale_colour_manual(values = values, aesthetics = aesthetic,
                                          guide = old$guide, na.value = old$na.value)
    if (!inherits(old$name, "waiver")) scale$name <- old$name
    plot <- suppressMessages(plot + scale)
  }
  plot
}

#' Audit the Figures of a Paper
#'
#' Checks every figure of a paper against a journal with [journal_check()], and
#' then checks that the figures agree with each other.
#'
#' The figures are compared on:
#'
#' * **group colors**: a group, such as a strain or a treatment, has the same
#'   color in every figure that shows it. A group that is blue in Figure 1 and red
#'   in Figure 3 gives a warning.
#' * **tick labels** and **axis titles**: the text of the axes has one size in
#'   all the figures.
#' * **font family**: the figures use one font family.
#'
#' The result has one row per check: the rows of each figure where
#' `journal_check()` did not pass, and the rows that compare the figures, whose
#' `figure` is `"all"`. [match_style()] gives a figure the style and the colors
#' of another one, and [journal_fix()] repairs what the journal does not allow.
#'
#' @inheritParams journal_check
#' @param figures A list of figures: each a ggplot object or a list of panels.
#'   The names of the list name the figures in the table; without names they
#'   are numbered.
#' @param column The column that the figures are drawn at: one for all, or one
#'   per figure.
#' @return A data frame of class `journal_audit` with the columns `figure`,
#'   `check`, `status`, `value`, `limit` and `note`. The attribute `overall` has
#'   the worst status, and the attribute `colors` has the color of every group
#'   in every figure (`figure`, `aesthetic`, `group` and `color`).
#' @seealso [journal_check()] for one figure.
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' growth <- ggplot(od, aes(time, value, color = strain)) +
#'   geom_line() +
#'   labs(x = "Incubation time (hr)", y = "OD600", color = NULL)
#' last <- subset(od, time == max(time))
#' final <- ggplot(last, aes(strain, value, fill = strain)) +
#'   geom_col() +
#'   labs(x = NULL, y = "Final OD600", fill = NULL)
#'
#' figures <- list(
#'   "Figure 1" = apply_journal(growth, "nature"),
#'   "Figure 2" = apply_journal(final, "nature", palette = "okabe_ito")
#' )
#' journal_audit(figures, "nature")
#'
#' # the second figure in the colors of the first
#' figures[["Figure 2"]] <- match_style(figures[["Figure 2"]], figures[["Figure 1"]])
#' journal_audit(figures, "nature")
journal_audit <- function(figures, journal = "nature", column = "single") {
  spec <- journal_template(journal)
  if (inherits(figures, "ggplot") || !is.list(figures) || !length(figures)) {
    stop("`figures` must be a list of figures, each a ggplot object or a list of them.", call. = FALSE)
  }
  ids <- names(figures)
  if (is.null(ids)) ids <- rep("", length(figures))
  ids[ids == ""] <- paste("Figure", seq_along(figures))[ids == ""]
  panels <- lapply(figures, function(f) if (inherits(f, "ggplot")) list(f) else f)
  ok <- vapply(panels, function(p) is.list(p) && length(p) && all(vapply(p, inherits, logical(1), "ggplot")),
               logical(1))
  if (!all(ok)) {
    stop("Figure(s) ", paste(ids[!ok], collapse = ", "), " must be a ggplot object or a list of them.", call. = FALSE)
  }
  if (!length(column) %in% c(1L, length(figures))) {
    stop("`column` must be one column for all the figures or one per figure.", call. = FALSE)
  }
  column <- rep(column, length.out = length(figures))

  rows <- list()
  add <- function(figure, check, status, value, limit = "", note = "") {
    rows[[length(rows) + 1L]] <<- data.frame(figure = figure, check = check, status = status, value = value,
                                             limit = limit, note = note, stringsAsFactors = FALSE)
  }

  # Each figure against the journal
  for (k in seq_along(panels)) {
    check <- journal_check(panels[[k]], spec, column = column[[k]])
    bad <- check[check$status %in% c("warn", "fail"), , drop = FALSE]
    if (!nrow(bad)) {
      add(ids[k], "journal", "pass", "all checks pass", spec$name)
    } else {
      for (i in seq_len(nrow(bad))) add(ids[k], bad$check[i], bad$status[i], bad$value[i], bad$limit[i], bad$note[i])
    }
  }

  # The color of each group in each figure
  colors <- do.call(rbind, lapply(seq_along(panels), function(k) {
    found <- do.call(rbind, lapply(panels[[k]], group_colors))
    if (is.null(found) || !nrow(found)) return(NULL)
    cbind(figure = ids[k], unique(found), stringsAsFactors = FALSE)
  }))
  if (is.null(colors)) {
    colors <- data.frame(figure = character(), aesthetic = character(), group = character(), color = character(),
                         stringsAsFactors = FALSE)
  }
  shared <- names(which(tapply(colors$figure, colors$group, function(f) length(unique(f))) > 1L))
  if (!length(shared)) {
    add("all", "group colors", "info", "no group in two figures", "", "nothing to compare")
  } else {
    # A group clashes when two figures draw it with no color in common
    clash <- vapply(shared, function(group) {
      sets <- split(colors$color[colors$group == group], colors$figure[colors$group == group])
      pairs <- utils::combn(length(sets), 2L)
      any(apply(pairs, 2L, function(p) !length(intersect(sets[[p[1]]], sets[[p[2]]]))))
    }, logical(1))
    if (any(clash)) {
      details <- vapply(shared[clash], function(group) {
        here <- unique(colors[colors$group == group, c("figure", "color")])
        paste0(group, ": ", paste0(here$color, " (", here$figure, ")", collapse = ", "))
      }, character(1))
      add("all", "group colors", "warn", paste(sum(clash), "of", length(shared), "groups differ"),
          "one color per group", paste(details, collapse = "; "))
    } else {
      add("all", "group colors", "pass", paste(length(shared), "shared groups"), "one color per group")
    }
  }

  # The text of the axes and the font, which should be the same in every figure
  element_size <- function(plot, element) {
    if (element == "axis.title.x" && is.null(plot$labels$x)) return(NA_real_)
    el <- tryCatch(ggplot2::calc_element(element, effective_theme(plot)), error = function(e) NULL)
    if (is.null(el) || inherits(el, "element_blank") || is.null(el$size)) NA_real_ else as.numeric(el$size)
  }
  same <- function(check, values, format) {
    values <- values[!is.na(values)]
    distinct <- unique(values)
    if (length(distinct) <= 1L) {
      add("all", check, "pass", if (length(distinct)) format(distinct) else "-", "the same in all figures")
    } else {
      by_figure <- tapply(values, names(values), function(v) paste(format(unique(v)), collapse = " and "))
      add("all", check, "warn", paste(length(distinct), "values"), "the same in all figures",
          paste0(names(by_figure), ": ", by_figure, collapse = "; "))
    }
  }
  # One value per panel, named by the figure of the panel
  figure_values <- function(f) {
    unlist(lapply(seq_along(panels), function(k) {
      stats::setNames(unlist(lapply(panels[[k]], f)), rep(ids[k], length(panels[[k]])))
    }))
  }
  pt <- function(x) sprintf("%.1f pt", x)
  same("tick labels", figure_values(function(p) element_size(p, "axis.text.x")), pt)
  same("axis titles", figure_values(function(p) element_size(p, "axis.title.x")), pt)
  family <- figure_values(function(p) {
    el <- tryCatch(ggplot2::calc_element("text", effective_theme(p)), error = function(e) NULL)
    if (is.null(el$family) || !nzchar(el$family)) "default" else el$family
  })
  same("font family", family, function(x) x)

  out <- do.call(rbind, rows)
  status <- out$status
  structure(out, class = c("journal_audit", "data.frame"),
            journal = spec$journal, name = spec$name, colors = colors,
            overall = if ("fail" %in% status) "fail" else if ("warn" %in% status) "warn" else "pass")
}

#' @export
print.journal_audit <- function(x, ...) {
  columns <- c("figure", "check", "status", "value", "limit", "note")
  if (!all(columns %in% names(x))) return(NextMethod())   # a table that was cut down
  name <- attr(x, "name", exact = TRUE)
  overall <- attr(x, "overall", exact = TRUE)
  cat("Audit of ", length(setdiff(unique(x$figure), "all")), " figure(s) for ",
      if (is.null(name)) "a journal" else name, if (!is.null(overall)) paste0(": ", overall), "\n", sep = "")
  cells <- as.matrix(as.data.frame(x)[columns[1:5]])
  widths <- pmax(nchar(colnames(cells)), apply(nchar(cells), 2L, max))
  pad <- function(text) paste(sprintf("%-*s", widths, text), collapse = "  ")
  cat(pad(colnames(cells)), "  note\n", sep = "")
  for (i in seq_len(nrow(cells))) cat(pad(cells[i, ]), "  ", x$note[i], "\n", sep = "")
  invisible(x)
}
