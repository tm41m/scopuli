{{ config(materialized='view') }}

select dcd.id
from {{ ref('dim_census_division')}} as dcd
