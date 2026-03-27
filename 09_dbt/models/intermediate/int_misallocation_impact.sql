with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
)

select
    governance_level,
    model_tier,

    round(avg(governance_composite_index), 2)   as avg_score,
    round(avg(total_cost), 6)                   as avg_cost

from base
group by governance_level, model_tier