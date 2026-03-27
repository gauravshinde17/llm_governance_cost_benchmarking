with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
)

select
    provider,
    model_name,
    governance_level,

    round(avg(governance_composite_index), 2)   as avg_governance_score,
    round(avg(total_cost), 6)                   as avg_total_cost,

    round(
        avg(total_cost) / nullif(avg(governance_composite_index), 0),
        8
    ) as cost_per_governance_point

from base
group by provider, model_name, governance_level