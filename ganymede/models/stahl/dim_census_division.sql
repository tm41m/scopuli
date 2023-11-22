{{ config(materialized='view') }}

select
    cduid as id
    , cdname as name
    , cdtype as type
    , landarea as land_area
    , {{ statcan_pruid_to_province('pruid') }} as region_code
from {{ source('static', 'statcan_census_divisions') }}
