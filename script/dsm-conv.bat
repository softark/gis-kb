@echo off
set FILE=%1
set IN_FILE=D:\i-gis\hyogo\DSM\txt\DSM_05%FILE%1_05g.txt
set OUT_FILE=D:\i-gis\hyogo\DSM\raster\DSM_%FILE%1.tif
C:\OSgeo4W\bin\gdal_translate -a_srs EPSG:6673 -ot Float32 -of GTiff %IN_FILE% %OUT_FILE%
set IN_FILE=D:\i-gis\hyogo\DSM\txt\DSM_05%FILE%2_05g.txt
set OUT_FILE=D:\i-gis\hyogo\DSM\raster\DSM_%FILE%2.tif
C:\OSgeo4W\bin\gdal_translate -a_srs EPSG:6673 -ot Float32 -of GTiff %IN_FILE% %OUT_FILE%
set IN_FILE=D:\i-gis\hyogo\DSM\txt\DSM_05%FILE%3_05g.txt
set OUT_FILE=D:\i-gis\hyogo\DSM\raster\DSM_%FILE%3.tif
C:\OSgeo4W\bin\gdal_translate -a_srs EPSG:6673 -ot Float32 -of GTiff %IN_FILE% %OUT_FILE%
set IN_FILE=D:\i-gis\hyogo\DSM\txt\DSM_05%FILE%4_05g.txt
set OUT_FILE=D:\i-gis\hyogo\DSM\raster\DSM_%FILE%4.tif
C:\OSgeo4W\bin\gdal_translate -a_srs EPSG:6673 -ot Float32 -of GTiff %IN_FILE% %OUT_FILE%
