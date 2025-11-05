# ==========================================================
# 📦 Install & Load Required Packages
# ==========================================================
# install.packages(c("geodata", "sf", "ggplot2", "ggrepel", "dplyr"))

library(geodata)
library(sf)
library(ggplot2)
library(ggrepel)
library(dplyr)

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
  Latitude = 5.76412,    # Approximate coordinates for Amrahia
  Longitude = -0.13986
)

# Convert to spatial (sf) object
sites_sf <- st_as_sf(sites_df, coords = c("Longitude", "Latitude"), crs = 4326)

# ==========================================================
# 🗺️ 3. Filter for Greater Accra Region
# ==========================================================
accra_poly <- ghana_sf %>% filter(NAME_1 == "Greater Accra")

# ==========================================================
# 🎨 4. Plot Full Greater Accra Map (No Zoom Crop)
# ==========================================================
ggplot() +
  geom_sf(data = accra_poly, fill = "lightpink", color = "black") +
  geom_sf(data = sites_sf, color = "blue", size = 3) +
  geom_text_repel(
    data = st_drop_geometry(sites_sf),   # ✅ avoids the st_point_on_surface warning
    aes(x = st_coordinates(sites_sf)[,1],
        y = st_coordinates(sites_sf)[,2],
        label = Site_Name),
    size = 3.5,
    color = "black",
    fontface = "bold"
  ) +
  ggtitle("Greater Accra Region") +
  theme_minimal() +
  coord_sf() +   # ✅ shows full region, no cropping
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.title = element_blank()
  )
