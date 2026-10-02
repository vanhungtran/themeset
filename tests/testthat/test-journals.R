quiet <- function(code) {
  utils::capture.output(result <- withVisible(code))
  result$value
}

# A small line plot of the simulated growth data, with a color legend
growth_plot <- function() {
  od <- subset(example_growth(), measure == "OD600")
  ggplot2::ggplot(od, ggplot2::aes(time, value, color = strain)) +
    ggplot2::geom_line() +
    ggplot2::labs(x = "Incubation time (hr)", y = "OD600", color = NULL)
}

# The colors as "#RRGGBB", whatever the palette returns
hex <- function(x) unname(farver::encode_colour(farver::decode_colour(x)))

# The size in pixels of a png, from its header
png_size <- function(file) {
  bytes <- as.integer(readBin(file, "raw", 24))
  c(width = sum(bytes[17:20] * 256^(3:0)), height = sum(bytes[21:24] * 256^(3:0)))
}

test_that("the journal registry is complete and consistent", {
  reg <- journal_templates()
  expect_s3_class(reg, "data.frame")
  expect_false(anyDuplicated(reg$journal) > 0)
  expect_true(all(c("nature", "natcomms", "science", "cell", "pnas", "plos", "elsevier") %in% reg$journal))

  # every palette is a color scale set that can be built
  for (palette in unique(reg$palette)) {
    expect_s3_class(scale_color_set(palette), "ScaleDiscrete")
  }

  # the numbers of the journals that give sizes hang together
  sized <- reg[reg$sizes, ]
  expect_gte(nrow(sized), 5)
  expect_true(all(sized$min_text_pt <= sized$text_pt))
  expect_true(all(sized$text_pt <= sized$max_text_pt, na.rm = TRUE))
  expect_true(all(sized$tag_pt >= sized$text_pt))
  expect_false(anyNA(sized$double_mm))
  widths <- as.matrix(sized[, c("single_mm", "onehalf_mm", "double_mm")])
  expect_true(all(apply(widths, 1L, function(w) !is.unsorted(w[!is.na(w)]))))
  expect_true(all(sized$tag %in% c("lower", "upper")))
  expect_true(all(startsWith(sized$guide, "https://")))

  # the others have nothing but a palette
  expect_true(all(is.na(reg$double_mm[!reg$sizes])))
})

test_that("journal_template() returns a template that can be changed", {
  nature <- journal_template("nature")
  expect_s3_class(nature, "journal_template")
  expect_equal(nature$single_mm, 89)
  expect_equal(nature$text_pt, 7)
  expect_equal(nature$tag, "lower")
  expect_output(print(nature), "Nature")

  smaller <- journal_template("nature", text_pt = 6)
  expect_equal(smaller$text_pt, 6)
  expect_equal(smaller$single_mm, 89)
  expect_equal(journal_template(smaller)$text_pt, 6)   # a template stands for its id

  mine <- journal_template("my_journal", single_mm = 80, double_mm = 165, palette = "npg")
  expect_equal(mine$name, "my_journal")
  expect_true(mine$sizes)
  expect_equal(journal_width(mine, "single"), 80)
  expect_equal(mine$text_pt, 7)   # the generic value, since none was given

  expect_error(journal_template("nope"), "not found")
  expect_error(journal_template("nature", colour = "red"), "Unknown field")
  expect_error(journal_template("nature", tag = "title"), "lower")
  expect_error(journal_template(c("nature", "cell")), "one journal")
})

test_that("a journal that gives no sizes falls back on generic values", {
  nejm <- journal_template("nejm")
  expect_false(nejm$sizes)
  expect_equal(nejm$text_pt, 7)
  expect_equal(nejm$tag_pt, 8)
  expect_equal(nejm$tag, "upper")
  expect_equal(nejm$palette, "nejm")
  expect_equal(journal_width("nejm", "single"), 85)
  expect_equal(journal_width("nejm", "double"), 174)
})

test_that("journal_width() gives the column, or the nearest one that the journal has", {
  expect_equal(journal_width("nature", "single"), 89)
  expect_equal(journal_width("nature", "double"), 183)
  expect_equal(journal_width("science", "onehalf"), 121)
  expect_equal(journal_width("nature", "onehalf"), 183)   # a tie: the larger column
  expect_equal(journal_width("plos", "single"), 190.5)
  expect_equal(journal_width("nature", 70), 70)
  expect_error(journal_width("nature", "triple"))
})

test_that("journal_tags() prints the case of the journal", {
  expect_equal(journal_tags("nature", 3), c("a", "b", "c"))
  expect_equal(journal_tags("science", 3), c("A", "B", "C"))
  expect_length(journal_tags("cell"), 26)
  expect_error(journal_tags("nature", 27), "from 1 to 26")
})

test_that("journal_theme() sets the text and the lines of the journal", {
  th <- journal_theme("nature")
  expect_s3_class(th, "theme")
  size <- function(element, theme = th) ggplot2::calc_element(element, theme)$size
  expect_equal(size("text"), 7)
  expect_equal(size("axis.title.x"), 7)
  expect_equal(size("axis.text.x"), 5.6)
  expect_equal(size("legend.text"), 5.6)
  expect_equal(size("plot.tag"), 8)
  expect_equal(ggplot2::calc_element("axis.line.x", th)$linewidth * ggplot2::.pt, 0.75)

  # the smallest size of the journal is a floor for the text of the axes
  expect_equal(size("axis.text.x", journal_theme("plos")), 8)

  # a template of your own
  expect_equal(size("text", journal_theme(journal_template("nature", text_pt = 6))), 6)
})

test_that("journal_theme() is plain text unless markdown is asked for", {
  expect_false(inherits(journal_theme("nature")$plot.title, "element_markdown"))

  md <- journal_theme("nature", markdown = TRUE)
  expect_s3_class(md$plot.title, "element_markdown")
  expect_equal(md$plot.title$size, 7)
})

test_that("journal_colors() returns plain hex colors, as many as asked for", {
  for (journal in c("nature", "science", "cell", "nejm")) {
    colors <- journal_colors(journal, 4)
    expect_length(colors, 4)
    expect_match(colors, "^#[0-9A-F]{6}$")
  }
  expect_false(identical(journal_colors("nature", 4), journal_colors("science", 4)))
  expect_equal(journal_colors("cell", 3), journal_colors("plos", 3))   # both use Okabe-Ito

  # the colors come from ggsci and base R, they are not copied
  expect_equal(journal_colors("nature", 3), hex(ggsci::pal_npg()(3)))
  expect_equal(journal_colors("cell", 8), hex(grDevices::palette.colors(9, "Okabe-Ito")[c(2:8, 1)]))

  # a fixed palette gives no more than it has, and says so
  expect_length(journal_colors("cell"), 8)
  expect_warning(more <- journal_colors("cell", 20), "fewer")
  expect_length(more, 8)
  expect_error(journal_colors("cell", 0), "number of colors")
})

test_that("journal_ramp() gives shades of one color, from light to dark", {
  ramp <- journal_ramp("nature", 5)
  expect_length(ramp, 5)
  expect_match(ramp, "^#[0-9A-F]{6}$")
  expect_equal(ramp[5], journal_colors("nature", 1))

  # lighter at the start, darker at the end, one step after another
  lightness <- farver::convert_colour(farver::decode_colour(ramp), "rgb", "lab")[, "l"]
  expect_true(all(diff(lightness) < 0))
  steps <- diff(lightness)
  expect_lt(max(steps) - min(steps), 0.5)   # the steps are even

  expect_equal(journal_ramp("nature", 1), journal_colors("nature", 1))
  expect_equal(journal_ramp("cell", 3, color = 2)[3], journal_colors("cell", 2)[2])
  expect_equal(journal_ramp("cell", 3, light = 0)[1], journal_colors("cell", 1)[1])

  expect_error(journal_ramp("nature", 3, color = 11), "from 1 to")
  expect_error(journal_ramp("nature", 0), "number of shades")
  expect_error(journal_ramp("nature", 3, light = 1), "light")
})

test_that("apply_journal() adds the theme and the palette of the journal", {
  d <- data.frame(x = 1:6, y = 1:6, g = rep(c("a", "b", "c"), 2))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, color = g, fill = g)) + ggplot2::geom_point()
  drawn <- function(plot) hex(unique(ggplot2::ggplot_build(plot)$data[[1]]$colour))

  nature <- apply_journal(p, "nature")
  expect_s3_class(nature, "ggplot")
  expect_true(nature$scales$has_scale("colour"))
  expect_true(nature$scales$has_scale("fill"))
  expect_equal(drawn(nature), journal_colors("nature", 3))
  expect_equal(ggplot2::calc_element("text", nature$theme)$size, 7)

  expect_equal(drawn(apply_journal(p, "cell")), journal_colors("cell", 3))

  # another palette than the one of the journal
  expect_equal(drawn(apply_journal(p, "nature", palette = "okabe_ito")), journal_colors("cell", 3))

  # NA keeps the colors of the plot, which a continuous scale needs
  expect_false(apply_journal(p, "nature", palette = NA)$scales$has_scale("colour"))

  # a template of your own
  own <- journal_template("nature", text_pt = 6, palette = "lancet")
  expect_equal(ggplot2::calc_element("text", apply_journal(p, own)$theme)$size, 6)
  expect_equal(drawn(apply_journal(p, own)), hex(ggsci::pal_lancet()(3)))
})

test_that("compare_journals() draws a page to scale", {
  p <- growth_plot()

  sheet <- compare_journals(p, c("nature", "science"))
  expect_s3_class(sheet, "ggplot")
  # two columns side by side: 4 + 89 + 6 + 57 + 4 wide; a caption and a copy high
  expect_equal(attr(sheet, "size_mm"), c(width = 160, height = 83.75))

  stacked <- compare_journals(p, c("nature", "science"), ncol = 1)
  expect_equal(attr(stacked, "size_mm"), c(width = 97, height = 141.5))

  # a row that is full goes on to the next one
  expect_equal(attr(compare_journals(p, c("nature", "science"), sheet_mm = 100), "size_mm"),
               attr(stacked, "size_mm"))

  # a title takes room
  titled <- compare_journals(p, c("nature", "science"), title = "A title")
  expect_equal(unname(attr(titled, "size_mm")["height"]), 83.75 + 8)

  # one template, and a mix of ids and templates
  expect_equal(attr(compare_journals(p, journal_template("nature", text_pt = 6)), "size_mm"),
               c(width = 97, height = 83.75))
  mixed <- compare_journals(p, list(journal_template("nature", text_pt = 6), "science"))
  expect_equal(unname(attr(mixed, "size_mm")["width"]), 160)

  # the page draws
  grDevices::pdf(NULL, width = 160 / 25.4, height = 83.75 / 25.4)
  on.exit(grDevices::dev.off())
  expect_no_error(print(sheet))

  expect_error(compare_journals("not a plot"), "ggplot")
})

test_that("compare_journals() gives a function the template with the size of the copy", {
  p <- growth_plot()
  seen <- list()
  make <- function(spec) {
    seen[[spec$journal]] <<- c(spec$width_mm, spec$height_mm)
    p
  }
  compare_journals(make, c("nature", "science"), column = "double", height = 50)
  expect_equal(seen$nature, c(183, 50))
  expect_equal(seen$science, c(184, 50))

  compare_journals(make, c("nature", "science"), column = 80, aspect = 0.5)
  expect_equal(seen$nature, c(80, 40))
})

test_that("compare_journals() copes with a figure of several panels", {
  panels <- function(spec) {
    a <- apply_journal(growth_plot(), spec) + ggplot2::labs(tag = journal_tags(spec, 2)[1])
    b <- apply_journal(growth_plot(), spec) + ggplot2::labs(tag = journal_tags(spec, 2)[2])
    cowplot::plot_grid(a, b, ncol = 2)
  }
  sheet <- compare_journals(panels, c("nature", "science"), column = "double", ncol = 1)
  grDevices::pdf(NULL, width = 6, height = 6)
  on.exit(grDevices::dev.off())
  expect_no_error(print(sheet))
})

test_that("a color bar keeps its size in a journal figure", {
  d <- data.frame(x = rep(1:3, 3), y = rep(1:3, each = 3), z = 1:9)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = z)) + ggplot2::geom_tile()
  legend_height <- function(canvas_mm) {
    grDevices::pdf(NULL, width = 89 / 25.4, height = canvas_mm / 25.4)
    on.exit(grDevices::dev.off())
    g <- ggplot2::ggplotGrob(apply_journal(p, "nature", palette = NA))
    legend <- g$grobs[[which(g$layout$name == "guide-box-right")]]
    sum(vapply(legend$heights, function(u) grid::convertHeight(u, "mm", valueOnly = TRUE), numeric(1)))
  }
  expect_equal(legend_height(60), legend_height(120), tolerance = 0.01)
})

test_that("min_color_distance() is small for close colors and large for far ones", {
  distance <- themeset:::min_color_distance
  expect_lt(distance(c("#FF0000", "#FF0101")), 1)
  expect_equal(distance(c("#000000", "#FFFFFF")), 100, tolerance = 0.01)
  expect_true(is.na(distance("#FF0000")))

  skip_if_not_installed("colorspace")
  # red and green are far apart, but not for a reader with deuteranopia
  expect_lt(distance(c("#FF0000", "#00FF00"), "deutan"), distance(c("#FF0000", "#00FF00"), "normal"))
})

test_that("compare_palettes() compares the colors of the palettes", {
  skip_if_not_installed("colorspace")
  out <- compare_palettes(c("npg", "okabe_ito"), n = 5)
  expect_named(out, c("set", "n", "normal", "deutan", "protan", "tritan", "worst", "confusable"))
  expect_equal(out$set, c("npg", "okabe_ito"))
  expect_equal(out$n, c(5, 5))
  expect_equal(out$worst, pmin(out$normal, out$deutan, out$protan, out$tritan))
  expect_equal(out$confusable, out$worst < 10)

  # a palette with fewer colors than n is compared as it is
  expect_equal(compare_palettes("okabe_ito", n = 20)$n, 8)

  # the threshold decides what counts as confusable
  expect_false(any(compare_palettes(c("npg", "okabe_ito"), n = 5, threshold = 0)$confusable))

  # by default, the palettes of the journals
  expect_setequal(compare_palettes()$set, unique(journal_templates()$palette))
})

test_that("journal_check() fails text that is too large and passes the journal theme", {
  p <- growth_plot()

  default <- journal_check(p, "nature")
  expect_s3_class(default, "journal_check")
  expect_equal(default$status[default$check == "largest text"], "fail")
  expect_equal(attr(default, "overall"), "fail")

  themed <- journal_check(apply_journal(p, "nature"), "nature", height = 60)
  expect_equal(themed$status[themed$check == "smallest text"], "pass")
  expect_equal(themed$status[themed$check == "largest text"], "pass")
  expect_equal(themed$status[themed$check == "thinnest line"], "pass")
  expect_equal(themed$status[themed$check == "height"], "pass")
  expect_equal(themed$value[themed$check == "width"], "89 mm")

  # a journal with a large floor for the text
  plos <- journal_check(apply_journal(p, "plos"), "plos")
  expect_equal(plos$status[plos$check == "smallest text"], "pass")
  small <- journal_check(p + ggplot2::theme(axis.text = ggplot2::element_text(size = 6)), "plos")
  expect_equal(small$status[small$check == "smallest text"], "fail")
})

test_that("journal_check() looks at the height, the lines, the tags and the text layers", {
  p <- apply_journal(growth_plot(), "nature")
  status <- function(chk, check) chk$status[chk$check == check]

  expect_equal(status(journal_check(p, "nature", height = 200), "height"), "fail")
  expect_equal(status(journal_check(p, "nature"), "height"), "info")

  thin <- p + ggplot2::theme(axis.line = ggplot2::element_line(linewidth = 0.05))
  chk <- journal_check(thin, "nature")
  expect_equal(status(chk, "thinnest line"), "fail")
  expect_equal(chk$note[chk$check == "thinnest line"], "axis.line.x")

  expect_equal(status(journal_check(p + ggplot2::labs(tag = "A"), "nature"), "panel tags"), "warn")
  expect_equal(status(journal_check(p + ggplot2::labs(tag = "a"), "nature"), "panel tags"), "pass")
  expect_equal(status(journal_check(p + ggplot2::labs(tag = "A"), "science"), "panel tags"), "pass")
  expect_length(status(journal_check(p, "nature"), "panel tags"), 0)

  small <- p + ggplot2::geom_text(ggplot2::aes(label = strain), size = 1)
  chk <- journal_check(small, "nature")
  expect_equal(status(chk, "smallest text"), "fail")
  expect_equal(chk$note[chk$check == "smallest text"], "text layer")
})

test_that("journal_check() warns about colors that are hard to tell apart", {
  skip_if_not_installed("colorspace")
  d <- data.frame(x = 1:2, y = 1:2, g = c("a", "b"))
  two <- function(colors) {
    ggplot2::ggplot(d, ggplot2::aes(x, y, color = g)) +
      ggplot2::geom_point() +
      ggplot2::scale_color_manual(values = colors)
  }
  close <- journal_check(two(c("#1B9E77", "#1B9E78")), "nature")
  expect_equal(close$status[close$check == "colors"], "warn")
  expect_match(close$note[close$check == "colors"], "okabe_ito")

  far <- journal_check(two(c("#E69F00", "#0072B2")), "nature")
  expect_equal(far$status[far$check == "colors"], "pass")

  # greys carry no hue and are left out, so a single color has nothing to be compared with
  grey <- journal_check(two(c("#444444", "#E69F00")), "nature")
  expect_equal(grey$status[grey$check == "colors"], "info")
})

test_that("journal_check() takes a list of panels, and prints a table", {
  p <- apply_journal(growth_plot(), "nature")
  big <- p + ggplot2::theme(text = ggplot2::element_text(size = 12))
  chk <- journal_check(list(p, big), "nature")
  expect_equal(chk$status[chk$check == "largest text"], "fail")
  expect_equal(chk$value[chk$check == "largest text"], "12.0 pt")

  expect_output(print(chk), "Check against Nature: fail")
  expect_output(print(chk), "largest text +fail +12.0 pt")
  # a table that was cut down is still printed
  expect_output(print(chk[, c("check", "status")]), "largest text")

  expect_error(journal_check("not a plot"), "ggplot")
  expect_error(journal_check(list(p, "not a plot")), "ggplot")
})

test_that("journal_check() warns about a figure that was assembled from panels", {
  p <- apply_journal(growth_plot(), "nature")
  assembled <- cowplot::plot_grid(p, p, ncol = 2)
  expect_warning(journal_check(assembled, "nature"), "panels as a list")
  expect_no_warning(journal_check(list(p, p), "nature"))
})

test_that("device_opens() tells a device that opens from one that does not", {
  before <- grDevices::dev.list()
  expect_true(themeset:::device_opens(grDevices::pdf))
  # opens nothing: what cairo_pdf() does on a macOS without XQuartz, although capabilities("cairo") is TRUE
  expect_false(themeset:::device_opens(function(file) invisible(NULL)))
  expect_false(themeset:::device_opens(function(file) stop("no such device")))
  expect_equal(grDevices::dev.list(), before)
})

test_that("save_journal_figure() saves at the size of the column", {
  p <- apply_journal(growth_plot(), "nature")

  png <- tempfile(fileext = ".png")
  on.exit(unlink(png), add = TRUE)
  save_journal_figure(p, png, journal = "nature", column = "single", dpi = 100)
  expect_equal(unname(png_size(png)), c(350, 263), tolerance = 0.01)   # 89 x 66.75 mm

  png2 <- tempfile(fileext = ".png")
  on.exit(unlink(png2), add = TRUE)
  save_journal_figure(p, png2, journal = "science", column = "onehalf", height = 50, dpi = 100)
  expect_equal(unname(png_size(png2)), c(476, 197), tolerance = 0.01)   # 121 x 50 mm

  pdf <- tempfile(fileext = ".pdf")
  on.exit(unlink(pdf), add = TRUE)
  save_journal_figure(p, pdf, journal = "nature", column = "double")
  expect_gt(file.size(pdf), 0)
})

test_that("save_journal_figure() warns about a height that the journal does not allow", {
  p <- growth_plot()
  png <- tempfile(fileext = ".png")
  on.exit(unlink(png), add = TRUE)
  expect_warning(save_journal_figure(p, png, journal = "nature", height = 200, dpi = 30), "allows")
  expect_no_warning(save_journal_figure(p, png, journal = "nejm", height = 200, dpi = 30))
})

test_that("save_journal_figure() saves a page of compare_journals() at its own size", {
  sheet <- compare_journals(growth_plot(), c("nature", "science"))
  png <- tempfile(fileext = ".png")
  on.exit(unlink(png), add = TRUE)
  save_journal_figure(sheet, png, dpi = 50)
  expect_equal(unname(png_size(png)), c(315, 165), tolerance = 0.01)   # 160 x 83.75 mm

  expect_error(save_journal_figure(growth_plot(), png), "journal")
})
