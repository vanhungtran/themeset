test_that("example_growth() has the documented shape", {
  growth <- example_growth()

  expect_s3_class(growth, "data.frame")
  expect_equal(nrow(growth), 144)
  expect_named(growth, c("time", "strain", "measure", "value", "se"))
  expect_equal(nlevels(growth$strain), 6)
  expect_equal(
    levels(growth$measure),
    c("Product A (uM)", "Product B (uM)", "Substrate (mM)", "OD600")
  )
  expect_equal(sort(unique(growth$time)), c(0, 5, 19, 26, 44, 67))
  expect_false(anyNA(growth))
})

test_that("example_taxa() has the documented shape", {
  taxa <- example_taxa()

  expect_s3_class(taxa, "data.frame")
  expect_equal(nrow(taxa), 120)
  expect_named(taxa, c("taxon", "condition", "abundance"))
  expect_equal(nlevels(taxa$taxon), 5)
  expect_equal(levels(taxa$condition), c("Control", "Diet A", "Diet B"))
  expect_true(all(table(taxa$taxon, taxa$condition) == 8))
  expect_true(all(taxa$abundance >= 0))
  expect_false(anyNA(taxa))
})

test_that("the example data are the same on every call", {
  expect_identical(example_growth(), example_growth())
  expect_identical(example_taxa(), example_taxa())
})

test_that("the example data leave the random number stream alone", {
  set.seed(1)
  expected <- runif(1)

  set.seed(1)
  invisible(example_taxa())
  invisible(example_growth())

  expect_equal(runif(1), expected)
})

test_that("the example data show the effects they are meant to show", {
  taxa <- example_taxa()
  means <- tapply(taxa$abundance, list(taxa$taxon, taxa$condition), mean)

  # Diet A more than doubles Proteobacteria, Diet B halves Clostridium
  expect_gt(means["Proteobacteria", "Diet A"], 1.5 * means["Proteobacteria", "Control"])
  expect_lt(means["Clostridium", "Diet B"], 0.75 * means["Clostridium", "Control"])

  # The uninoculated control makes no product
  growth <- example_growth()
  product <- subset(growth, measure == "Product A (uM)" & strain == "No bacteria")
  expect_true(all(product$value == 0))
})
