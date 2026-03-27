with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
)

select
    governance_level,
    model_tier,

    avg(governance_composite_index)             as avg_governance_score,
    avg(total_cost)                             as avg_total_cost,

    avg(total_cost) / avg(governance_composite_index)
                                                as cost_per_governance_point,

    avg(governance_composite_index) / avg(total_cost)
                                                as governance_efficiency_index

from base
group by governance_level, model_tier