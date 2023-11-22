{{ config(materialized='view') }}

with store_coordinates as (
    select
        *
        , r_store_attributes -> 'geo' -> 'latitude' as latitude
        , r_store_attributes -> 'geo' -> 'longitude' as longitude
        , {{ raw_region_to_province("store_address->>'addressRegion'") }} as region_code
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
    , cd.cduid as census_division_id
    , store_coordinates.region_code
    , store_coordinates.created_at
    , store_coordinates.updated_at
    , store_coordinates.md5_key
from store_coordinates
left join {{ source('static', 'statcan_census_divisions') }} as cd
    on ST_COVERS(cd.geom, ST_TRANSFORM(ST_SETSRID(ST_MAKEPOINT(store_coordinates.longitude::double precision, store_coordinates.latitude::double precision), 4326), 3347))
