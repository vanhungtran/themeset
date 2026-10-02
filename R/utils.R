# --------------------------------------------------------------------------
# File: themeset/R/utils.R
# --------------------------------------------------------------------------
# The markdown-enabling helper function. Not exported.

# Text elements that are switched to markdown rendering: titles and captions,
# axis titles, legends and facet strips. Children such as `axis.title.x` are
# listed because ggplot2 draws the child, so a markdown parent alone is not
# enough. Axis tick labels (`axis.text*`) stay plain: they come from the data,
# and labels such as "<LOD>" or "***" would fail to parse as markdown. Elements
# that the theme rotates are skipped too (see as_md_theme()).
md_text_elements <- c(
  "plot.title", "plot.subtitle", "plot.caption",
  "axis.title", "axis.title.x", "axis.title.x.top", "axis.title.x.bottom",
  "axis.title.y", "axis.title.y.left", "axis.title.y.right",
  "legend.title", "legend.text",
  "strip.text", "strip.text.x", "strip.text.x.top", "strip.text.x.bottom",
  "strip.text.y", "strip.text.y.left", "strip.text.y.right"
)

# The elements of the list above whose parent in ggplot2's element tree is not
# in the list (it is plain `title` or `text`).
md_root_elements <- c(
  "plot.title", "plot.subtitle", "plot.caption", "axis.title",
  "legend.title", "legend.text", "strip.text"
)

# Parent of each child element in ggplot2's element tree. Walking this small
# tree is much cheaper than calling ggplot2::calc_element() for every element.
md_parents <- c(
  axis.title.x = "axis.title", axis.title.x.top = "axis.title.x",
  axis.title.x.bottom = "axis.title.x",
  axis.title.y = "axis.title", axis.title.y.left = "axis.title.y",
  axis.title.y.right = "axis.title.y",
  strip.text.x = "strip.text", strip.text.x.top = "strip.text.x",
  strip.text.x.bottom = "strip.text.x",
  strip.text.y = "strip.text", strip.text.y.left = "strip.text.y",
  strip.text.y.right = "strip.text.y"
)

# TRUE if the theme hides this element, either directly or because it inherits
# blank from a blank parent (as theme_map() does for the axis titles).
md_is_blank <- function(theme, name) {
  el <- theme[[name]]
  if (inherits(el, "element_blank")) return(TRUE)
  if (!is.null(el) && !isTRUE(el$inherit.blank)) return(FALSE)
  parent <- md_parents[name]
  if (is.na(parent)) return(FALSE)
  md_is_blank(theme, unname(parent))
}

as_md_theme <- function(theme, all_plain = TRUE) {
  # Load required libraries if not already loaded
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Please install ggplot2")
  if (!requireNamespace("ggtext", quietly = TRUE)) stop("Please install ggtext")

  # Switch each existing text element to markdown rendering and keep the styling
  # the theme gave it (size, alignment, margins, color, ...). Elements that are
  # blank or unset are skipped, so a theme that hides a title still hides it.
  overrides <- list()
  for (name in md_text_elements) {
    old <- theme[[name]]
    if (inherits(old, c("element_markdown", "element_blank"))) next
    if (md_is_blank(theme, name)) next
    if (is.null(old)) {
      # Unset elements inherit from their parent. Only the top-level ones need
      # an element of their own, because their parent is plain text.
      if (name %in% md_root_elements) {
        overrides[[name]] <- ggtext::element_markdown(
          face = if (all_plain) "plain",
          inherit.blank = TRUE
        )
      }
    } else if (inherits(old, "element_text")) {
      # Rotated text (y axis titles, row strips) stays plain: ggtext drops the
      # spaces of rotated text at low resolution on the standard png devices.
      if (!is.null(old$angle) && old$angle %% 360 != 0) next
      emd <- ggtext::element_markdown(
        face = if (all_plain) "plain",
        inherit.blank = isTRUE(old$inherit.blank)
      )
      overrides[[name]] <- ggplot2::merge_element(emd, old)
    }
  }

  # Use %+replace% to force the override of text elements
  theme %+replace% do.call(ggplot2::theme, overrides)
}


num2col <- function(x,
                    pal = c("blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red"),
                    ref = range(x, na.rm = TRUE),
                    breaks = NULL,
                    NAcol = "#B9BBB6") {

  # Create a color ramp function from the palette
  ramp <- grDevices::colorRamp(pal)

  # Determine the scale based on breaks or the reference range
  if (is.null(breaks)) {
    min_ref <- min(ref, na.rm = TRUE)
    max_ref <- max(ref, na.rm = TRUE)
    # Avoid division by zero if the range is a single number
    if (min_ref == max_ref) max_ref <- min_ref + 1
    # Scale values from 0 to 1 based on the reference range
    x_scaled <- (x - min_ref) / (max_ref - min_ref)
  } else {
    # Use findInterval to map values to breaks
    x_scaled <- findInterval(x, breaks, rightmost.closed = TRUE) / (length(breaks) - 1)
  }

  # Clamp scaled values between 0 and 1
  x_scaled[x_scaled < 0 | is.na(x_scaled)] <- -1 # Use -1 to later identify NAs and out-of-bounds
  x_scaled[x_scaled > 1] <- -1

  # Initialize the color vector with the NA color
  cols <- rep(NAcol, length(x))

  # Identify valid, non-NA values to color
  valid_indices <- x_scaled != -1

  # Apply the color ramp to the valid scaled values
  if (any(valid_indices)) {
    cols[valid_indices] <- grDevices::rgb(ramp(x_scaled[valid_indices]), maxColorValue = 255)
  }

  return(cols)
}



# ==============================================================================
# R Package Installation and Loading Function (with GitHub Search)
# ==============================================================================

#' Install and Load R Packages from Multiple Sources
#'
#' This function iterates through a vector of package names. If a package is
#' not installed, it attempts to install it from CRAN, then Bioconductor. If
#' still not found, it will search GitHub for a repository with that name and
#' prompt the user to interactively select from the top results for installation.
#'
#' @param packages A character vector or list of package names.
#'   To install directly from GitHub without searching, use the 'username/reponame' format.
#'
#' @return Loads the requested packages into the current session. Prints status
#'   messages and continues processing even if one package fails.
#'
#' @examples
#' # packages <- c("ggplot2", "limma", "tidyverse/dplyr", "hrbrthemes")
#' # install_and_load(packages)
install_and_load <- function(packages) {

  # Loop through each package in the provided vector/list
  for (pkg in packages) {
    message(paste("\n--- Processing package:", pkg, "---"))

    actual_name <- basename(pkg)

    # 1. Check if the package is already installed and load it
    if (requireNamespace(actual_name, quietly = TRUE)) {
      message(paste("\U2705 Package '", actual_name, "' is already installed. Loading now.", sep = ""))
      library(actual_name, character.only = TRUE)
      next # Skip to the next package in the loop
    }

    message(paste("-> Package '", actual_name, "' not found. Attempting installation...", sep = ""))
    is_remote <- grepl("/", pkg)

    if (is_remote) {
      # Direct installation from GitHub/GitLab
      tryCatch({
        if (!requireNamespace("remotes", quietly = TRUE)) {
          message("--> Installing 'remotes' to handle remote installation...")
          utils::install.packages("remotes", quiet = TRUE, repos = "https://cran.rstudio.com/")
        }
        message(paste("--> Installing '", pkg, "' from remote source...", sep = ""))
        remotes::install_github(pkg, quiet = TRUE)
      }, error = function(e) {
        warning(paste("--> Remote installation failed for '", pkg, "'.", sep = ""))
      })

    } else {
      # Installation from repositories (CRAN, Bioconductor, then search GitHub)
      # 2a. Try CRAN
      tryCatch({
        message(paste("--> Attempt 1/3: Installing '", pkg, "' from CRAN...", sep = ""))
        utils::install.packages(pkg, quiet = TRUE, repos = "https://cran.rstudio.com/")
      }, error = function(e) {})

      # 2b. Try Bioconductor if not found on CRAN
      if (!requireNamespace(pkg, quietly = TRUE)) {
        tryCatch({
          message(paste("--> Attempt 2/3: Installing '", pkg, "' from Bioconductor...", sep = ""))
          if (!requireNamespace("BiocManager", quietly = TRUE)) {
            utils::install.packages("BiocManager", quiet = TRUE, repos = "https://cran.rstudio.com/")
          }
          # Suppress updates to avoid lengthy builds during script run
          BiocManager::install(pkg, ask = FALSE, update = FALSE)
        }, error = function(e) {})
      }

      # 2c. Search GitHub if not found on CRAN or Bioconductor
      if (!requireNamespace(pkg, quietly = TRUE)) {
        message(paste("--> Attempt 3/3: Searching for '", pkg, "' on GitHub...", sep = ""))
        tryCatch({
          # Ensure 'gh' package is installed for API access
          if (!requireNamespace("gh", quietly = TRUE)) {
            message("--> Installing 'gh' package to search GitHub API...")
            utils::install.packages("gh", quiet = TRUE, repos = "https://cran.rstudio.com/")
          }

          # Search GitHub repositories, sorted by stars
          search_query <- paste0(pkg, " in:name language:R")
          results <- gh::gh("/search/repositories", q = search_query, per_page = 5, sort = "stars", order = "desc")

          if (results$total_count > 0) {
            repos <- sapply(results$items, function(item) item$full_name)
            choice_msg <- paste("Found repositories for '", pkg, "'. Please choose one to install:", sep="")

            # Use menu() for interactive selection in the console
            choice <- utils::menu(c(repos, "None of the above"), title = choice_msg)

            if (choice > 0 && choice <= length(repos)) {
              chosen_repo <- repos[choice]
              message(paste("--> User selected:", chosen_repo))

              if (!requireNamespace("remotes", quietly = TRUE)) {
                utils::install.packages("remotes", quiet = TRUE, repos = "https://cran.rstudio.com/")
              }
              remotes::install_github(chosen_repo, quiet = TRUE)
            } else {
              message("--> No package selected. Skipping GitHub installation.")
            }
          } else {
            message("--> No R packages found on GitHub matching that name.")
          }
        }, error = function(e) {
          warning(paste("--> GitHub search failed. Error:", e$message))
        })
      }
    }

    # --- Final Loading Attempt ---
    if (requireNamespace(actual_name, quietly = TRUE)) {
      message(paste("\U2705 Successfully installed and loaded '", actual_name, "'.", sep = ""))
      library(actual_name, character.only = TRUE)
    } else {
      warning(paste("\U274C Failed to install package '", actual_name, "' from any source.", sep = ""))
    }
  } # End of for loop
}


