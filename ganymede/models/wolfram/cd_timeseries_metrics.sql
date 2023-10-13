{{ config(materialized='view') }}

with all_calendar_dates as (
    select date_trunc('day', dd):: date as val
    from generate_series
            ( '2023-07-25'::timestamp 
            , current_date::timestamp + '1 day'::interval
            , '1 day'::interval) dd
)
, transform_1 as (
    select *
    from {{ ref('cd_locate_stores') }} s 
    inner join {{ source('aethervest', 'product_listings_history') }} plh 
        on s.id = plh.store_id
)
, transform_2 as (
    select
      acd.val as calendar_date
      , t1.region
      , t1.cdname
      , t1.product_id
      , t1.currency
      , t1.unit
      , avg(t1.price) as avg_price
      , null::numeric(32,2) as avg_price_chng
      , count(1) as product_listings
      , null::bigint as product_listings_rtn
    from all_calendar_dates acd
    left join transform_1 t1
        on acd.val > t1.effective_from and acd.val <= coalesce(t1.effective_to, '9999-01-01'::timestamp)
    group by 
        grouping sets (
            (1,2,3,4,5,6),
            (1,2,4,5,6)    
        )
)
select * 
from transform_2

