{{ config(materialized='view') }}

select
    dcd.id
    , sum(pm.product_listings) as product_listings
from {{ ref('dim_census_division') }} as dcd
inner join {{ ref('product_metrics') }} as pm
    on dcd.id = pm.census_division_id
group by 1
