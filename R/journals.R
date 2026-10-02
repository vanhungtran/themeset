# --------------------------------------------------------------------------
# File: themeset/R/journals.R
# --------------------------------------------------------------------------
# Journal templates: the figure sizes, text sizes, panel tags and palette of a
# journal, as a theme and as numbers. The numbers come from the author guides
# of the journals (the links are in the `guide` column), read in October 2026.
# Where a guide gives no number, the field is NA and a generic default is used.

# What is used when a journal does not say
generic_template <- list(
  single_mm = 85, onehalf_mm = 114, double_mm = 174,
  text_pt = 7, min_text_pt = 5, line_pt = 0.75, tag_case = "upper"
)

# The thinnest line that prints reliably (the figure guide of Nature)
min_line_pt <- 0.25

journal_registry <- function() {
  data.frame(
    journal = c("nature", "natcomms", "science", "cell", "pnas", "plos", "elsevier",
                "nejm", "lancet", "jama", "bmj", "jco", "frontiers"),
    name = c("Nature", "Nature Communications", "Science", "Cell Press journals", "PNAS",
             "PLOS journals", "Elsevier journals", "NEJM", "The Lancet", "JAMA", "BMJ",
             "Journal of Clinical Oncology", "Frontiers journals"),
    # Column widths in mm. For Science, onehalf is the two-column width and double the
    # three-column (full page) width. PLOS has no columns: its figures may be 66.8 to
    # 190.5 mm wide, and double is the full width.
    single_mm = c(89, 88, 57, 85, 87, NA, 90, NA, NA, NA, NA, NA, NA),
    onehalf_mm = c(NA, NA, 121, 114, 114, NA, 140, NA, NA, NA, NA, NA, NA),
    double_mm = c(183, 180, 184, 174, 178, 190.5, 190, NA, NA, NA, NA, NA, NA),
    # The height: a limit for Nature and Nature Communications and PLOS, a
    # recommendation (54 picas) for PNAS
    max_height_mm = c(170, 225, NA, NA, 228.6, 222.25, NA, NA, NA, NA, NA, NA, NA),
    # Body text, the smallest and the largest text size in points. Panel tags are
    # not counted in the largest size.
    text_pt = c(7, 7, 7, 7, 7, 8, 7, NA, NA, NA, NA, NA, NA),
    min_text_pt = c(5, 5, 5, 6, 6, 8, 6, NA, NA, NA, NA, NA, NA),
    max_text_pt = c(7, 7, 9, 8, 12, 12, NA, NA, NA, NA, NA, NA, NA),
    # Panel tags: Nature and Science state their size; for the others the size is the
    # body text size plus one point, and the case is the one the journal prints.
    tag_pt = c(8, 8, 10, 8, 8, 9, 8, NA, NA, NA, NA, NA, NA),
    tag = c("lower", "lower", "upper", "upper", "upper", "upper", "upper",
            NA, NA, NA, NA, NA, NA),
    # The guide of Nature lists the Okabe-Ito colors for color-blind readers. The other
    # palettes are the ones of ggsci that take their inspiration from the journals, and
    # Okabe-Ito stands in where themeset knows no palette for a journal.
    palette = c("npg", "npg", "aaas", "okabe_ito", "okabe_ito", "okabe_ito", "okabe_ito",
                "nejm", "lancet", "jama", "bmj", "jco", "frontiers"),
    # FALSE where the journal redraws figures and gives no size to draw them at
    sizes = c(rep(TRUE, 7), rep(FALSE, 6)),
    guide = c("https://research-figure-guide.nature.com/figures/building-and-exporting-figure-panels/",
              "https://www.nature.com/ncomms/submit/how-to-submit",
              "https://www.science.org/content/page/instructions-preparing-initial-manuscript",
              "https://www.cell.com/information-for-authors/figure-guidelines",
              "https://www.pnas.org/pb-assets/authors/digitalart-1675347574760.pdf",
              "https://journals.plos.org/plosone/s/figures",
              "https://www.elsevier.com/about/policies-and-standards/author/artwork-and-media-instructions/artwork-sizing",
              NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
}

#' Journal Templates
#'
#' The figure templates of the journals that `themeset` knows: the widths of
#' their columns, the limits for the size of the text, the style of the panel
#' tags and the palette to use.
#'
#' `journal_templates()` lists them all as a data frame. `journal_template()`
#' returns one of them, as an object that the other journal functions accept in
#' place of the name of the journal. Changing a field of it makes a template of
#' your own, and a new name with the fields of your journal makes one from
#' scratch.
#'
#' @section Where the numbers come from:
#' They come from the author guides of the journals, read in October 2026; the
#' `guide` field has the address of each guide. Journals change their guides, so
#' read the current one before you submit, and note that a journal can have more
#' than one guide, with numbers that differ a little: Science, for example, has
#' one for the first submission and one for the final figures. Some journals do
#' not give a number: the field is then `NA`, and `themeset` falls back on
#' generic values (85, 114 and 174 mm wide, 7 pt text, panel tags of body size
#' plus one point in capital letters). The journals that redraw the figures of
#' authors (NEJM, The Lancet, JAMA, BMJ, JCO and Frontiers here) have
#' `sizes = FALSE`: only their palette is specific.
#'
#' Nature states the size of its panel tags (8 pt, bold, lowercase) and so does
#' the figure guide of Science (10 pt, bold, capitals). For the other journals the
#' case of the tags is the one that the journal prints, and the size is a
#' convention.
#'
#' The palettes of the journals are the palettes of ggsci that take their
#' inspiration from them, and `themeset` is not affiliated with any journal.
#' ggsci has no palette for Cell Press, PNAS, PLOS and Elsevier, so they get the
#' Okabe-Ito palette, which was designed to be told apart by readers with
#' color-vision deficiency and which the guide of Nature lists.
#'
#' @param journal The id of a journal (see `journal_templates()`), or a template
#'   made by `journal_template()`.
#' @param ... Fields to change, for example `text_pt = 6`, or all the fields of a
#'   new journal: `single_mm`, `onehalf_mm`, `double_mm`, `max_height_mm`,
#'   `text_pt`, `min_text_pt`, `max_text_pt`, `tag_pt`, `tag` (`"lower"` or
#'   `"upper"`), `palette` (the name of a color scale set) and `name`.
#' @return `journal_templates()`: a data frame with one row per journal.
#'   `journal_template()`: a list of class `journal_template`.
#' @seealso [journal_theme()], [apply_journal()], [compare_journals()]
#' @export
#' @examples
#' journal_templates()[, c("journal", "single_mm", "double_mm", "text_pt", "palette")]
#'
#' journal_template("nature")
#'
#' # Nature, with a smaller text size
#' journal_template("nature", text_pt = 6)
#'
#' # A journal of your own
#' journal_template("my_journal", single_mm = 80, double_mm = 165, palette = "npg")
journal_templates <- function() {
  journal_registry()
}

#' @rdname journal_templates
#' @export
journal_template <- function(journal = "nature", ...) {
  changes <- list(...)
  if (inherits(journal, "journal_template")) {
    spec <- unclass(journal)
  } else {
    if (!is.character(journal) || length(journal) != 1L || is.na(journal)) {
      stop("`journal` must be the id of one journal. Run journal_templates() for the ids.", call. = FALSE)
    }
    registry <- journal_registry()
    row <- registry[registry$journal == journal, , drop = FALSE]
    if (nrow(row)) {
      spec <- as.list(row)
    } else if (length(changes)) {
      spec <- list(journal = journal, name = journal)   # a journal of your own
    } else {
      stop("Journal '", journal, "' not found. Run journal_templates() for available options.", call. = FALSE)
    }
  }

  fields <- c("name", "single_mm", "onehalf_mm", "double_mm", "max_height_mm", "text_pt",
              "min_text_pt", "max_text_pt", "tag_pt", "tag", "palette", "sizes", "guide")
  unknown <- setdiff(names(changes), fields)
  if (length(unknown)) {
    stop("Unknown field(s): ", paste(unknown, collapse = ", "), ". Use ", paste(fields, collapse = ", "), ".", call. = FALSE)
  }
  for (field in names(changes)) spec[[field]] <- changes[[field]]
  for (field in setdiff(fields, names(spec))) spec[[field]] <- NA
  if (!is.null(changes$single_mm) || !is.null(changes$double_mm) || !is.null(changes$text_pt)) {
    if (is.null(changes$sizes)) spec$sizes <- TRUE   # you gave sizes of your own
  }
  if (is.na(spec$sizes)) spec$sizes <- FALSE

  # Generic values where the journal gives none
  spec$text_pt <- if (is.na(spec$text_pt)) generic_template$text_pt else spec$text_pt
  spec$min_text_pt <- if (is.na(spec$min_text_pt)) min(generic_template$min_text_pt, spec$text_pt) else spec$min_text_pt
  spec$tag_pt <- if (is.na(spec$tag_pt)) spec$text_pt + 1 else spec$tag_pt
  spec$tag <- if (is.na(spec$tag)) generic_template$tag_case else spec$tag
  spec$palette <- if (is.na(spec$palette)) "okabe_ito" else spec$palette
  spec$line_pt <- generic_template$line_pt
  if (!spec$tag %in% c("lower", "upper")) stop("`tag` must be \"lower\" or \"upper\".", call. = FALSE)
  structure(spec, class = "journal_template")
}

#' @export
print.journal_template <- function(x, ...) {
  width <- function(mm) if (is.na(mm)) "-" else paste0(format(mm), " mm")
  cat("Journal template: ", x$name, " (", x$journal, ")\n", sep = "")
  cat("  widths:  single ", width(x$single_mm), ", one and a half ", width(x$onehalf_mm),
      ", double ", width(x$double_mm), if (!isTRUE(x$sizes)) "  (generic: the journal gives no size)", "\n", sep = "")
  cat("  height:  ", if (is.na(x$max_height_mm)) "no limit given" else paste0("at most ", format(x$max_height_mm), " mm"), "\n", sep = "")
  cat("  text:    ", x$text_pt, " pt, at least ", x$min_text_pt, " pt",
      if (!is.na(x$max_text_pt)) paste0(", at most ", x$max_text_pt, " pt"), "\n", sep = "")
  cat("  tags:    ", x$tag_pt, " pt, bold, ", x$tag, "case\n", sep = "")
  cat("  palette: ", x$palette, "\n", sep = "")
  if (!is.na(x$guide)) cat("  guide:   ", x$guide, "\n", sep = "")
  invisible(x)
}

# The width in mm of a column of a journal. `column` is "single", "onehalf" or
# "double", or a width in mm. A column that the journal does not have is
# replaced by the nearest one it has; a journal with no widths gets the generic ones.
journal_width <- function(journal, column = "single") {
  spec <- journal_template(journal)
  if (is.numeric(column)) return(as.numeric(column)[1])
  column <- match.arg(column, c("single", "onehalf", "double"))
  widths <- c(single = spec$single_mm, onehalf = spec$onehalf_mm, double = spec$double_mm)
  if (!is.na(widths[[column]])) return(unname(widths[[column]]))
  known <- which(!is.na(widths))
  if (!length(known)) {
    return(unname(c(single = generic_template$single_mm, onehalf = generic_template$onehalf_mm,
                    double = generic_template$double_mm)[[column]]))
  }
  wanted <- match(column, names(widths))
  distance <- abs(known - wanted)
  nearest <- known[distance == min(distance)]
  unname(widths[[max(nearest)]])   # the larger one on a tie
}

#' Panel Tags of a Journal
#'
#' The letters that label the panels of a figure, in the case that the journal
#' prints: lowercase for Nature and Nature Communications, capitals for the
#' others.
#'
#' @inheritParams journal_templates
#' @param n How many tags, at most 26.
#' @return A character vector.
#' @export
#' @examples
#' journal_tags("nature", 4)
#' journal_tags("science", 4)
journal_tags <- function(journal = "nature", n = 26) {
  spec <- journal_template(journal)
  if (!is.numeric(n) || length(n) != 1L || n < 1 || n > 26) stop("`n` must be a number from 1 to 26.", call. = FALSE)
  tags <- if (spec$tag == "lower") letters else LETTERS
  tags[seq_len(n)]
}

#' A Theme in the Style of a Journal
#'
#' A theme that follows the template of a journal: the L-shaped axes and white
#' background of `theme_classic()`, the body text size of the journal, axis and
#' legend text that is not below the smallest size it allows, thin lines, a
#' frameless legend and panel tags in the style of the journal.
#'
#' With ggplot2 4.0 or later the size of the text and the lines also sets the
#' default size of text, lines and points in the layers, so a `geom_line()` has
#' the right width without an argument.
#'
#' Draw the figure at the size that the journal prints it, with
#' [save_journal_figure()], so that a text size of 7 pt is 7 pt on the page.
#'
#' @inheritParams journal_templates
#' @param base_family The font family. Many journals ask for Arial or Helvetica,
#'   and `"sans"` stands for one of the two on many systems.
#' @param markdown If `TRUE`, the titles, the x axis title, the legend title and
#'   the strips render markdown, as in the theme sets, so that a title can have
#'   italic species names or an exponent. The default is plain text, which is
#'   what a figure with labels from your data needs: a label such as `<LOD>` is
#'   read as markup. See [md_theme_classic()] for what stays plain.
#' @return A `ggplot2` theme.
#' @seealso [apply_journal()] to add the palette as well.
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' ggplot(od, aes(time, value, color = strain)) +
#'   geom_line() +
#'   labs(x = "Incubation time (hr)", y = "OD600", color = NULL) +
#'   journal_theme("nature")
journal_theme <- function(journal = "nature", base_family = "", markdown = FALSE) {
  spec <- journal_template(journal)
  size <- spec$text_pt
  small <- max(spec$min_text_pt, 0.8 * size)   # ticks, legend keys and strips
  line <- spec$line_pt / ggplot2::.pt          # ggplot2 gives line widths in mm

  theme <- ggplot2::theme_classic(base_size = size, base_family = base_family,
                                  base_line_size = line, base_rect_size = line) +
    ggplot2::theme(
      axis.text = ggplot2::element_text(size = small, colour = "black"),
      legend.text = ggplot2::element_text(size = small),
      strip.text = ggplot2::element_text(size = small, face = "bold"),
      strip.background = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(size = size, face = "bold", hjust = 0),
      plot.tag = ggplot2::element_text(size = spec$tag_pt, face = "bold"),
      legend.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      legend.key.size = ggplot2::unit(size / 2, "mm")
    )
  if (isTRUE(markdown)) as_md_theme(theme) else theme
}

#' The Colors of a Journal
#'
#' The palette that goes with a journal: the colors that `apply_journal()` uses.
#'
#' @inheritParams journal_templates
#' @param n How many colors. By default all the colors of the palette; a warning
#'   says if the palette has fewer than you ask for.
#' @return A character vector of colors, as `"#RRGGBB"`.
#' @seealso [compare_palettes()] to compare palettes, also for readers with
#'   color-vision deficiency.
#' @export
#' @examples
#' journal_colors("nature", 4)
#' journal_colors("science", 4)
journal_colors <- function(journal = "nature", n = NULL) {
  spec <- journal_template(journal)
  scale <- scale_color_set(spec$palette)
  size <- palette_size(scale)
  if (is.null(n)) n <- size
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 1) stop("`n` must be a number of colors, 1 or more.", call. = FALSE)
  if (n > size) {
    warning("The palette of ", spec$name, " has ", size, " colors, fewer than the ", n, " asked for.", call. = FALSE)
    n <- size
  }
  colors <- unname(scale$palette(n))
  colors <- colors[seq_len(min(n, length(colors)))]   # a fixed vector of colors ignores n
  farver::encode_colour(farver::decode_colour(colors))   # "#RRGGBB": some palettes add an alpha channel
}

#' Shades of One Color of a Journal
#'
#' A sequential ramp for groups that have an order, such as doses or stages:
#' `n` shades of one color of the palette of the journal, from a light tint to the
#' color itself. The colors of a categorical palette tell the reader that groups
#' differ, not which end is high.
#'
#' The shades are evenly spaced in the CIE Lab color space, so that each step
#' looks about as large as the next. The lightest shade is a tint of the color
#' with the share of white that `light` gives; take a smaller `light` if the
#' lightest group must be visible as a thin line on white paper.
#'
#' @inheritParams journal_templates
#' @param n How many shades.
#' @param color Which color of the palette to shade, by its position: 1 is the
#'   first color of [journal_colors()].
#' @param light The share of white in the lightest shade, from 0 up to but not
#'   including 1.
#' @return A character vector of `n` colors, as `"#RRGGBB"`, from the lightest to
#'   the darkest. The darkest is the color of the palette.
#' @seealso [journal_colors()] for groups without an order.
#' @export
#' @examples
#' journal_ramp("nature", 4)
#'
#' library(ggplot2)
#' doses <- data.frame(dose = factor(1:4), response = c(2, 3.5, 5.5, 8))
#' ggplot(doses, aes(dose, response, fill = dose)) +
#'   geom_col() +
#'   scale_fill_manual(values = journal_ramp("nature", 4), guide = "none") +
#'   journal_theme("nature")
journal_ramp <- function(journal = "nature", n = 5, color = 1, light = 0.75) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 1) stop("`n` must be a number of shades, 1 or more.", call. = FALSE)
  if (!is.numeric(light) || length(light) != 1L || is.na(light) || light < 0 || light >= 1) {
    stop("`light` must be a number from 0 up to, but not including, 1.", call. = FALSE)
  }
  palette <- journal_colors(journal)
  if (!is.numeric(color) || length(color) != 1L || is.na(color) || color < 1 || color > length(palette)) {
    stop("`color` must be a position from 1 to ", length(palette), ", the number of colors of the palette.", call. = FALSE)
  }
  base <- palette[color]
  if (n == 1) return(base)
  tint <- farver::encode_colour((1 - light) * farver::decode_colour(base) + light * 255, from = "rgb")
  shades <- grDevices::colorRampPalette(c(tint, base), space = "Lab")(n)
  shades[c(1L, n)] <- c(tint, base)   # the round trip through Lab can change the last digit of a channel
  shades
}

# How many colors a fixed palette has; 50 for a palette that interpolates
palette_size <- function(scale, limit = 50L) {
  size <- 0L
  for (k in seq_len(limit)) {
    colors <- tryCatch(suppressWarnings(scale$palette(k)), error = function(e) NULL)
    if (is.null(colors) || anyNA(colors)) break
    size <- k
  }
  size
}

#' Apply the Template of a Journal to a Plot
#'
#' Adds the theme of a journal, [journal_theme()], and its palette to a plot, as
#' `apply_theme_set()` does for a theme set.
#'
#' @inheritParams journal_templates
#' @param plot A ggplot object.
#' @param palette The name of a color scale set to use instead of the palette of
#'   the journal (see `list_color_scales()`), for example `"okabe_ito"`. `NA`
#'   keeps the colors of the plot and adds only the theme, which is what you want
#'   for a continuous color scale.
#' @param markdown Passed on to [journal_theme()]: `TRUE` renders markdown in the
#'   titles, the x axis title, the legend title and the strips.
#' @return A ggplot object.
#' @seealso [compare_journals()] to see one plot in several journals.
#' @export
#' @examples
#' library(ggplot2)
#' od <- subset(example_growth(), measure == "OD600")
#' p <- ggplot(od, aes(time, value, color = strain)) +
#'   geom_line() +
#'   labs(x = "Incubation time (hr)", y = "OD600", color = NULL)
#'
#' apply_journal(p, "science")
#'
#' # the same plot with the Okabe-Ito palette
#' apply_journal(p, "science", palette = "okabe_ito")
apply_journal <- function(plot, journal = "nature", palette = NULL, markdown = FALSE) {
  spec <- journal_template(journal)
  plot <- plot + journal_theme(spec, markdown = markdown)
  if (length(palette) == 1L && is.na(palette)) return(plot)
  palette <- if (is.null(palette)) spec$palette else palette
  plot + scale_color_set(palette) + scale_fill_set(palette)
}
