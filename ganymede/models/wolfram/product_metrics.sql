{{ config(materialized='view') }}

select *
from {{ ref('product_timeseries_metrics') }}
where calendar_date = (
    select max(calendar_date)
    from {{ ref('product_timeseries_metrics') }}
)
