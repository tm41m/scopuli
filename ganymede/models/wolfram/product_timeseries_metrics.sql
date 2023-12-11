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
        , plh.product_id
        , plh.product_listing_id
        , ds.region_code
        , ds.census_division_id
        , plh.price
        , abs(price - avg(price) over (partition by acd.val, product_id, region_code, census_division_id, currency, unit)) as residue_cd
        , abs(price - avg(price) over (partition by acd.val, product_id, region_code, currency, unit)) as residue_re
        , abs(price - avg(price) over (partition by acd.val, product_id, currency, unit)) as residue_ca
        , avg(price) over (partition by acd.val, product_id, region_code, census_division_id, currency, unit) as avg_price
        , stddev(price) over (partition by acd.val, product_id, region_code, census_division_id, currency, unit) as stddev_price_cd
        , stddev(price) over (partition by acd.val, product_id, region_code, currency, unit) as stddev_price_re
        , stddev(price) over (partition by acd.val, product_id, currency, unit) as stddev_price_ca
        , plh.currency
        , plh.unit
    from all_calendar_dates as acd
    left join {{ source('aethervest', 'product_listings_history') }} as plh
        on acd.val > plh.effective_from and acd.val <= coalesce(plh.effective_to, '9999-01-01'::timestamp)
    inner join {{ ref('dim_store') }} as ds
        on plh.store_id = ds.id
)
, transform_2 as (
    select
        calendar_date
        , product_id
        , transform_1.region_code
        , census_division_id
        , currency
        , unit
        , round(avg(price), 2) as avg_price
        , null::numeric(32, 2) as avg_price_chng
        , null::bigint as product_listings_rtn
        , case
            when region_code is not null and census_division_id is not null then sum(case when (residue_cd <= coalesce(stddev_price_cd, 0)) then 0 else 1 end)
            when region_code is not null and census_division_id is null then sum(case when (residue_re <= coalesce(stddev_price_re, 0)) then 0 else 1 end)
            when region_code is null and census_division_id is null then sum(case when (residue_ca <= coalesce(stddev_price_ca, 0)) then 0 else 1 end)
        end as sum_outside_one_stddev
        , count(*) as product_listings
    from transform_1
    group by
        grouping sets (
            (calendar_date, product_id, region_code, census_division_id, currency, unit)
            , (calendar_date, product_id, region_code, currency, unit)
            , (calendar_date, product_id, currency, unit)
        )
)
select 
    transform_2.*
    , dcd.name as census_division_name
    , md5(
        concat_ws(
            '|'
            , transform_2.calendar_date
            , coalesce(transform_2.region_code, '')
            , coalesce(transform_2.census_division_id, '')
            , transform_2.product_id
        )
    ) as md5_key
from transform_2
left join {{ ref('dim_census_division') }} as dcd
    on transform_2.census_division_id = dcd.id