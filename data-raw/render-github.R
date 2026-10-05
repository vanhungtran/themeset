# Renders what GitHub cannot show by itself.
#
# GitHub displays .Rmd files as source only, so the figures of the README and of the
# articles are not visible there. This script writes the versions that GitHub does show:
#
#   articles/*.md           the vignettes as GitHub Markdown, figures in articles/*_files/
#   articles/README.md      an index of them
#   man/figures/multi-panel.png   the figure that the README shows
#   README.md               knitted from README.Rmd, figures in man/figures/
#
# The package website, built by CI with pkgdown, stays the main home of the articles.
# Run this again, from the package root, after a vignette or the README changes:
#
#   source("data-raw/render-github.R")

stopifnot(file.exists("DESCRIPTION"), dir.exists("vignettes"), file.exists("README.Rmd"))
for (pkg in c("rmarkdown", "pkgload", "ragg")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Install the ", pkg, " package first.", call. = FALSE)
}

# Keep the knit free of font downloads: OlinkAnalyze can otherwise try to register a web font
options(OlinkAnalyze.allow.font.load = FALSE)

# The articles call library(themeset), which finds this copy of the package
pkgload::load_all(".", quiet = TRUE)

articles <- c("themeset", "theme-sets-and-scales", "markdown-themes",
              "global-and-custom-themes", "multi-panel-figure", "journal-figures",
              "figure-gallery", "showcase", "figure-set", "reporting-study")
dir.create("articles", showWarnings = FALSE)

# The files are committed, so write the same line endings on every system
write_lf <- function(text, path) {
  con <- file(path, "wb")
  on.exit(close(con))
  writeLines(text, con, sep = "\n", useBytes = TRUE)
}

for (name in articles) {
  # no figures left over from chunks that no longer exist
  unlink(file.path("articles", paste0(name, "_files")), recursive = TRUE)

  md <- rmarkdown::render(
    file.path("vignettes", paste0(name, ".Rmd")),
    output_format = rmarkdown::github_document(
      html_preview = FALSE, toc = TRUE, toc_depth = 3, dev = "ragg_png",
      pandoc_args = "--eol=lf"
    ),
    output_file = paste0(name, ".md"),
    output_dir = "articles",
    intermediates_dir = "articles",
    knit_root_dir = normalizePath("vignettes"),
    quiet = TRUE,
    envir = new.env(parent = globalenv())
  )

  text <- paste(readLines(md, encoding = "UTF-8"), collapse = "\n")

  # rmarkdown writes the figure links as absolute paths: make them relative to articles/
  text <- gsub(sprintf("[^\"()]*/articles/(?=%s_files/)", name), "", text, perl = TRUE)

  # A figure with a caption is written as a <div> with a paragraph that GitHub does not
  # close properly: use the image, then the caption in italics
  text <- gsub(
    "(?s)<div class=\"figure\">\n\n(<img [^\n]*/>)\n<p class=\"caption\">\n\n(.*?)\n</p>\n\n</div>",
    "\\1\n\n_\\2_", text, perl = TRUE
  )

  # Links between the articles point to the .html pages of the website;
  # on GitHub they should open the Markdown copies
  text <- gsub(sprintf("\\]\\((%s)\\.html\\)", paste(articles, collapse = "|")), "](\\1.md)", text)

  # Never commit a path from this machine
  if (grepl("(?<![A-Za-z])[A-Za-z]:/[^/]|[\"(]/(home|Users|tmp|var|private)/", text, perl = TRUE)) {
    stop("articles/", name, ".md still contains an absolute path", call. = FALSE)
  }
  write_lf(text, md)
  message("rendered articles/", name, ".md")
}

# The figure that the README shows
dir.create(file.path("man", "figures"), recursive = TRUE, showWarnings = FALSE)
file.copy(file.path("articles", "multi-panel-figure_files", "figure-gfm", "print-1.png"),
          file.path("man", "figures", "multi-panel.png"), overwrite = TRUE)

# An index, which GitHub shows under the file list of the folder
titles <- vapply(articles, function(name) {
  rmarkdown::yaml_front_matter(file.path("vignettes", paste0(name, ".Rmd")))$title
}, character(1))
write_lf(c(
  "# Articles",
  "",
  "The articles of the package, rendered with their figures for reading on GitHub.",
  "They are the vignettes in `vignettes/`; the package website,",
  "<https://vanhungtran.github.io/themeset/>, has the same articles.",
  "",
  sprintf("- [%s](%s.md)", titles, articles),
  "",
  "These files are written by `data-raw/render-github.R`; edit the vignettes, not these files."
), file.path("articles", "README.md"))

rmarkdown::render(
  "README.Rmd",
  output_format = rmarkdown::github_document(html_preview = FALSE, pandoc_args = "--eol=lf"),
  quiet = TRUE,
  envir = new.env(parent = globalenv())
)
message("rendered README.md")
