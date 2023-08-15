{% macro raw_region_to_province(column_name) %}
    case
        when {{column_name}} in ('Manitoba') then 'MB'
        when {{column_name}} in ('British Columbia', 'Colombie-Britannique') then 'BC'
        when {{column_name}} in ('Nouvelle-Écosse', 'Nova Scotia') then 'NS'
        when {{column_name}} in ('Île-du-Prince-Édouard', 'Prince Edward Island') then 'PE'
        when {{column_name}} in ('Terre-Neuve et Labr.', 'Newfoundland and Labrador') then 'NL'
        when {{column_name}} in ('Terr. du Nord-Ouest', 'Northwest Territories') then 'NT'
        when {{column_name}} in ('Alberta') then 'AB'
        when {{column_name}} in ('ON', 'Ontario') then 'ON'
        when {{column_name}} in ('Nouveau-Brunswick', 'New Brunswick') then 'NB'
        when {{column_name}} in ('Quebec', 'Québec') then 'QC'
        when {{column_name}} in ('Yukon') then 'YT'
        when {{column_name}} in ('Saskatchewan') then 'SK'
        when {{column_name}} in ('Nunavut') then 'NU'
        when {{column_name}} in ('Canada') then null
        else 'Unknown'
    end
{% endmacro %}
