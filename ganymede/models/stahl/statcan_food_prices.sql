{{ config(materialized='table') }}

with transform_1 as (
  select
    ("REF_DATE" || '-01')::date as calendar_date
    , 'monthly' as time_grain
    , {{ raw_region_to_province('\"GEO\"')}} as region_code
    , "Products" as r_product_name
    , lower(substring("Products", '(.*)[,(]')) as product_name
    , case
        when substring("Products", '(\d*\.?\d+)') is not null then substring("Products", '(\d*\.?\d+)')::numeric(32,2) 
        else 1
      end as amount
    , case
        when substring(rtrim("Products"), '\s*(\S+)$') = 'grams' then 'g'
        when substring(rtrim("Products"), '\s*(\S+)$') in ('kilogram', 'kilograms') then 'kg'
        when substring(rtrim("Products"), '\s*(\S+)$') in ('millilitres') then 'mL'
        when substring(rtrim("Products"), '\s*(\S+)$') in ('litres', 'litre') then 'L'
        when rtrim(substring(rtrim("Products"), '\s*(\S+)$'), ')') in ('unit', 'bags', 'dozen')
            then rtrim(substring(rtrim("Products"), '\s*(\S+)$'), ')')
        else 'Unknown'
      end as unit
    , "VALUE" as price
    , lag("VALUE", 1) over(partition by "GEO", "Products" order by ("REF_DATE" || '-01')::date asc) as previous_price
    , "DGUID" as r_dguid
    , case when "UOM" = 'Dollars' then 'CAD' else 'Unknown' end as currency
  from {{ source('aethervest', 'statcan_food_prices') }}
)
select
  *
  , (price - previous_price) / previous_price as price_chng 
from transform_1
