with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
)

select
    provider,
    model_name,
    governance_level,

    round(avg(latency_ms), 0)                   as avg_latency,
    round(avg(total_cost), 6)                   as avg_cost,
    round(avg(governance_composite_index), 2)   as avg_score

from base
group by provider, model_name, governance_level