
### "Flood change detection"

# Set the working directory ("wd") and assign it to an object (here, "w")
w <- setwd(".\\your\\path")

# Check the location of the working directory
getwd()

#  Load and install packages
ipak <- function(pkg){
  newpkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(newpkg)) 
    install.packages(newpkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}


packages <- c("rgdal", "raster","sp", "RColorBrewer", "RStoolbox", "sf")
ipak(packages)

### 3. Create change data

#For detecting change, you can make classes for the observed change in the landscape. For example: 
  
# + 1 : agriculture - agriculture
# + 2 : forest - forest
# + 3 : river - sediment 
# + 4 : urban - urban  
# + 5 : urban - sediment
# + 6 : river - river

# In QGIS, create at least 10-15 polygons per land class. These polygons correspond to the change data that will be used for the supervised classification. 

### 4. Change detection: Classification of rasters

#### Read raster data

s2_pre_cr <- stack("data\\s2_change_rasters\\juneCrop_32N.tif")
s2_post_cr <- stack("data\\s2_change_rasters\\julyCrop_32N.tif")

# Merge the before and after Sentinel-2 images for the classification

s2_pre_cr <- resample(s2_pre_cr,s2_post_cr)
s2_change <- stack(s2_pre_cr, s2_post_cr)
s2_change

#### Read vector data with land cover change classes

# In this example, we created a multipolygon shapefile with 6 classes that corresponds to the land covers identifiable on the raster image:  
  
# + 1 : agriculture - agriculture
# + 2 : forest - forest
# + 3 : river - sediment 
# + 4 : urban - urban  
# + 5 : urban - sediment
# + 6 : river - river
# 
# Import the vector file with these landcover change classes

# Import change samples
change <- readOGR("data\\vector\\wk3_change_data.shp")

# Since the projection did not match, I made a reprojection here.
change_32N <- spTransform(change, crs(s2_change))

# Plot the change data on top of the raster subset.   
# Plot the raster with both vector files on top
# First, add the raster
plotRGB(s2_pre_cr, r=3, g=2, b=1, axes=FALSE, stretch="lin")

# Second, add the vectors
plot(change_32N, col="red", add=TRUE)

## Classification with `superClass()` from the RStoolbox Package

flood_change <- superClass(img = s2_change,  nSamples=100, trainData = change_32N, responseCol = "class_name")

# Display classification results
flood_change
# Since, the validation data was not included, therefore, no test of the model could be performed. Create a validation data, include it in the model and run again the classifier. Share the results of this step with your colleagues. 
 
# Plot your change detection map
plot(flood_change$map, breaks = c(0, 1, 2, 3, 4, 5, 6), col = c("darkolivegreen", "tomato", "yellowgreen", "tan", "blue2", "cyan") , main = 'Change Detection Classification')

## Landscape Statistics

# Generate statistics of the area that was classified to quantify the damages

flood_change.freq <- freq(flood_change$map, useNA= "no")

change.freq <- flood_change.freq[, "count"]*10^2*1e-06

# plot the stats
barplot(change.freq, main = "Area (km2) of landcover change in our study area",
        col= c("darkolivegreen", "tomato", "yellowgreen", "tan", "blue2", "cyan"), 
        names.arg = c("agriculture", "forest", "river", "sedimented river", "sedimented urban", "urban"))

# assign the classification to an object
map_classi <- flood_change$map

# export the classification as a raster
writeRaster(map_classi, datatype="FLT4S", filename = "data/wk3_results\\change_detection_classification.tif", format = "GTiff", overwrite=TRUE)