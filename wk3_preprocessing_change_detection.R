#### Preprocessing of the Sentinel data ###########
# After downloading the data from the ESA archive, open and preprocess in R

# Load necessary libraries
ipak <- function(pkg){
  newpkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(newpkg)) 
    install.packages(newpkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}


packages <- c("rgdal", "raster","dplyr", "magrittr", "RStoolbox", "dplyr","magrittr","sf","sp")
ipak(packages)

# set working directory
w <- setwd("C:\\Users\\ulloa-to\\Desktop\\M3")

# load bands 2, 3, 4, 8 from each date (before and after the disaster)
june_b2 <- raster("raster\\june01_raw\\T32ULA_20210601T104021_B02_20m.jp2")
june_b3 <- raster("raster\\june01_raw\\T32ULA_20210601T104021_B03_20m.jp2")
june_b4 <- raster("raster\\june01_raw\\T32ULA_20210601T104021_B04_20m.jp2")
june_b5 <- raster("raster\\june01_raw\\T32ULA_20210601T104021_B05_20m.jp2")


july_b2 <- raster("raster\\july21_raw\\T31UGR_20210721T104031_B02_20m.jp2")
july_b3 <- raster("raster\\july21_raw\\T31UGR_20210721T104031_B03_20m.jp2")
july_b4 <- raster("raster\\july21_raw\\T31UGR_20210721T104031_B04_20m.jp2")
july_b5 <- raster("raster\\july21_raw\\T31UGR_20210721T104031_B05_20m.jp2")

# stack files
junestack <- stack(june_b2,june_b3,june_b4,june_b5)
julystack <- stack(july_b2,july_b3,july_b4,july_b5)

# reprojection july scene
junecrs <- crs(junestack)
julystck_reprj <- projectRaster(julystack, crs = junecrs)

# export both stacks with the same projection
writeRaster(julystck_reprj, datatype="FLT4S", filename = "raster\\julystack_32N.tif", format = "GTiff", overwrite=TRUE)
writeRaster(junestack, datatype="FLT4S", filename = "raster\\junestack_32N.tif", format = "GTiff", overwrite=TRUE)

# crop raster to SHP aoi
# load vector
aoi <- st_read("vector\\aoi.shp")

# the projection was also wrong. Reproject. 
aoi_32N <- st_transform(aoi, CRS("+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs"))

# crop rasters using the aoi
junecrop <- crop(junestack, aoi_32N)
julycrop <- crop(julystck_reprj, aoi_32N)

# export cropped files
writeRaster(junecrop, datatype="FLT4S", filename = "raster\\juneCrop_32N.tif", format = "GTiff", overwrite=TRUE)
writeRaster(julycrop, datatype="FLT4S", filename = "raster\\julyCrop_32N.tif", format = "GTiff", overwrite=TRUE)