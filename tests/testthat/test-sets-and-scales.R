quiet <- function(code) {
  utils::capture.output(result <- withVisible(code))
  result$value
}

complete_sets <- c(
  "simpsons", "avatar", "olink", "fivethirtyeight",
  "npg", "aaas", "nejm", "lancet", "jama", "jco", "bmj", "frontiers",
  "flexoki_light", "flexoki_dark"
)

test_that("every theme set can be built", {
  sets <- quiet(list_theme_sets())
  expect_gt(length(sets), length(complete_sets))
  expect_false(anyDuplicated(sets) > 0)
  for (set in sets) {
    expect_s3_class(themeset:::build_theme_set(set)$theme, "theme")
  }
})

test_that("the complete sets come first and bring both scales", {
  sets <- quiet(list_theme_sets())
  expect_equal(sets[seq_along(complete_sets)], complete_sets)
  for (set in complete_sets) {
    built <- themeset:::build_theme_set(set)
    expect_s3_class(built$scale_color, "ScaleDiscrete")
    expect_s3_class(built$scale_fill, "ScaleDiscrete")
  }
  for (set in setdiff(sets, complete_sets)) {
    expect_null(themeset:::build_theme_set(set)$scale_color)
  }
})

test_that("a journal set applies its theme, color scale and fill scale", {
  p <- ggplot2::ggplot(
    example_taxa(),
    ggplot2::aes(taxon, abundance, color = condition, fill = condition)
  ) + ggplot2::geom_boxplot()
  themed <- apply_theme_set(p, "nejm")

  expect_true(themed$scales$has_scale("colour"))
  expect_true(themed$scales$has_scale("fill"))
  expect_equal(themed$scales$get_scales("fill")$palette(3), scale_fill_set("nejm")$palette(3))
})

test_that("unknown sets are reported with the way to list them", {
  expect_error(apply_theme_set(ggplot2::ggplot(), "nope"), "not found")
  expect_error(set_global_theme("nope"), "list_theme_sets")
  expect_error(scale_color_set("nope"), "list_color_scales")
  expect_error(scale_color_set(c("nejm", "lancet")), "one color scale set")
})

test_that("scale_color_set() and scale_fill_set() return the palette that is named", {
  expect_s3_class(scale_color_set("lancet"), "ScaleDiscrete")
  expect_s3_class(scale_fill_set("lancet"), "ScaleDiscrete")
  expect_false(identical(scale_color_set("nejm")$palette(4), scale_color_set("lancet")$palette(4)))

  # the same colors as the scales that have a function of their own
  expect_equal(scale_color_set("jama")$palette(7), scale_color_jama()$palette(7))
  expect_equal(scale_fill_set("avatar")$palette(5), scale_fill_avatar()$palette(5))

  # arguments reach the scale
  expect_equal(scale_color_set("nejm", name = "Group")$name, "Group")
})

test_that("every ggsci palette of the list is a discrete scale", {
  for (palette in themeset:::ggsci_palettes) {
    expect_s3_class(scale_color_set(palette), "ScaleDiscrete")
  }
})

test_that("the two flexoki sets take the tones that suit their background", {
  expect_equal(
    scale_color_set("flexoki_light")$palette(4),
    flexoki::scale_color_flexoki_d(palette = "dark")$palette(4)
  )
  expect_equal(
    scale_color_set("flexoki_dark")$palette(4),
    flexoki::scale_color_flexoki_d(palette = "light")$palette(4)
  )
})

test_that("list_color_scales() names the sets, and can be limited to one package", {
  all_sets <- quiet(list_color_scales())
  expect_true(all(c("nejm", "lancet", "flexoki_dark", "olink", "jama") %in% all_sets))

  expect_output(list_color_scales("ggsci"), "ggsci:")
  ggsci_sets <- quiet(list_color_scales("ggsci"))
  expect_true("nejm" %in% ggsci_sets)
  expect_false("olink" %in% ggsci_sets)

  expect_output(list_color_scales("nothing"), "No color scale sets")
})

test_that("the palettes of wesanderson are reached as package::palette", {
  skip_if_not_installed("wesanderson")
  expect_true("wesanderson::Darjeeling1" %in% quiet(list_color_scales()))
  expect_equal(
    scale_color_set("wesanderson::Darjeeling1")$palette(5),
    as.character(wesanderson::wes_palette("Darjeeling1"))
  )
  # a fixed palette cannot color more levels than it has
  expect_error(scale_color_set("wesanderson::Darjeeling1")$palette(7), "Insufficient")
  expect_error(scale_color_set("wesanderson::NoSuchPalette"), "not found")
})

test_that("the palettes of biopalette and ggpalettes are reached as package::palette", {
  skip_if_not_installed("biopalette")
  skip_if_not_installed("ggpalettes")
  all_sets <- quiet(list_color_scales())
  expect_true(all(c("biopalette::cancer_mosaic", "ggpalettes::clinical") %in% all_sets))

  bio <- scale_fill_set("biopalette::cancer_mosaic")
  expect_s3_class(bio, "ScaleDiscrete")
  expect_length(bio$palette(5), 5)

  gg <- scale_color_set("ggpalettes::clinical")
  expect_s3_class(gg, "ScaleDiscrete")
  expect_length(gg$palette(5), 5)
})

test_that("global theme sets store the first colors of the palette", {
  on.exit(suppressMessages(reset_global_theme()), add = TRUE)
  suppressMessages(set_global_theme("nejm"))
  expect_length(getOption("ggplot2.discrete.colour"), 3)
  suppressMessages(reset_global_theme())
  expect_null(getOption("ggplot2.discrete.colour"))
})

test_that("dark themes draw default geoms in a light color", {
  skip_if_not("element_geom" %in% getNamespaceExports("ggplot2"), "needs ggplot2 4.0 or later")
  lightness <- function(theme) {
    mean(grDevices::col2rgb(ggplot2::calc_element("geom", theme)$ink)) / 255
  }
  dark_themes <- list(
    midnight = theme_midnight(),
    royal = theme_royal(),
    deepblue = theme_deepblue(),
    flexoki_dark = themeset:::build_theme_set("flexoki_dark")$theme
  )
  for (name in names(dark_themes)) {
    expect_gt(lightness(dark_themes[[name]]), 0.5)
  }
  expect_lt(lightness(theme_nyt()), 0.5)

  # the point of a layer without a color mapping is light too
  points <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    theme_midnight()
  drawn <- ggplot2::layer_data(points)$colour
  expect_gt(mean(grDevices::col2rgb(drawn[1])) / 255, 0.5)
})
