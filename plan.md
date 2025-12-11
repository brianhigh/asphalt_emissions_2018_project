
# Implementation Plan

1. **Scaffold project**: Create `scripts/`, `data/`, and `plots/` folders.
2. **R dependencies**: Load libraries using `pacman::p_load()` — `here`, `readxl`, `dplyr`, `stringr`, `ggplot2`, `usmap`, `sf`, `scales`.
3. **Data acquisition**: Conditionally download the EPA Excel to `data/` with `download.file(..., mode = "wb")`.
4. **Reading data**:
   - Read sheet **“Output - State”** with `read_excel(..., .name_repair = "unique_quiet")`.
   - Extract `State` and `Total kg/person`.
   - Convert the values to numeric (suppress conversion warnings).
5. **Key alignment**:
   - Retrieve map states via `usmap::us_map("states")` (sf).
   - Normalize state names to **lower case** on both sides and check unmatched entries.
6. **Mapping**:
   - Use `plot_usmap(data=..., values="values", color="grey60", linewidth=0.25)`.
   - Add ggplot layers: `scale_fill_gradientn()` (dark green → yellow → red), titles, subtitle, caption.
   - Remove axes, keep **white background**.
7. **Export**: Save to `plots/epa_asphalt_emissions_2018.png`.
8. **Docs**: Write `README.md`, `tasks.md`, `walkthrough.md`, `.gitignore`, and archive the original prompt as `prompt.md`.
9. **QA**: Verify folder creation, successful read and success message, proper join (no/limited mismatches), color differentiation, and Alaska/Hawaii visibility.
