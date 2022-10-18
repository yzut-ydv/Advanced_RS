### Set your working directory. You can use the function 'ReadClipboard()' to paste the path string with the correct syntaxis.

wd <- setwd("your\\path\\here")
getwd()

### Install and load packages

# Define the multiple mutiple packages in a vector
PkgToLoad <- c("raster", "rgdal", "ggplot2", "devtools", "sf")

# Install mutiple packages if needed
install.packages(PkgToLoad)

# Load the packages
lapply(PkgToLoad, library, character.only = TRUE)

# The package 'devtools' is important in order to be able to import packages directly from the Github repository
# While installing the last version of 'RStoolbox', please select option Nr:3 or 'None'. This way no package will be updated
install_github("bleutner/RStoolbox")
library("RStoolbox")

### Perform the radiometric correction. 
# More information on: https://bleutner.github.io/RStoolbox/rstbx-docu/radCor.html
#In this exercise we are using the raster data of last week (basic raster) so please adjust your path accordingly

# Import meta-data and bands based on MTL file
metaData <- readMeta("data\\LC08_L1TP_174037_20180904_20180912_01_T1\\LC08_L1TP_174037_20180904_20180912_01_T1_MTL.txt")

# Stack the metadata bands
lsMeta <- stackMeta(metaData)

# Correct DN to at-surface-reflecatance with DOS (Chavez decay model)
l8_boa_ref <- radCor(lsMeta, metaData, method = "dos")

# Export raster to folder
writeRaster(l8_boa_ref, datatype="FLT4S", filename = "data\\wk2_results\\l8_boa_ref.tif", format = "GTiff", overwrite=TRUE)
# Afterwards, load the image in QGis. Compare the file 'l8_boa_ref' and the file 'l8_radiance' in terms of quality.

### Load the BOA-Landsat8 image as a 'rasterBrick'.

# import the corrected boa image
l8_boa_br <- brick("data/wk2_results/l8_boa_ref.tif")

# Load the vector file that shows a subset of the AOI and crop the Landsat corrected image.
# Load vector shapefile
aoi <- readOGR("data\\vector", "aoi_beirut")

# In case the Projection of the vector and the raster do not coincide, reproject the vector file before cropping.

# Check the projection of the vector
crs(aoi)

# Check the projection of your raster
crs(l8_boa_br)

# Reproject aoi if needed
aoi <- spTransform(aoi, crs(l8_boa_br))

# Crop all rasters to the extent of the aoi
l8_boa_cr <- crop(l8_boa_br, aoi)

# Export raster to folder
writeRaster(l8_boa_cr, datatype="FLT4S", filename = "data\\wk2_results\\l8_boa_cr.tif", format = "GTiff", overwrite=TRUE)

# Plot
plotRGB(l8_boa_cr, r=4, g=3, b=2, axes=TRUE, stretch="lin", main = "Bottom of Atmosphere Reflectance. Landsat 8")