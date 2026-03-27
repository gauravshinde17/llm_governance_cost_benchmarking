{{
    config(
        materialized='table'
    )
}}

with cost_waste as (
    select * from {{ ref('int_cost_waste_analysis') }}
)

select
    provider,
    governance_level,
    allocation_status,
    total_runs,
    avg_actual_cost,
    avg_benchmark_cost,
    total_cost_waste,
    avg_cost_waste_per_run,
    avg_actual_score,
    avg_benchmark_score,
    avg_governance_score_loss,
    waste_severity

from cost_waste

order by governance_level, allocation_status, provider