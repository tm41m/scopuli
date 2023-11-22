{{ config(materialized='table') }}

with all_calendar_dates as (
    select date_trunc('day', dd)::date as val
    from generate_series(
        '2023-07-25'::timestamp
        , current_date::timestamp + '1 day'::interval
        , '1 day'::interval
    ) as dd
)

, transform_1 as (
    select
        acd.val as calendar_date
        , ds.region_code
        , ds.census_division_id
        , plh.product_id
        , plh.currency
        , plh.unit
        , null::numeric(32, 2) as avg_price_chng
        , null::bigint as product_listings_rtn
        , avg(plh.price) as avg_price
        , count(*) as product_listings
    from all_calendar_dates as acd
    left join {{ source('aethervest', 'product_listings_history') }} as plh
        on acd.val > plh.effective_from and acd.val <= coalesce(plh.effective_to, '9999-01-01'::timestamp)
    inner join {{ ref('dim_store') }} as ds
        on plh.store_id = ds.id
    group by
        grouping sets (
                (1, 2, 3, 4, 5, 6)
                , (1, 2, 4, 5, 6)
                , (1, 4, 5, 6)
        )
)

select
    transform_1.*
    , dcd.census_division_name
    , md5(
        concat_ws(
            '|'
            , transform_1.calendar_date
            , coalesce(transform_1.region_code, '')
            , coalesce(transform_1.census_division_id, '')
            , transform_1.product_id
        )
    ) as md5_key
from transform_1
left join {{ ref('dim_census_division') }} as dcd
    on transform_1.census_division_id = dcd.id
