{{ config(materialized='view') }}

select
    cduid as id
    , dguid
    , cdname as census_division_name
    , cdtype as census_division_type
    , landarea as land_area
    , {{ statcan_pruid_to_provinceid('pruid') }} as province_id

from {{ source('static', 'statcan_census_divisions') }}