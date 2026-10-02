test_that("markdown themes switch the text elements to markdown", {
  th <- md_theme_minimal()
  for (el in c("plot.title", "plot.subtitle", "plot.caption",
               "axis.title.x", "legend.title", "strip.text")) {
    expect_s3_class(th[[el]], "element_markdown")
  }
})

test_that("legend labels stay plain text, and can be switched to markdown", {
  th <- md_theme_minimal()
  expect_false(inherits(th$legend.text, "element_markdown"))

  on <- th + ggplot2::theme(legend.text = ggtext::element_markdown())
  expect_s3_class(ggplot2::calc_element("legend.text", on), "element_markdown")
})

test_that("a continuous color bar does not depend on the size of the canvas", {
  d <- data.frame(x = rep(1:3, 3), y = rep(1:3, each = 3), z = 1:9)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = z)) +
    ggplot2::geom_tile() +
    md_theme_minimal()

  legend_height <- function(canvas_mm) {
    grDevices::pdf(NULL, width = 89 / 25.4, height = canvas_mm / 25.4)
    on.exit(grDevices::dev.off())
    g <- ggplot2::ggplotGrob(p)
    legend <- g$grobs[[which(g$layout$name == "guide-box-right")]]
    sum(vapply(legend$heights, function(u) grid::convertHeight(u, "mm", valueOnly = TRUE), numeric(1)))
  }
  expect_equal(legend_height(60), legend_height(120), tolerance = 0.01)
})

test_that("rotated text stays plain", {
  th <- md_theme_minimal()

  expect_false(inherits(th$axis.title.y, "element_markdown"))
  expect_false(inherits(th$strip.text.y, "element_markdown"))
})

test_that("markdown themes keep the styling of the base theme", {
  base <- ggplot2::theme_gray()
  md <- md_theme_gray()

  expect_equal(md$plot.title$size, base$plot.title$size)
  expect_equal(md$plot.title$hjust, base$plot.title$hjust)
  expect_equal(md$plot.title$margin, base$plot.title$margin)
  expect_equal(md$axis.title.x$margin, base$axis.title.x$margin)
  expect_equal(md$axis.title.y$angle, base$axis.title.y$angle)
})

test_that("axis tick labels stay plain text", {
  th <- md_theme_bw()
  expect_false(inherits(th$axis.text, "element_markdown"))
  expect_false(inherits(th$axis.text.x, "element_markdown"))
  expect_false(inherits(th$axis.text.y, "element_markdown"))
})

test_that("tick labels can be switched to markdown for one plot", {
  th <- md_theme_minimal() +
    ggplot2::theme(axis.text.x.bottom = ggtext::element_markdown())

  expect_s3_class(
    ggplot2::calc_element("axis.text.x.bottom", th),
    "element_markdown"
  )
})

test_that("elements that a theme hides stay hidden", {
  base <- ggplot2::theme_gray() +
    ggplot2::theme(plot.title = ggplot2::element_blank())
  th <- as_md_theme(base)

  expect_s3_class(th$plot.title, "element_blank")
  expect_s3_class(th$plot.subtitle, "element_markdown")
})

test_that("elements hidden through a blank parent stay hidden", {
  # theme_map() blanks axis.title; axis.title.x only inherits that
  th <- md_theme_map_gg()

  expect_s3_class(ggplot2::calc_element("axis.title.x", th), "element_blank")
  expect_s3_class(ggplot2::calc_element("axis.title.y", th), "element_blank")
})

test_that("elements that a theme leaves unset become markdown too", {
  # theme_economist() does not set plot.subtitle; it inherits from `title`
  th <- md_theme_economist()

  expect_null(ggthemes::theme_economist()$plot.subtitle)
  expect_s3_class(th$plot.subtitle, "element_markdown")
})

test_that("all_plain controls the font face", {
  base <- ggplot2::theme_gray() +
    ggplot2::theme(plot.title = ggplot2::element_text(face = "bold"))

  expect_equal(as_md_theme(base)$plot.title$face, "plain")
  expect_equal(as_md_theme(base, all_plain = FALSE)$plot.title$face, "bold")
})

test_that("markdown in titles and axis titles draws", {
  od <- subset(example_growth(), measure == "OD600")
  p <- ggplot2::ggplot(od, ggplot2::aes(time, value)) +
    ggplot2::geom_point() +
    ggplot2::labs(
      title = "**Bold** and *italic*",
      x = "log<sub>10</sub> time (hr<sup>2</sup>)"
    ) +
    md_theme_minimal()

  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  expect_no_error(print(p))
})

test_that("tick labels with markdown characters still draw", {
  d <- data.frame(x = c("<LOD>", "***", "1."), y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    md_theme_minimal()

  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  expect_no_error(print(p))
})
