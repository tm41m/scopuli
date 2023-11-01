#!/bin/bash

psql -h $PG_HOST -p $PG_PORT -d $PG_DBNAME -U $PG_USERNAME < migrations/20231010_importpostgis_0000.up.sql

cd_filename=tmp_lcd_000b21a_e.zip

curl -o $cd_filename https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lcd_000b21a_e.zip

unzip $cd_filename -d tmp/
rm -f $cd_filename

shp2pgsql -D -I -s 3347 tmp/lcd_000b21a_e.shp static.statcan_census_divisions | psql -h $PG_HOST -p $PG_PORT -d $PG_DBNAME -U $PG_USERNAME