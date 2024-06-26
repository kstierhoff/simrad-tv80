# A script for viewing net mensuration data from the Simrad TV80 system 

# Install and load pacman (library management package)
if (!require("pacman")) install.packages("pacman")

# Install and load required packages from CRAN and Github ---------------------------
pacman::p_load(tidyverse, lubridate, fs, here, mapproj)
pacman::p_load_gh("SWFSC/atm")

# Plotting preferences
theme_set(theme_bw())

dat.files <- fs::dir_ls(here("data/TV80"), 
                        recurse = TRUE,
                        regexp = "*.measurements.csv")

hdr.files <- fs::dir_ls(here("data/TV80"), 
                        recurse = TRUE,
                        regexp = "*.header_names.csv")

# read_tv80_msg <- function(file) {
#   # Convert file to path to extract file name
#   file.name <- path_file(as_fs_path(file))
#   
#   # Read and format CSV file data
#   df <- readr::read_delim(file, delim = ";", name_repair = "minimal", lazy = FALSE) %>%
#     dplyr::select(which(!duplicated(names(.)))) %>%
#     dplyr::mutate(VES_Latitude = as.numeric(stringr::str_sub(VES_Latitude,1,2)) +
#              as.numeric(stringr::str_sub(VES_Latitude,4,11))/60,
#            VES_Longitude = as.numeric(stringr::str_sub(VES_Longitude,1,3)) +
#              as.numeric(stringr::str_sub(VES_Longitude,5,12))/60) %>%
#     dplyr::mutate_if(is.character, as.numeric) %>%
#     dplyr::mutate(datetime = lubridate::ymd_hms(DateTime),
#            file = file.name)
#   
#   return(df)
# }

# Extract data
dat <- atm::extract_tv80(file = dat.files[12])

dat.depth <- dat %>% 
  select(datetime, TWL_Depth, DOR_Depth_Prt, DOR_Depth_Std) %>% 
  pivot_longer(-datetime, names_to = "variable", values_to = "value")

# Plot door and trawl depths
ggplot() + 
  geom_line(data = dat.depth, aes(datetime, -value, colour = variable)) +
  scale_x_datetime() +
  scale_y_continuous(name = "Depth (m)") +
  scale_colour_manual(name = "Location", values = c(TWL_Depth = 'blue', DOR_Depth_Prt = 'red', DOR_Depth_Std = 'green')) +
  labs(x = "Time", title = paste("Start:", dat.depth$datetime[1], "UTC"))

# ggplot() + 
#   geom_line(data = dat, aes(datetime, -TWL_Depth), colour = "blue") +
#   geom_line(data = dat, aes(datetime, -DOR_Depth_Prt), colour = "red") +
#   geom_line(data = dat, aes(datetime, -DOR_Depth_Std), colour = "green") +
#   scale_y_continuous(name = "Depth (m)")

# Plot trawl path
ggplot(dat, aes(VES_Longitude, VES_Latitude, colour = VES_Speed)) + geom_point() + coord_map()

# Plot trawl geometry
ggplot() +
  geom_line(data = dat, aes(datetime, TWL_Geometry_Prt), colour = "red") +
  geom_line(data = dat, aes(datetime, TWL_Geometry_Std), colour = "blue")

# Plot door spread
ggplot() +
  geom_line(data = dat, aes(datetime, DOR_Spread), colour = "red")

