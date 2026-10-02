# --------------------------------------------------------------------------
# File: themeset/R/set_registry.R
# --------------------------------------------------------------------------
# The theme sets. Each set is a function that builds it when it is asked for:
# building every set takes more than a second, and a call needs only one.

# The journal sets are the classic theme with a palette from ggsci. Their names
# are those of the ggsci palettes, which take their inspiration from journals;
# themeset is not affiliated with any journal.
journal_sets <- c("npg", "aaas", "nejm", "lancet", "jama", "jco", "bmj", "frontiers")

# A complete set: a theme and the scales of the color scale set `scales`
complete_set <- function(theme_fn, scales) {
  force(theme_fn)
  force(scales)   # the sets are created in a loop: capture this one, not the last
  function() {
    list(theme = theme_fn(), scale_color = scale_color_set(scales), scale_fill = scale_fill_set(scales))
  }
}

# A set that changes only the theme
theme_only_set <- function(theme_fn) {
  force(theme_fn)
  function() list(theme = theme_fn())
}

# The builders, in the order in which list_theme_sets() shows the sets:
# the complete sets first, then the ones that change only the theme.
theme_set_builders <- function() {
  builders <- list(
    simpsons = complete_set(md_theme_simpsons, "simpsons"),
    avatar = complete_set(md_theme_avatar, "avatar"),
    olink = complete_set(md_theme_olink, "olink"),
    fivethirtyeight = complete_set(md_theme_fivethirtyeight, "fivethirtyeight")
  )
  for (name in journal_sets) builders[[name]] <- complete_set(md_theme_classic, name)
  builders$flexoki_light <- complete_set(md_theme_flexoki_light, "flexoki_light")
  builders$flexoki_dark <- complete_set(md_theme_flexoki_dark, "flexoki_dark")

  theme_only <- list(
    nyt = theme_nyt, midnight = theme_midnight, royal = theme_royal, deepblue = theme_deepblue,
    bw = md_theme_bw, classic = md_theme_classic, dark = md_theme_dark, light = md_theme_light,
    linedraw = md_theme_linedraw, minimal = md_theme_minimal,
    base = md_theme_base, calc = md_theme_calc, clean = md_theme_clean,
    economist = md_theme_economist, economist_white = md_theme_economist_white,
    excel = md_theme_excel, excel_new = md_theme_excel_new, few = md_theme_few,
    foundation = md_theme_foundation, gdocs = md_theme_gdocs, hc = md_theme_hc,
    igray = md_theme_igray, map_gg = md_theme_map_gg, pander = md_theme_pander,
    par = md_theme_par, solarized = md_theme_solarized, solarized_2 = md_theme_solarized_2,
    solid = ggthemes::theme_solid, stata = md_theme_stata, tufte = md_theme_tufte,
    wsj = md_theme_wsj, ipsum = md_theme_ipsum, ipsum_rc = md_theme_ipsum_rc,
    cowplot = md_theme_cowplot, minimal_grid = md_theme_minimal_grid
  )
  for (name in names(theme_only)) builders[[name]] <- theme_only_set(theme_only[[name]])
  builders
}

# One set, built: a list with `theme` and, for the complete sets,
# `scale_color` and `scale_fill`.
build_theme_set <- function(set) {
  builders <- theme_set_builders()
  if (!is.character(set) || length(set) != 1L || !set %in% names(builders)) {
    stop("Set '", paste(set, collapse = ", "), "' not found. Run list_theme_sets() for available options.",
         call. = FALSE)
  }
  builders[[set]]()
}

# Every set, built. This is slow; it is meant for checking the registry as a whole.
get_theme_set_list <- function() {
  lapply(theme_set_builders(), function(build) build())
}
