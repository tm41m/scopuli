#!/bin/bash

PGHOST=$SCOPULI_LOCAL_PG_HOST
PGPORT=$SCOPULI_LOCAL_PG_PORT
PGDBNAME=$SCOPULI_LOCAL_PG_DBNAME
PGUSERNAME=$SCOPULI_LOCAL_PG_USERNAME
export PGPASSWORD=${SCOPULI_LOCAL_PG_PASSWORD}

mkdir tmp/

# download resources 
curl "https://api-proxy.edh.azure.cloud.dfo-mpo.gc.ca/catalogue/records/82c7eaa7-7078-4d38-a880-25d53f00c579/attachments/gill_net_1996-2004_commercial_salmon_post-season_catch_en.csv" -o "tmp/gill_net_catch_data_1996-2004.csv"
curl "https://api-proxy.edh.azure.cloud.dfo-mpo.gc.ca/catalogue/records/82c7eaa7-7078-4d38-a880-25d53f00c579/attachments/seine_1996-2004_commercial_salmon_post-season_catch_en.csv" -o "tmp/seine_catch_data_1996-2004.csv"
curl "https://api-proxy.edh.azure.cloud.dfo-mpo.gc.ca/catalogue/records/82c7eaa7-7078-4d38-a880-25d53f00c579/attachments/troll_1996-2004_commercial_salmon_post-season_catch_en.csv" -o "tmp/troll_catch_data_1996-2004.csv"
curl "https://api-proxy.edh.azure.cloud.dfo-mpo.gc.ca/catalogue/records/7ac5fe02-308d-4fff-b805-80194f8ddeb4/attachments/ise-ecs.zip" -o "tmp/catch_data_2005-2022.zip"

# unzip file containing the 2005-2022 datasets
unzip tmp/catch_data_2005-2022.zip -d tmp/
rm -f tmp/catch_data_2005-2022.zip

# delete the dataset's name value from each csv
sed -i '' 1d tmp/gill_net_catch_data_1996-2004.csv
sed -i '' 1d tmp/seine_catch_data_1996-2004.csv
sed -i '' 1d tmp/troll_catch_data_1996-2004.csv
sed -i '' 1d tmp/ise-ecs/cs-gn-pac-dfo-mpo-science-eng.csv
sed -i '' 1d tmp/ise-ecs/cs-sn-pac-dfo-mpo-science-eng.csv
sed -i '' 1d tmp/ise-ecs/cs-tr-pac-dfo-mpo-science-eng.csv

# create tables to dump data into
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "
    CREATE TABLE if not exists static.statcan_commercial_salmon_catch_data_1996_to_2004 (
        FISHERY VARCHAR(15), 
        ESTIMATE_TYPE CHAR(11), 
        LICENCE_AREA VARCHAR(24), 
        CALENDAR_YEAR INTEGER, 
        MGMT_AREA INTEGER, 
        BOAT_DAYS VARCHAR, 
        SOCKEYE_KEPT VARCHAR, 
        COHO_KEPT VARCHAR, 
        PINK_KEPT VARCHAR, 
        CHUM_KEPT VARCHAR, 
        CHINOOK_KEPT VARCHAR, 
        NOTES VARCHAR(54)
    );
"
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "
    CREATE TABLE if not exists static.statcan_commercial_salmon_catch_data_2005_to_2022 (
        FISHERY VARCHAR(15), 
        ESTIMATE_TYPE CHAR(11), 
        LICENCE_AREA VARCHAR(24), 
        CALENDAR_YEAR INTEGER, 
        MGMT_AREA INTEGER, 
        VESSEL_COUNT INTEGER,
        BOAT_DAYS VARCHAR, 
        SOCKEYE_KEPT VARCHAR, 
        SOCKEYE_RELD VARCHAR,
        COHO_KEPT VARCHAR,
        COHO_RELD VARCHAR, 
        PINK_KEPT VARCHAR,
        PINK_RELD VARCHAR, 
        CHUM_KEPT VARCHAR, 
        CHUM_RELD VARCHAR,
        CHINOOK_KEPT VARCHAR, 
        CHINOOK_RELD VARCHAR,
        STEELHEAD_KEPT VARCHAR,
        STEELHEAD_RELD VARCHAR,
        NOTES CHAR(54)
    );
"

# copy data from csv into statcan_commercial_salmon_catch_data_1996_to_2004 table
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "\copy static.statcan_commercial_salmon_catch_data_1996_to_2004 from 'tmp/gill_net_catch_data_1996-2004.csv' delimiter ',' csv header;"
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "\copy static.statcan_commercial_salmon_catch_data_1996_to_2004 from 'tmp/seine_catch_data_1996-2004.csv' delimiter ',' csv header;"
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "\copy static.statcan_commercial_salmon_catch_data_1996_to_2004 from 'tmp/troll_catch_data_1996-2004.csv' delimiter ',' csv header;"

# copy data from csv into statcan_commercial_salmon_catch_data_2005_to_2022 table
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "\copy static.statcan_commercial_salmon_catch_data_2005_to_2022 from 'tmp/ise-ecs/cs-gn-pac-dfo-mpo-science-eng.csv' delimiter ',' csv header encoding 'UTF8';"
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "\copy static.statcan_commercial_salmon_catch_data_2005_to_2022 from 'tmp/ise-ecs/cs-sn-pac-dfo-mpo-science-eng.csv' delimiter ',' csv header encoding 'UTF8';"
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "\copy static.statcan_commercial_salmon_catch_data_2005_to_2022 from 'tmp/ise-ecs/cs-tr-pac-dfo-mpo-science-eng.csv' delimiter ',' csv header encoding 'LATIN1';"

# pre-processing on the licence_area columns
psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "
    update static.statcan_commercial_salmon_catch_data_1996_to_2004
    set licence_area = 
        case   
            when licence_area like 'AREA C%' then 'AREA C - SALMON GILL NET'
            when licence_area like 'AREA D%' then 'AREA D - SALMON GILL NET'
            when licence_area like 'AREA E%' then 'AREA E - SALMON GILL NET'
            when licence_area like 'AREA B%' then 'AREA B - SALMON SEINE'
            else licence_area
        end;
"

psql -h $PGHOST -p $PGPORT -d $PGDBNAME -U $PGUSERNAME -c "
    update static.statcan_commercial_salmon_catch_data_2005_to_2022
    set licence_area = 
        case
            when licence_area like 'AREA H%' then 'AREA H - SALMON TROLL'
            when licence_area like 'AREA G%' then 'AREA G - SALMON TROLL'
            when licence_area like 'AREA F%' then 'AREA F - SALMON TROLL'
            else licence_area
        end;
"
rm -r tmp/