# A line plot of the simulated growth data, colored by strain
od600 <- function() subset(example_growth(), measure == "OD600")

line_plot <- function() {
  ggplot2::ggplot(od600(), ggplot2::aes(time, value, color = strain)) +
    ggplot2::geom_line() +
    ggplot2::labs(x = "Incubation time (hr)", y = "OD600", color = NULL)
}

# The final OD600 of each strain as bars
bar_plot <- function(data = subset(od600(), time == max(time))) {
  ggplot2::ggplot(data, ggplot2::aes(strain, value, fill = strain)) +
    ggplot2::geom_col() +
    ggplot2::labs(x = NULL, y = "Final OD600", fill = NULL)
}

# A plot with everything that a journal does not allow
broken_plot <- function() {
  od <- od600()
  ggplot2::ggplot(od, ggplot2::aes(time, value, color = strain)) +
    ggplot2::geom_line(linewidth = 0.05) +
    ggplot2::geom_text(data = od[1, ], ggplot2::aes(label = "start"), size = 1, color = "black") +
    ggplot2::labs(x = "Incubation time (hr)", y = "OD600", color = NULL, tag = "A") +
    ggplot2::theme_classic(base_size = 4)
}

test_that("journal_fix() repairs a plot until journal_check() passes", {
  p <- broken_plot()
  expect_equal(attr(journal_check(p, "nature"), "overall"), "fail")

  fixed <- journal_fix(p, "nature")
  expect_s3_class(fixed, "ggplot")
  check <- attr(fixed, "check")
  expect_s3_class(check, "journal_check")
  expect_equal(attr(check, "overall"), "pass")
  expect_equal(attr(journal_check(fixed, "nature"), "overall"), "pass")

  fixes <- attr(fixed, "fixes")
  expect_named(fixes, c("round", "panel", "check", "target", "before", "after"))
  expect_true(all(c("text", "lines", "tags", "colors") %in% fixes$check))
  expect_true("layer 2 (GeomText)" %in% fixes$target)
  expect_equal(fixed$labels$tag, "a")

  # the original plot is not changed: layers are environments
  expect_equal(p$layers[[1]]$aes_params$linewidth, 0.05)
  expect_equal(p$layers[[2]]$aes_params$size, 1)
})

test_that("journal_fix() changes no more than it must", {
  fixed <- journal_fix(broken_plot(), "nature", fix = "text")
  fixes <- attr(fixed, "fixes")
  expect_true(all(fixes$check == "text"))
  # raised to the smallest size of the journal, no further
  expect_true(all(fixes$after == "5.0 pt"))
  expect_equal(fixed$labels$tag, "A")

  # a plot that passes is returned as it is
  good <- apply_journal(line_plot(), "nature", palette = "okabe_ito")
  same <- journal_fix(good, "nature")
  expect_equal(nrow(attr(same, "fixes")), 0L)
  expect_message(journal_fix(good, "nature", quiet = FALSE), "Nothing to change")
})

test_that("journal_fix() lowers text above the largest size and leaves mapped widths alone", {
  big <- line_plot() + ggplot2::theme_classic(base_size = 14)
  fixed <- journal_fix(big, "nature", fix = "text")
  sizes <- themeset:::text_sizes(fixed)
  expect_lte(max(sizes), 7 + 1e-6)

  mapped <- ggplot2::ggplot(od600(), ggplot2::aes(time, value, color = strain, linewidth = strain)) +
    ggplot2::geom_line() +
    ggplot2::scale_linewidth_manual(values = seq(0.01, 0.06, length.out = 6))
  result <- journal_fix(mapped, "nature", fix = "lines")
  expect_true(any(grepl("mapped", attr(result, "fixes")$after)))
})

test_that("journal_fix() keeps new colors only when they are easier to tell apart", {
  # two reds and two blues that are hard to tell apart
  close <- line_plot() +
    ggplot2::scale_color_manual(values = c("#E64B35", "#E8553F", "#4DBBD5", "#56B4E9", "#00A087", "#3C5488")) +
    journal_theme("nature")
  fixed <- journal_fix(close, "nature", fix = "colors")
  fixes <- attr(fixed, "fixes")
  expect_equal(fixes$check, "colors")
  before <- as.numeric(fixes$before)
  after <- as.numeric(sub(" .*$", "", fixes$after))
  expect_gt(after, before)

  # with nine groups Okabe-Ito has too few colors: nothing changes
  nine <- data.frame(x = 1:9, y = 1:9, g = letters[1:9])
  many <- ggplot2::ggplot(nine, ggplot2::aes(x, y, color = g)) +
    ggplot2::geom_point() +
    ggplot2::scale_color_manual(values = rep(c("#E64B35", "#E8553F", "#4DBBD5"), 3))
  expect_equal(nrow(attr(journal_fix(many, "nature", fix = "colors"), "fixes")), 0L)
})

test_that("journal_fix() repairs each panel of a list", {
  panels <- list(broken_plot(), broken_plot() + ggplot2::labs(tag = "b"))
  fixed <- journal_fix(panels, "science")
  expect_type(fixed, "list")
  expect_length(fixed, 2L)
  expect_equal(c(fixed[[1]]$labels$tag, fixed[[2]]$labels$tag), c("A", "B"))
  expect_setequal(attr(fixed, "fixes")$panel, 1:2)
  expect_equal(attr(attr(fixed, "check"), "overall"), "pass")

  expect_error(journal_fix("not a plot"), "ggplot")
  expect_error(journal_fix(line_plot(), rounds = 0), "rounds")
})

test_that("match_style() takes the theme and the colors of the groups of a reference", {
  reference <- apply_journal(line_plot(), "nature")
  wanted <- themeset:::group_colors(reference)

  last <- subset(od600(), time == max(time))
  some <- subset(last, strain %in% unique(last$strain)[c(2, 4)])
  some <- rbind(some, transform(some[1, ], strain = "Strain X"))
  p <- bar_plot(some) + ggplot2::scale_fill_discrete("Strain")
  styled <- match_style(p, reference)

  got <- themeset:::group_colors(styled)
  shared <- intersect(got$group, wanted$group)
  expect_length(shared, 2L)
  expect_equal(got$color[match(shared, got$group)], wanted$color[match(shared, wanted$group)])
  # a new group gets a color that no group of the reference has
  expect_false(got$color[got$group == "Strain X"] %in% wanted$color)
  # the name of the scale is kept
  expect_equal(styled$scales$get_scales("fill")$name, "Strain")
  # and the theme is the one of the reference
  expect_equal(ggplot2::calc_element("axis.text.x", styled$theme)$size,
               ggplot2::calc_element("axis.text.x", reference$theme)$size)

  colors_only <- match_style(p, reference, theme = FALSE)
  expect_null(colors_only$theme$axis.text)
  theme_only <- match_style(p, reference, colors = FALSE)
  expect_equal(theme_only$scales$get_scales("fill")$name, "Strain")
  expect_false(inherits(theme_only$scales$get_scales("fill"), "ScaleDiscreteIdentity"))

  expect_error(match_style(p, "nature"), "ggplot")
})

test_that("journal_audit() finds groups with different colors in two figures", {
  figures <- list(
    "Figure 1" = apply_journal(line_plot(), "nature"),
    "Figure 2" = apply_journal(bar_plot(), "nature", palette = "okabe_ito")
  )
  audit <- journal_audit(figures, "nature")
  expect_s3_class(audit, "journal_audit")
  expect_named(audit, c("figure", "check", "status", "value", "limit", "note"))
  row <- audit[audit$check == "group colors", ]
  expect_equal(row$status, "warn")
  expect_match(row$note, "Strain A")
  expect_output(print(audit), "Audit of 2 figure")

  colors <- attr(audit, "colors")
  expect_named(colors, c("figure", "aesthetic", "group", "color"))
  # a fill scale that was added with nothing mapped to it has no groups
  expect_false(any(colors$figure == "Figure 1" & colors$aesthetic == "fill"))

  figures[["Figure 2"]] <- match_style(figures[["Figure 2"]], figures[["Figure 1"]])
  matched <- journal_audit(figures, "nature")
  expect_equal(matched$status[matched$check == "group colors"], "pass")
})

test_that("journal_audit() compares the text and the font of the figures", {
  figures <- list(apply_journal(line_plot(), "nature"),
                  list(apply_journal(bar_plot(), "nature"), line_plot() + ggplot2::theme_bw(base_size = 9)))
  audit <- journal_audit(figures, "nature", column = c("single", "double"))
  expect_true(all(c("Figure 1", "Figure 2", "all") %in% audit$figure))
  expect_equal(audit$status[audit$check == "tick labels"], "warn")
  expect_equal(audit$status[audit$check == "font family"], "pass")
  expect_equal(attr(audit, "overall"), "fail")   # 11 pt titles are too large for Nature

  expect_error(journal_audit(line_plot()), "list of figures")
  expect_error(journal_audit(list(line_plot(), "x")), "Figure 2")
  expect_error(journal_audit(list(line_plot(), line_plot()), column = c("single", "double", "single")), "column")
})
