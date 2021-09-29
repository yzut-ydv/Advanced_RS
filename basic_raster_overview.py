import os, gdal
from osgeo import gdal_array
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

## set working directory

os.chdir("G:\\Documents\\_SHK\\M1")

## load raster as dataset

r1 = gdal.Open("raster\\LC08_L1TP_174037_20180904_20180912_01_T1\\LC08_L1TP_174037_20180904_20180912_01_T1_B5.TIF")

## load raster as array

ra = gdal_array.LoadFile("raster\\LC08_L1TP_174037_20180904_20180912_01_T1\\LC08_L1TP_174037_20180904_20180912_01_T1_B5.TIF")

## get number of bands of that image

print(r1.RasterCount)

## get Metadata of dataset
# RAM intensive!!

#print(r1.GetMetadata())

## get Projection
# RAM intensive!!

#print(r1.GetProjection())

## get Geotransform
# RAM intensive!!

#print(r1.GetGeoTransform())

## min, max

print(ra.max())
print(ra.min())


## plot histogram of the raster
# will sometimes give a ValueError, but still function fine

#plt.hist(ra)
#plt.show(ra)

## plot raster

## create rasterstack


