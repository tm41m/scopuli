{{ config(materialized='view') }}

select
    cduid as id
    , gid
    , dguid
    , cdname as census_division_name
    , cdtype as census_division_type
    , landarea as land_area
    , pruid
from {{ source('static', 'statcan_census_divisions') }}
