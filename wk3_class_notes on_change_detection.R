### change detection

# set my working directory
w <- setwd("C:\\Users\\ulloa-to\\git\\Advanced_Remote_sensing_HM")

getwd()

libToload <- c("rgdal", "raster")
library("rgdal")
library("raster")
library("sp")
library("RColorBrewer")
library("RStoolbox")
library(sf)

# load the raster stack, cropped

s2_pre_june <- stack("data\\s2_change_rasters\\juneCrop_32N.tif")
s2_post_july <- stack("data\\s2_change_rasters\\julyCrop_32N.tif")

# load aoi vector

aoi <- readOGR("data\\vector\\wk3_aoi.shp")
crs(aoi) 
# +proj=utm +zone=31 +datum=WGS84 +units=m +no_defs 
crs(s2_pre_june)
# +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs 

# reproject the aoi, because it has the wrong projection
aoi_32N <- spTransform(aoi, crs(s2_pre_june))
# +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs

# let'S mask both sentinel images to the shape of the vector AOI_32N. 
s2_pre_june_mask <- mask(s2_pre_june, aoi_32N)
s2_post_july_mask <- mask(s2_post_july, aoi_32N)

# export the masked files
writeRaster(s2_pre_june_mask, datatype="FLT4S", filename = "data/wk3_results/s2_june_32N_mask.tif", format = "GTiff", overwrite=TRUE)
writeRaster(s2_post_july_mask, datatype="FLT4S", filename = "data/wk3_results/s2_july_32N_mask.tif", format = "GTiff", overwrite=TRUE)

# plot a cropped and a masked file to see the difference between the 2 functions
x11()
plotRGB(s2_pre_june, r=3, g=2, b=1, axes=FALSE, stretch="lin", main = "raster cropped")
x11()
plotRGB(s2_pre_june_mask, r=3, g=2, b=1, axes=FALSE, stretch="lin", main = "raster masked")

# create a change raster stack
s2_pre_june_mask <- resample(s2_pre_june_mask, s2_post_july_mask)
s2_change <- stack(s2_pre_june_mask, s2_post_july_mask)

s2_change

# load train data
training_change  <- readOGR("data\\vector\\wk3_change_data.shp")

# reproject our training data
training_change_32N <- spTransform(training_change, crs(s2_change))

# let's do the classification
flood_change <- superClass(img = s2_change, nSamples = 1000, trainData = training_change_32N, 
                           responseCol = "class_name")

# plot
x11()
plot(flood_change$map, breaks = c(0, 1, 2, 3, 4, 5, 6), 
     col = c("darkolivegreen", "tomato", "yellowgreen", "tan", "blue2", "cyan"),
     main = "Change Detection")


# plot binary change
x11()
plot(flood_change$map, breaks = c(0, 1, 2, 3, 4, 5, 6), 
     col = c("cyan", "cyan", "tomato", "cyan", "tomato", "cyan"),
     main = "Change Detection Binary")















