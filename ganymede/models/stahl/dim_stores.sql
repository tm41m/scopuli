{{ config(materialized='view') }}

with store_coordinates as (
    select *, r_store_attributes->'geo'->'latitude' as latitude, r_store_attributes->'geo'->'longitude' as longitude, {{ raw_region_to_province("store_address->>'addressRegion'") }} as region
    from {{ source('aethervest', 'stores') }}
)
select 
    store_coordinates.id
    , store_coordinates.retailer_name
    , store_coordinates.parent_retailer_name
    , store_coordinates.store_address
    , store_coordinates.version
    , store_coordinates.r_id
    , store_coordinates.r_store_attributes
    , cds.cdname as census_division_name 
    , store_coordinates.region
    , store_coordinates.created_at
    , store_coordinates.updated_at
    , store_coordinates.md5_key
from store_coordinates left join {{ source('static', 'statcan_census_divisions') }} cds
on ST_Covers(cds.geom, ST_Transform(ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326), 3347))