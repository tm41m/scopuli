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
        , plh.currency
        , plh.unit
        , abs(plh.price - avg(plh.price) over (partition by acd.val, plh.product_id, ds.region_code, ds.census_division_id, plh.currency, plh.unit)) as residue_cd
        , abs(plh.price - avg(plh.price) over (partition by acd.val, plh.product_id, ds.region_code, plh.currency, plh.unit)) as residue_re
        , abs(plh.price - avg(plh.price) over (partition by acd.val, plh.product_id, plh.currency, plh.unit)) as residue_ca
        , avg(plh.price) over (partition by acd.val, plh.product_id, ds.region_code, ds.census_division_id, plh.currency, plh.unit) as avg_price
        , stddev(plh.price) over (partition by acd.val, plh.product_id, ds.region_code, ds.census_division_id, plh.currency, plh.unit) as stddev_price_cd
        , stddev(plh.price) over (partition by acd.val, plh.product_id, ds.region_code, plh.currency, plh.unit) as stddev_price_re
        , stddev(plh.price) over (partition by acd.val, plh.product_id, plh.currency, plh.unit) as stddev_price_ca
    from all_calendar_dates as acd
    left join {{ source('aethervest', 'product_listings_history') }} as plh
        on acd.val > plh.effective_from and acd.val <= coalesce(plh.effective_to, '9999-01-01'::timestamp)
    inner join {{ ref('dim_store') }} as ds
        on plh.store_id = ds.id
)

, transform_2 as (
    select
        t1.calendar_date
        , t1.product_id
        , t1.region_code
        , t1.census_division_id
        , t1.currency
        , t1.unit
        , null::numeric(32, 2) as avg_price_chng
        , null::bigint as product_listings_rtn
        , round(avg(t1.price), 2) as avg_price
        , case
            when t1.region_code is not null and t1.census_division_id is not null then sum(case when (t1.residue_cd <= coalesce(t1.stddev_price_cd, 0)) then 0 else 1 end)
            when t1.region_code is not null and t1.census_division_id is null then sum(case when (t1.residue_re <= coalesce(t1.stddev_price_re, 0)) then 0 else 1 end)
            when t1.region_code is null and t1.census_division_id is null then sum(case when (t1.residue_ca <= coalesce(t1.stddev_price_ca, 0)) then 0 else 1 end)
        end as sum_listings_outside_one_stddev
        , count(*) as product_listings
    from transform_1 as t1
    group by
        grouping sets (
                (t1.calendar_date, t1.product_id, t1.region_code, t1.census_division_id, t1.currency, t1.unit)
                , (t1.calendar_date, t1.product_id, t1.region_code, t1.currency, t1.unit)
                , (t1.calendar_date, t1.product_id, t1.currency, t1.unit)
        )
)

select
    t2.*
    , dcd.name as census_division_name
    , t2.sum_outside_one_stddev / t2.product_listings as percent_listings_outside_one_stddev
    , md5(
        concat_ws(
            '|'
            , t2.calendar_date
            , coalesce(t2.region_code, '')
            , coalesce(t2.census_division_id, '')
            , t2.product_id
        )
    ) as md5_key
from transform_2 as t2
left join {{ ref('dim_census_division') }} as dcd
    on t2.census_division_id = dcd.id
