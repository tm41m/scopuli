{% test warn_large_values(model, column_name, threshold) %}

{{ config(severity = 'warn') }}

select *
from {{ model }}
where {{column_name }} > {{ threshold }}

{% endtest %}