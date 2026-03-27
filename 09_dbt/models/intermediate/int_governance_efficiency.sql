with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
)

select
    provider,
    model_name,
    governance_level,

    round(
        avg(governance_composite_index) / nullif(avg(total_cost), 0),
        2
    ) as governance_efficiency_index

from base
group by provider, model_name, governance_level