#' ---
#' title: 'Opening and rendering an image from EO data'
#' ---
#' 
#' 
#' ## Introduction
#' 
#' This example will utilise a file from EUMETSAT CM SAF. We will work with a NetCDF file of monthly sunshine duration over Europe for the single time point of August 2018 from the Interim Climate Data Record. This data file should be provided along with this script and is called `SDUms201808010000401UD1000101UD.nc`. Put this data file in the same folder as this script is in.
#' 
#' For further information about downloading data from EUMETSAT CM SAF you can check the webpage https://wui.cmsaf.eu/ where you can browse the product catalog. There is also an online short course about this data record offered by EUMETSAT which includes tutorials on accessing data https://training.eumetsat.int/course/view.php?id=378.
#' 
#' ## Getting set up
#' 
#' We begin by importing the libraries we need for working with the data. If the packages are already installed, you can load them with the `library()` function. If this gives an error, you need to install them first using `install.packages()`.
#' 
#' It's good practice to load the packages used in your script in one place near the top of the file. This makes it easier for someone else you might share the file with to quickly see which packages they need to run your file.
#' 
## ----load_packages----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# If you have not previously installed these packages, do this first by running the line below without the # sign. You only need to do this once.
# install.packages(c("raster", "rgdal", "ncdf4", "tidync", "cmsaf", "rworldxtra", "fields", "maps"))

# 'raster' and 'rgdal' for working with and plotting NetCDF files
# 'ncdf4' and 'tidync' are for working with NetCDF files
# 'cmsaf' has the CM SAF R Toolbox and will also load `cmsafops`, which has helpful functions for working with CM SAF data.
# 'rworldxtra' for world maps to use in plotting
# 'fields' for plotting
# 'maps' for adding country features to plots
library(raster)
library(rgdal)
library(ncdf4)
library(tidync)
library(cmsaf)
library(rworldxtra)
library(fields)
library(maps)

#' 
#' It's often useful to set the working directory in R. This is just the default directory that R will use for reading and writing files. Files directly in your working directory can be referred to just with their name (or relative path). You can still access files outside your working directory by using the full path.
#' 
#' If you keep your scripts and data files in the same folder, you do not need to provide the full paths. However, you may want to store things in different places and so it is good practice to be specific.
#' 
#' Change the path within `setwd()` below to the folder that this file is in. Remember in R you must always use `/` as the path separator.
#' 
#' You can confirm that you set this correctly by running `getwd()` which should return the directory you set.
#' 
## ----set_wd-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Change the path below to the folder this file is in.
setwd("C:/Users/Danny/Documents/EO Coding R scripts")
# Confirm the working directory was set correctly.
getwd()

#' 
#' Now confirm that the data file `SDUms201808010000401UD1000101UD.nc` exists. If you placed the file within the same folder as this script file, you will not need to change the `data_path` variable below because it is directly in the working directory. If it is somewhere else, you can change `data_path` below with the full file path. If the file exists then `file.exists` will return `TRUE`. If it doesn't, you need to check the file is in the correct place or your path may be incorrect.
#' 
## ----check_file-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
data_path <- "SDUms201808010000401UD1000101UD.nc"
file.exists(data_path)

#' 
#' If this returns `TRUE` then we're reading to start working with the data!
#' 
#' ## Reading a NetCDF file
#' 
#' We can connect to a NetCDF file using the `nc_open()` function from the `ncdf4` package. We save the connection to the file as a variable called `nc`.
#' 
## ----nc_open----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
nc <- nc_open(data_path)

#' 
#' To view information/metadata about the file we can simply run `nc`.
#' 
## ----print_nc---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
nc

#' 
#' This gives a lot of output. We can see that there are 2 variables. `sdu` is the main one and it is indexed by three dimensions from the line `sdu[lon,lat,time]`.
#' 
#' A more concise output can be obtained from the `ncinfo` function from `cmsafops`. For this function, we need to specify that we are providing the `nc` object by naming it explicitly (`nc = nc`). You can find the help file for any function in R by using `?` e.g. `?ncinfo`. We could have instead provided the path to the file.
#' 
## ----ncinfo-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ncinfo(nc = nc)

#' 
#' Notice that there are 3 dimensions in this file, but the `time` dimension is of length 1, so essentially this can be considered as a 2 dimensional data.
#' 
#' ## Extracting data & variables
#' 
#' There are different packages in R that can work with NetCDF files and each has their own way of extracting data and variables from a file. The method you use should depend on what you want to do with the data.
#' 
#' To extract variables as a simple array, you can use `ncvar_get()` from the `ncdf4` package. The `dim` functions tell us the dimensions of the array.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sdu_array <- ncvar_get(nc, "SDU")
dim(sdu_array)

#' 
#' Notice that `sdu_array` has just two dimensions, 1200 x 500 for the longitude and latitude values - the time variable has been dropped since it was just length 1.
#' 
#' We can extract values from this array using the format `[ , ]`. Note that arrays in R are one-based, meaning the first item is `[1, 1]` (not `[0, 0]` like in Python).
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Extract a single value.
sdu_array[10, 10]

# Extract a range of values
sdu_array[1:10, 1:5]

# Extract all values along one dimension
# (Not printed)
# sdu_array[, 1]
# sdu_array[1, ]
# sdu_array[1:5, ]

#' 
#' 
#' We can use the same function to extract the dimension variables too. These are just one dimensional arrays (or vectors) because it has extracted the list of latitude values.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lon_vals <- ncvar_get(nc, "lon")
lat_vals <- ncvar_get(nc, "lat")
dim(lon_vals)
dim(lat_vals)

#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lat_vals

#' 
#' It's important to close the connection to the file after you've finished extracting data from it. This disconnects R from the file and prevents file corruption. Simply use `nc_close()` from `ncdf4` to do this.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
nc_close(nc)

#' 
#' These arrays are useful for doing simple calculations. For example, calculating the mean sunshine duration over the entire grid or converting the values from hours to seconds
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mean(sdu_array, na.rm = TRUE)
sdu_seconds <- sdu_array * 60 * 60

#' 
#' For plotting data from a NetCDF file, we can use these arrays and also different structures to help with projections.
#' 
#' ## Plotting a file
#' 
#' We can plots the arrays we have just extracted using the `image.plot` function from the `fields` package.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Make a quick plot using fields::image.plot
image.plot(sdu_array)

#' 
#' Now lets adapt the figure a little bit. 
#' Plot the 2D-image using `image.plot` from the `fields` package. The color scale label is adjusted by `legend.line`. The color scale named `larry.colors` from the `fields` package is used in reversed order using `rev()`.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
image.plot(x = lon_vals, y = lat_vals, z = sdu_array,
           xlab = "Longitude", ylab = "Latitude",
           main = "CM SAF Sunshine Duration",
           legend.lab = "Sunshine Duration (hours)",
           legend.line = -2.0,
           col = rev(larry.colors()))

# Adding a subtitle
mtext(side = 3, line = 0, "Monthly Sum August 2018")

# Add border lines using `map` from the `maps`
map("world", interior = FALSE, lwd = 1.5, col = "gray20", add = TRUE)

#' 
#' Another way to plot your data is to use the `brick` and `plot` functions from the `raster` package. `brick` imports the data into a "multi-layer raster object" and `plot` will automatically generate a nice plot. The advantage of this method is that the `raster` objects are spatial objects, so we can work with projections when plotting if needed.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sdu_ras <- brick(data_path, varname = "SDU")
plot(sdu_ras)

#' 
#' You can also add country borders by using the `countriesHigh` dataset from the `rworldxtra` package. `lwd` and `col` set the size and colour of the border lines. We use `as()` to convert the `countriesHigh` dataset from polygons to lines, since we only want the outlines.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
data("countriesHigh")
plot(sdu_ras)
world_countries <- as(countriesHigh, "SpatialLines")
raster::plot(world_countries, add = TRUE, lwd = 1.5, col = "grey20")

#' 
#' You can also change the projection of a raster object using the `projectRaster()` function and setting the `crs` (coordinates reference system) parameter. We do this for both the sunshine duration data and the countries data.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
new_proj <- "+proj=lcc +lat_1=48 +lat_2=33 +lon_0=-100 +datum=WGS84"
sdu_ras_new_proj <- projectRaster(sdu_ras, crs = new_proj)
plot(sdu_ras_new_proj)

world_countires_new_proj <- sp::spTransform(world_countries, CRSobj = crs(sdu_ras_new_proj))
raster::plot(world_countires_new_proj, add = TRUE, lwd = 1.5, col = "grey20")

#' 
#' ### Another data extraction method
#' Another way to extract data from a NetCDF file is to use the `tidync` package to import the file into a "tidy" data frame format. That means the data will be in a long table, with a column for the variable (`sdu`) and one column for each dimension (`lat`, `lon`, `time`). 
#' We use the functions `tidync()` and `hyper_tibble()` to read and then convert the data to a "tibble" (dataframe). The `%>%` is called a "pipe" and it's just a convenient way of applying functions after another. It is the same as `hyper_tibble(tidync(data_path))` but a bit more readable. You often also use this with the `hyper_filter()` function to extract a subset.
#' 
#' The `head()` function give us the first few rows of the data frame.
#' 
#' This format might be useful for manipulating and summarising the data, and if you want to use the data with the "tidyverse" packages such as `ggplot2` for graphics, and `dplyr` for data manipulation.
#' 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sdu_df <- tidync(data_path) %>% hyper_tibble()
head(sdu_df)

#' 
