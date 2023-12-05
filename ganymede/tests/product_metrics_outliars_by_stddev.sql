with std_devs as (
    select
        calendar_date,
        product_id,
        avg_price,
        avg(avg_price) over (partition by region_code, census_division_id, product_id, unit order by calendar_date rows between 30 preceding and 1 preceding) as avg_monthly_price,
        stddev(avg_price) over (partition by region_code, census_division_id, product_id, unit order by calendar_date rows between 30 preceding and 1 preceding) as stddev_monthly_price
    from {{ ref('product_timeseries_metrics') }}
)
select *
from std_devs
where avg_price < avg_monthly_price - 2 * stddev_monthly_price or avg_price > avg_monthly_price + 2 * stddev_monthly_price
except
select *
from std_devs
where stddev_monthly_price = 0