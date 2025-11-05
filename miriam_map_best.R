# ==========================================================
# 📦 Install & Load Required Packages
# ==========================================================
# install.packages(c("geodata", "sf", "ggplot2", "ggrepel", "dplyr", "patchwork"))

library(geodata)
library(sf)
library(ggplot2)
library(ggrepel)
library(dplyr)
library(patchwork)

# ==========================================================
# 🌍 1. Load Ghana Regional Boundaries (GADM Level 1)
# ==========================================================
ghana_regions <- geodata::gadm(country = "GHA", level = 1, path = tempdir())
ghana_sf <- st_as_sf(ghana_regions)

# ==========================================================
# 🏥 2. Define Site — St. John of God Hospital, Amrahia
# ==========================================================
sites_df <- data.frame(
  Site_Name = "St. John of God Hospital, Amrahia",
  Region = "Greater Accra",
  Latitude = 5.7719476,    # Approximate coordinates for Amrahia
  Longitude = -0.1406256
)

# Convert to spatial (sf) object
sites_sf <- st_as_sf(sites_df, coords = c("Longitude", "Latitude"), crs = 4326)

# ==========================================================
# 🗺️ 3. Filter for Greater Accra Region
# ==========================================================
accra_poly <- ghana_sf %>% filter(NAME_1 == "Greater Accra")

# ==========================================================
# 🌍 4. Map of Ghana (Accra Highlighted)
# ==========================================================
ghana_map <- ggplot() +
  geom_sf(data = ghana_sf, fill = "gray90", color = "black") +
  geom_sf(data = accra_poly, fill = "lightpink", color = "black") +
  ggtitle("Project Site (Ghana Overview)") +
  coord_sf(
    xlim = c(-3.5, 1.5), ylim = c(4.5, 11.5),
    expand = FALSE, 
    default_crs = sf::st_crs(4326)
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray85", size = 0.3, linetype = "dotted"),  # 👈 faint grid lines
    panel.background = element_rect(fill = "white"),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.title = element_blank(),
    axis.text = element_text(size = 8, color = "gray50"),  # faint lat/lon labels
    axis.ticks = element_blank()
  )

# ==========================================================
# 🏙️ 5. Zoomed-in Greater Accra Map (with Hospital)
# ==========================================================
accra_map <- ggplot() +
  geom_sf(data = accra_poly, fill = "lightpink", color = "black") +
  geom_sf(data = sites_sf, color = "blue", size = 3) +
  geom_text_repel(
    data = st_drop_geometry(sites_sf),
    aes(x = st_coordinates(sites_sf)[, 1],
        y = st_coordinates(sites_sf)[, 2],
        label = Site_Name),
    size = 3.5,
    color = "black",
    fontface = "bold"
  ) +
  ggtitle("Greater Accra Region — Site Location") +
  coord_sf(
    expand = FALSE,
    default_crs = sf::st_crs(4326)
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray85", size = 0.3, linetype = "dotted"),  # 👈 faint lat/lon grid lines
    panel.background = element_rect(fill = "white"),
    plot.title = element_text(hjust = 0.5, size = 13, face = "bold"),
    axis.title = element_blank(),
    axis.text = element_text(size = 8, color = "gray50"),
    axis.ticks = element_blank()
  )

# ==========================================================
# 🧩 6. Combine Both Maps (Using patchwork)
# ==========================================================
ghana_map + accra_map + plot_layout(ncol = 2, widths = c(1, 1.2))
