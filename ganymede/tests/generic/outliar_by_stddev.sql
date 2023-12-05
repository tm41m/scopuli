{% test outliar_by_stddev(model, column_name, index_column_name, partition_column_name, lookback, stddev_coef) %}

with std_devs as (
    select
        {{ index_column_name }},
        {{ partition_column_name }},
        {{ column_name }},
        avg({{ column_name }}) over (partition by {{ partition_column_name }} order by {{ index_column_name }} rows between {{ lookback }} preceding and 1 preceding) as avg_hist_metric,
        stddev({{ column_name }}) over (partition by {{ partition_column_name }} order by {{ index_column_name }} rows between {{ lookback }} preceding and 1 preceding) as stddev_hist_metric
    from {{ ref('product_timeseries_metrics') }}
)
select *
from std_devs
where {{ column_name }} < avg_hist_metric - {{ stddev_coef }} * stddev_hist_metric or {{ column_name }} > avg_hist_metric + {{ stddev_coef }} * stddev_hist_metric
except
select *
from std_devs
where stddev_hist_metric = 0

{% endtest %}