{{ config(materialized='view') }}

with all_calendar_dates as (
    select date_trunc('day', dd):: date as val
    from generate_series
            ( '2023-07-25'::timestamp 
            , current_date::timestamp + '1 day'::interval
            , '1 day'::interval) dd
)
, transform_1 as (
  select
      acd.val as calendar_date
      , s.region as region_code
      , s.census_division_name
      , plh.product_id
      , plh.currency
      , plh.unit
      , avg(plh.price) as avg_price
      , null::numeric(32,2) as avg_price_chng
      , count(1) as product_listings
      , null::bigint as product_listings_rtn
  from all_calendar_dates acd
  left join {{ source('aethervest', 'product_listings_history') }} plh
    on acd.val > plh.effective_from and acd.val <= coalesce(plh.effective_to, '9999-01-01'::timestamp)
  join {{ ref('dim_stores')}} s
    on plh.store_id = s.id
  group by
    grouping sets (
        (1,2,3,4,5,6)
        ,(1,2,4,5,6)
        ,(1,4,5,6)
    )
)
select
  *
  , md5(concat_ws('|', calendar_date, coalesce(region_code, ''), coalesce(census_division_name, ''), product_id)) as md5_key
from transform_1
