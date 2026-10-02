# --------------------------------------------------------------------------
# File: themeset/R/color_scales.R
# --------------------------------------------------------------------------
# Color scale sets: discrete palettes that are reached by name.
#
# Nothing here copies a palette. Every entry calls the scale function of the
# package that owns the palette, or asks that package for its colors.

# The discrete palettes of ggsci. Four more (bs5, gsea, material and tw3) are
# continuous, and the simpsons palette of ggsci would clash with the one from
# tvthemes.
ggsci_palettes <- c(
  "aaas", "atlassian", "bmj", "cosmic", "d3", "flatui", "frontiers", "futurama",
  "gephi", "igv", "iterm", "jama", "jco", "lancet", "locuszoom", "nejm", "npg",
  "observable", "primer", "rickandmorty", "startrek", "tron", "uchicago", "ucscgb"
)

# Suggested packages whose palettes are listed as `package::palette` when installed
optional_palette_packages <- c("wesanderson", "biopalette", "ggpalettes")

# An entry knows the package a palette comes from and how to build its scale for
# an aesthetic, "color" or "fill".
scale_entry <- function(package, make) list(package = package, make = make)

# A scale that is a fixed vector of colors
manual_scale <- function(aesthetic, values, ...) {
  switch(aesthetic,
    color = ggplot2::scale_color_manual(values = values, ...),
    fill = ggplot2::scale_fill_manual(values = values, ...)
  )
}

# The scale function `scale_<aesthetic>_<suffix>()` of a package, called with `...`
package_scale <- function(package, suffix) {
  force(package)
  force(suffix)   # the palettes are created in a loop: capture this one, not the last
  function(aesthetic, ...) getExportedValue(package, paste0("scale_", aesthetic, "_", suffix))(...)
}

builtin_color_scales <- function() {
  entries <- list(
    avatar = scale_entry("tvthemes", function(aesthetic, ...) {
      switch(aesthetic, color = scale_color_avatar(...), fill = scale_fill_avatar(...))
    }),
    simpsons = scale_entry("tvthemes", function(aesthetic, ...) {
      switch(aesthetic, color = scale_color_simpsons(...), fill = scale_fill_simpsons(...))
    }),
    olink = scale_entry("OlinkAnalyze", function(aesthetic, ...) {
      switch(aesthetic, color = scale_color_olink(...), fill = scale_fill_olink(...))
    }),
    fivethirtyeight = scale_entry("ggthemes", function(aesthetic, ...) {
      switch(aesthetic, color = scale_color_fivethirtyeight(...), fill = scale_fill_fivethirtyeight(...))
    })
  )
  for (palette in ggsci_palettes) {
    entries[[palette]] <- scale_entry("ggsci", package_scale("ggsci", palette))
  }
  # Flexoki names its tones after the colors: "dark" are the deep accents that
  # read well on paper, "light" the pale ones for a dark screen.
  flexoki_scale <- function(tones) {
    scale_entry("flexoki", function(aesthetic, ...) {
      getExportedValue("flexoki", paste0("scale_", aesthetic, "_flexoki_d"))(palette = tones, ...)
    })
  }
  entries$flexoki_light <- flexoki_scale("dark")
  entries$flexoki_dark <- flexoki_scale("light")
  entries
}

# The palettes of one suggested package, keyed as `package::palette`.
# The package must be installed.
optional_color_scales <- function(package) {
  entries <- list()
  add <- function(palette, make) entries[[paste0(package, "::", palette)]] <<- scale_entry(package, make)

  if (package == "wesanderson") {
    palettes <- names(wesanderson::wes_palettes)
    for (palette in palettes[!grepl("Continuous$", palettes)]) {
      local({
        palette <- palette
        add(palette, function(aesthetic, ...) {
          manual_scale(aesthetic, as.character(wesanderson::wes_palette(palette)), ...)
        })
      })
    }
  } else if (package == "biopalette") {
    # The qualitative palettes: the others are sequential or diverging
    for (palette in biopalette::list_palettes(type = "qualitative")$name) {
      local({
        palette <- palette
        add(palette, function(aesthetic, ...) {
          getExportedValue("biopalette", paste0("scale_", aesthetic, "_biopalette"))(palette = palette, ...)
        })
      })
    }
  } else if (package == "ggpalettes") {
    info <- ggpalettes::gg_palette_info()
    for (palette in info$name[info$type == "categorical"]) {
      add(palette, package_scale("ggpalettes", palette))
    }
  }
  entries
}

# All the sets that can be used now: the built-in ones and those of the suggested packages that are installed
available_color_scales <- function() {
  entries <- builtin_color_scales()
  for (package in optional_palette_packages) {
    if (requireNamespace(package, quietly = TRUE)) entries <- c(entries, optional_color_scales(package))
  }
  entries
}

# One set by name. A suggested package is only loaded when its own palette is asked for.
find_color_scale <- function(set) {
  if (!is.character(set) || length(set) != 1L || is.na(set)) {
    stop("`set` must be the name of one color scale set. Run list_color_scales() for the names.", call. = FALSE)
  }
  entries <- builtin_color_scales()
  if (set %in% names(entries)) return(entries[[set]])

  package <- sub("::.*$", "", set)
  if (grepl("::", set, fixed = TRUE) && package %in% optional_palette_packages) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop("The color scale set '", set, "' needs the ", package, " package. ",
           "Install it with install.packages(\"", package, "\").", call. = FALSE)
    }
    entries <- optional_color_scales(package)
    if (set %in% names(entries)) return(entries[[set]])
  }
  stop("Color scale set '", set, "' not found. Run list_color_scales() for available options.", call. = FALSE)
}

#' Color and Fill Scales by Name
#'
#' `scale_color_set()` and `scale_fill_set()` return a discrete color or fill
#' scale that is picked by name. One pair of functions thus reaches every
#' palette that `themeset` knows, and [list_color_scales()] shows the names.
#'
#' @section Names:
#' Most names are plain. They come from the packages that `themeset` imports:
#' the discrete palettes of ggsci, among them the journal palettes `npg`,
#' `aaas`, `nejm`, `lancet`, `jama`, `jco` and `bmj`; `avatar` and `simpsons`
#' from tvthemes; `olink` from OlinkAnalyze; `fivethirtyeight` from ggthemes;
#' and `flexoki_light` and `flexoki_dark`, the accent colors of the Flexoki
#' scheme for a light and for a dark background.
#'
#' The palettes of three more packages are listed as `package::palette`, for
#' example `"wesanderson::Darjeeling1"`, when the package is installed:
#' wesanderson, biopalette and ggpalettes. They are suggested packages, so
#' `themeset` works without them.
#'
#' Most palettes have a fixed number of colors and cannot color more levels
#' than that. `olink` and the palettes of ggpalettes interpolate instead, and
#' the flexoki sets repeat their eight colors.
#'
#' @section Credits:
#' The palettes belong to their authors; `themeset` only reaches them by name.
#' The names of the journal palettes tell where a palette took its inspiration.
#' `themeset` is not affiliated with any journal.
#'
#' @param set The name of a color scale set. Run [list_color_scales()] for the
#'   names.
#' @param ... Passed on to the scale, for example `name`, `breaks`, `labels` or
#'   `guide`.
#' @return A discrete `ggplot2` scale.
#' @seealso [theme_color_scales] for the scales with a function of their own.
#' @name color_scale_sets
#' @examples
#' library(ggplot2)
#' ggplot(example_taxa(), aes(taxon, abundance, fill = condition)) +
#'   geom_boxplot() +
#'   scale_fill_set("nejm")
#'
#' if (requireNamespace("wesanderson", quietly = TRUE)) {
#'   ggplot(example_taxa(), aes(taxon, abundance, fill = condition)) +
#'     geom_boxplot() +
#'     scale_fill_set("wesanderson::Darjeeling1")
#' }
NULL

#' @rdname color_scale_sets
#' @export
scale_color_set <- function(set, ...) { find_color_scale(set)$make("color", ...) }

#' @rdname color_scale_sets
#' @export
scale_fill_set <- function(set, ...) { find_color_scale(set)$make("fill", ...) }

#' List Available Color Scale Sets
#'
#' Prints the names of the color scale sets, grouped by the package that the
#' palettes come from. Use a name with [scale_color_set()] or
#' [scale_fill_set()].
#'
#' The palettes of the suggested packages wesanderson, biopalette and
#' ggpalettes appear, as `package::palette`, only when the package is installed.
#'
#' @param package Only list the sets from this package, for example `"ggsci"`.
#'   The default lists them all.
#' @return Invisibly, a character vector with the names.
#' @seealso [color_scale_sets]
#' @export
#' @examples
#' list_color_scales("ggsci")
list_color_scales <- function(package = NULL) {
  entries <- available_color_scales()
  sources <- vapply(entries, function(entry) entry$package, character(1))
  if (!is.null(package)) {
    entries <- entries[sources == package]
    sources <- sources[sources == package]
  }
  if (!length(entries)) {
    cat("No color scale sets from '", package, "'. Is the package installed?\n", sep = "")
    return(invisible(character()))
  }

  cat("Available color scale sets:\n")
  for (source in unique(sources)) {
    sets <- names(entries)[sources == source]
    # The palettes of a suggested package are used as `package::palette`: say so once
    prefix <- paste0(source, "::")
    line <- if (all(startsWith(sets, prefix))) {
      paste0(source, " (use as ", prefix, "<name>): ", paste(substring(sets, nchar(prefix) + 1L), collapse = ", "))
    } else {
      paste0(source, ": ", paste(sets, collapse = ", "))
    }
    writeLines(strwrap(line, width = getOption("width") - 2L, exdent = 4L))
  }
  invisible(names(entries))
}
