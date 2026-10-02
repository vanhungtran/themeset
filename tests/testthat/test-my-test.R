test_that("list helpers return names", {
  expect_true("simpsons" %in% list_theme_sets())
  expect_true("jama" %in% list_color_scales())
})

test_that("apply_theme_set returns a ggplot object", {
  od <- subset(example_growth(), measure == "OD600")
  plot <- ggplot2::ggplot(
    od,
    ggplot2::aes(x = time, y = value, color = strain)
  ) + ggplot2::geom_line()

  themed_plot <- apply_theme_set(plot, "simpsons")

  expect_s3_class(themed_plot, "ggplot")
})

test_that("custom themes and color scales are callable", {
  expect_s3_class(theme_nyt(), "theme")
  expect_s3_class(theme_midnight(), "theme")
  expect_s3_class(theme_royal(), "theme")
  expect_s3_class(theme_deepblue(), "theme")
  expect_s3_class(scale_color_jama(), "ScaleDiscrete")
})
