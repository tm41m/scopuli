{{ config(materialized='view') }}

with store_locations as (
    select id, r_store_attributes->'geo'->'latitude' as latitude, r_store_attributes->'geo'->'longitude' as longitude, {{ raw_region_to_province("store_address->>'addressRegion'") }} as region
    from {{ source('aethervest', 'stores') }}
)
select store_locations.id, cds.cdname, store_locations.region 
from store_locations inner join {{ source('static_resources', 'censusdivisions') }} cds
on ST_Covers(cds.geom, ST_Transform(ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326), 3347))

/*
select ST_Covers(cds.geom, ST_Transform(ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326), 3347)) 
from store_locations, {{ source('static_resources', 'censusdivisions') }} cds
where cds.pruid='35'


join instead of where
*/


/*
select store_locations.id, cds.cdname 
from store_locations, {{ source('static_resources', 'censusdivisions') }} cds
where ST_Covers(cds.geom, ST_Transform(ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326), 3347))
*/

