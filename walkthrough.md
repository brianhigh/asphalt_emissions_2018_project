
# Walkthrough

1. **Run the script**
   ```r
   source("scripts/epa_asphalt_choropleth_2018.R")
   ```
2. **Folders auto-create**: The script ensures `data/` and `plots/` exist.
3. **Data download**: If the Excel isn’t present, it is downloaded **in binary mode** to `data/`.
4. **Read & clean**:
   - Sheet: **Output - State**.
   - Columns: `State` and `Total kg/person`.
   - Numeric conversion uses `suppressWarnings(as.numeric(...))`.
   - A success message is printed after reading.
5. **Key alignment**:
   - Retrieve `usmap::us_map("states")` (sf).
   - Lower-case both sets of names and flag any mismatches.
6. **Plot**:
   - Base map via `plot_usmap(...)` — includes **Alaska & Hawaii** by default.
   - Add a vivid gradient (**dark green → yellow → red**) with `scale_fill_gradientn()`.
   - Borders are **grey**; background **white**; axes are removed.
   - Title includes **(2018)**, with descriptive subtitle and data-source caption.
7. **Save**: PNG written to `plots/epa_asphalt_emissions_2018.png`.
