{{ config(materialized='table') }}

with transform_1 as (
    select
        ("REF_DATE" || '-01')::date as calendar_date
        , 'monthly' as time_grain
        , {{ raw_region_to_province('\"GEO\"') }} as region_code
        , "Products and product groups" as component_name
        , "VALUE" as cpi
        , lag("VALUE", 1)
            over (
                partition by "GEO", "Products and product groups"
                order by ("REF_DATE" || '-01')::date asc
            )
        as previous_cpi
        , "DGUID" as r_dguid
        , "UOM" as r_uom
    from {{ source('aethervest', 'statcan_cpi_monthly') }}

)

select
    calendar_date::date as calendar_date
    , time_grain::text as time_grain
    , region_code::char(2) as region_code
    , component_name::text as component_name
    , cpi::numeric(32, 2) as cpi
    , previous_cpi::numeric(32, 2) as previous_cpi
    , ((cpi - previous_cpi) / previous_cpi)::numeric(32, 4) as cpi_chng
    , r_dguid::text as r_dguid
    , r_uom::text as r_uom
    , md5(
        concat_ws(
            '|'
            , calendar_date
            , time_grain
            , coalesce(region_code, '')
            , component_name
        )
    ) as md5_key
from transform_1
