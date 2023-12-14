# A script for viewing net mensuration data from the Simrad TV80 system 

# Install and load pacman (library management package)
if (!require("pacman")) install.packages("pacman")

# Install and load required packages from CRAN ---------------------------------
pacman::p_load(tidyverse, lubridate, fs, here, mapproj)
theme_set(theme_bw())

dat.files <- fs::dir_ls(here("data/TV80"), 
                        recurse = TRUE,
                        regexp = "*.measurements.csv")

hdr.files <- fs::dir_ls(here("data/TV80"), 
                        recurse = TRUE,
                        regexp = "*.header_names.csv")

# dat.tmp <- read.table(dat.files[5], header = TRUE, sep = ";") %>% 
#   mutate(datetime = ymd_hms(DateTime))

dat.tmp <- read_delim(dat.files[12], delim = ";", name_repair = "minimal") 

dat <- dat.tmp[, which(!duplicated(names(dat.tmp)))] %>% 
  mutate(datetime = ymd_hms(DateTime)) %>% 
  mutate(lat = as.numeric(str_sub(VES_Latitude,1,2)) +
           as.numeric(str_sub(VES_Latitude,4,11))/60,
         long = as.numeric(str_sub(VES_Longitude,1,3)) +
           as.numeric(str_sub(VES_Longitude,5,12))/60)

ggplot() + 
  geom_line(data = dat, aes(datetime, -as.numeric(TWL_Depth)), colour = "blue") +
  geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Prt)), colour = "red") +
  geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Std)), colour = "green") +
  scale_y_continuous(name = "Depth (m)", limits = c(-400,0))

# ggplot(dat, aes(long, lat, colour = VES_Speed)) + geom_point() + coord_map()
# 
# ggplot() + 
#   # geom_line(data = dat, aes(datetime, -as.numeric(TWL_Depth))) +
#   # geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Prt)), colour = "red") +
#   geom_line(data = dat, aes(datetime, as.numeric(TWL_Geometry_Prt)), colour = "red") +
#   geom_line(data = dat, aes(datetime, as.numeric(TWL_Geometry_Std)), colour = "blue")
# 
# ggplot() + 
#   # geom_line(data = dat, aes(datetime, -as.numeric(TWL_Depth))) +
#   # geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Prt)), colour = "red") +
#   geom_histogram(data = dat, aes(as.numeric(TWL_Geometry_Prt)), fill = "red") +
#   geom_histogram(data = dat, aes(as.numeric(TWL_Geometry_Std)), fill = "blue")  
# 
# ggplot() + 
#   # geom_line(data = dat, aes(datetime, -as.numeric(TWL_Depth))) +
#   # geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Prt)), colour = "red") +
#   geom_line(data = dat, aes(datetime, as.numeric(DOR_Spread)), colour = "red") 
# 
# ggplot() + 
#   # geom_line(data = dat, aes(datetime, -as.numeric(TWL_Depth))) +
#   # geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Prt)), colour = "red") +
#   geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Prt)), colour = "red") +
#   geom_line(data = dat, aes(datetime, -as.numeric(DOR_Depth_Std)), colour = "blue")
