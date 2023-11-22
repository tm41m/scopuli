{{ config(materialized='view') }}

select
    cduid as id
    , cdname as census_division_name
    , cdtype as division_type
    , landarea as land_area
    , {{ statcan_pruid_to_province('pruid') }} as region_code
from {{ source('static', 'statcan_census_divisions') }}
