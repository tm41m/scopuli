#!/bin/bash

export PGPASSWORD=$SCOPULI_PROD_PG_PASSWORD

psql -h $SCOPULI_PROD_PG_HOST -p $SCOPULI__PROD_PG_PORT -d $SCOPULI_PROD_PG_DBNAME -U $SCOPULI_PROD_PG_USERNAME < migrations/20231010_importpostgis.up.sql

cd_filename=tmp_lcd_000b21a_e.zip

curl -o $cd_filename https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lcd_000b21a_e.zip

unzip $cd_filename -d tmp/
rm -f $cd_filename

shp2pgsql -D -I -s 3347 tmp/lcd_000b21a_e.shp static.statcan_census_divisions | psql -h $SCOPULI_PROD_PG_HOST -p $SCOPULI__PROD_PG_PORT -d $SCOPULI_PROD_PG_DBNAME -U $SCOPULI_PROD_PG_USERNAME