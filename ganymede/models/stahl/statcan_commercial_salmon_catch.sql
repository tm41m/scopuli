{{ config(materialized='table') }}

with transform_1 as (
    select
        scd1.fishery
        , scd1.estimate_type
        , scd1.licence_area
        , scd1.calendar_year
        , scd1.mgmt_area
        , null::integer as vessel_count
        , scd1.boat_days
        , scd1.sockeye_kept
        , null::varchar as sockeye_reld
        , scd1.coho_kept
        , null::varchar as coho_reld
        , scd1.pink_kept
        , null::varchar as pink_reld
        , scd1.chum_kept
        , null::varchar as chum_reld
        , scd1.chinook_kept
        , null::varchar as chinook_reld
        , null::varchar as steelhead_kept
        , null::varchar as steelhead_reld
        , scd1.notes
    from {{ source('static', 'statcan_commercial_salmon_catch_data_1996_to_2004') }} as scd1
    union
    select scd2.*
    from {{ source('static', 'statcan_commercial_salmon_catch_data_2005_to_2022') }} as scd2
)

select
    t1.estimate_type
    , t1.calendar_year
    , t1.mgmt_area
    , t1.vessel_count
    , t1.boat_days
    , unpivoted_catch_quantities.salmon_type
    , unpivoted_catch_quantities.kept
    , unpivoted_catch_quantities.released
    , substring(t1.fishery, 8) as fishery
    , substring(t1.licence_area, 6, 1) as licence_area
    , case
        when t1.notes is not null then 'redacted'
    end as notes
from transform_1 as t1
,
    lateral(
        values
        ('sockeye', sockeye_kept, sockeye_reld)
        , ('coho', coho_kept, coho_reld)
        , ('pink', pink_kept, pink_reld)
        , ('chum', chum_kept, chum_reld)
        , ('chinook', chinook_kept, chinook_reld)
        , ('steelhead', steelhead_kept, steelhead_reld)
    ) as unpivoted_catch_quantities (salmon_type, kept, released)
order by t1.calendar_year, t1.fishery, licence_area
