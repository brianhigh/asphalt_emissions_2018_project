
# epa_asphalt_choropleth_2018.R
# Create a U.S. states choropleth (2018) for asphalt emissions using EPA Excel (Output - State)

# ---- Setup ----
if (!require("pacman")) install.packages("pacman", quiet = TRUE)
pacman::p_load(
  here, readxl, dplyr, stringr, ggplot2, usmap, scales
)

safe_main <- function() {
  tryCatch({
    # ---- Folders ----
    data_dir <- here::here("data")
    plots_dir <- here::here("plots")
    if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)
    if (!dir.exists(plots_dir)) dir.create(plots_dir, recursive = TRUE)

    # ---- Download (if needed) ----
    url <- "https://pasteur.epa.gov/uploads/10.23719/1531683/AP_2018_State_County_Inventory.xlsx"
    xlsx_path <- file.path(data_dir, "AP_2018_State_County_Inventory.xlsx")
    if (!file.exists(xlsx_path)) {
      message("Downloading EPA Excel to ", xlsx_path)
      utils::download.file(url, destfile = xlsx_path, mode = "wb", quiet = TRUE)
      message("✅ Download complete.")
    }

    # ---- Read data (quietly) ----
    emissions_raw <- suppressMessages(
      readxl::read_excel(
        xlsx_path,
        sheet = "Output - State",
        .name_repair = "unique_quiet"
      )
    )

    emissions_tbl <- emissions_raw |>
      dplyr::select(
        State = dplyr::any_of("State"),
        `Total kg/person` = dplyr::any_of("Total kg/person")
      ) |>
      dplyr::mutate(
        State = stringr::str_trim(State),
        values = suppressWarnings(as.numeric(`Total kg/person`))
      ) |>
      dplyr::filter(!is.na(State))

    cat("✅ Successfully read 'Output - State' sheet (State, Total kg/person).
")

    # ---- Validate state name matching (lowercase join check) ----
    map_states <- usmap::us_map(regions = "states")
    keys_map <- as.data.frame(map_states) |>
      dplyr::mutate(full_lower = stringr::str_to_lower(full)) |>
      dplyr::select(full_lower, abbr, fips)

    keys_data <- emissions_tbl |>
      dplyr::mutate(state_lower = stringr::str_to_lower(State)) |>
      dplyr::select(state_lower) |>
      dplyr::distinct()

    unmatched <- setdiff(keys_data$state_lower, keys_map$full_lower)
    if (length(unmatched) > 0) {
      warning("Found state names in data that did not match usmap 'full' names (lowercase): ",
              paste(unmatched, collapse = ", "))
    }

    # ---- Prepare data for plot_usmap ----
    df_for_plot <- emissions_tbl |>
      dplyr::transmute(
        state = State,
        values = values
      )

    # ---- Build map ----
    p <- usmap::plot_usmap(
      data = df_for_plot,
      values = "values",
      color = "grey60",
      linewidth = 0.25
    ) +
      ggplot2::scale_fill_gradientn(
        colours = c("#006400", "#FFD700", "#FF0000"),
        na.value = "#f0f0f0",
        name = "Total kg/person"
      ) +
      ggplot2::labs(
        title = "Asphalt-related emissions by U.S. state (2018)",
        subtitle = "Choropleth based on EPA State & County Inventory 'Output - State' sheet (Total kg/person).",
        caption = "Source: U.S. EPA, State & County Inventory (2018)."
      ) +
      ggplot2::theme_void() +
      ggplot2::theme(
        panel.background = ggplot2::element_rect(fill = "white", colour = NA),
        plot.background = ggplot2::element_rect(fill = "white", colour = NA),
        legend.position = "right",
        plot.title = ggplot2::element_text(face = "bold"),
        plot.caption.position = "plot",
        plot.caption = ggplot2::element_text(hjust = 0)
      )

    out_path <- file.path(plots_dir, "epa_asphalt_emissions_2018.png")
    ggplot2::ggsave(filename = out_path, plot = p, width = 10, height = 6, dpi = 300, bg = "white")
    message("✅ Map saved: ", out_path)

    invisible(TRUE)
  }, error = function(e) {
    message("❌ Error: ", conditionMessage(e))
    FALSE
  })
}

safe_main()
