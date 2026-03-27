with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
)

select
    provider,
    governance_level,

    round(avg(governance_composite_index), 2)   as avg_score,
    round(avg(total_cost), 6)                   as avg_cost,
    round(avg(latency_ms), 0)                   as avg_latency,

    round(
        avg(total_cost) / nullif(avg(governance_composite_index), 0),
        8
    ) as cost_per_governance_point

from base
group by provider, governance_level