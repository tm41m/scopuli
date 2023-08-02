{{ config(materialized='view') }}

with all_calendar_dates as (
    select date_trunc('day', dd):: date as val
    from generate_series
            ( '2023-07-25'::timestamp 
            , current_date::timestamp + '1 day'::interval
            , '1 day'::interval) dd
)
select
    acd.val as calendar_date
    , {{ raw_region_to_province("s.store_address->>'addressRegion'")}} as region_code
    , plh.product_id
    , plh.currency
    , plh.unit
    , avg(plh.price) as avg_price
    , count(1) as product_listings
from all_calendar_dates acd
left join {{ source('aethervest', 'product_listings_history') }} plh
  on acd.val > plh.effective_from and acd.val <= coalesce(plh.effective_to, '9999-01-01'::timestamp)
join {{ source('aethervest', 'stores')}} s
  on plh.store_id = s.id
group by
  grouping sets (
    (1,2,3,4,5)
    ,(1,3,4,5)
  )

