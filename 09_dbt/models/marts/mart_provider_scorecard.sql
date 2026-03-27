{{
    config(
        materialized='table'
    )
}}

with provider_ranking as (
    select * from {{ ref('int_provider_ranking') }}
),

cost_waste as (
    select * from {{ ref('int_cost_waste_analysis') }}
)

select
    pr.provider,
    pr.governance_level,
    pr.avg_governance_score,
    pr.avg_cost,
    pr.avg_latency,
    pr.avg_hallucination_score,
    pr.cost_per_governance_point,
    pr.total_runs,
    pr.governance_rank,
    pr.cost_efficiency_rank,
    pr.latency_rank,
    pr.hallucination_rank,
    pr.composite_rank_score,
    pr.overall_rank,
    pr.performance_tier,

    -- Cost waste context from misallocated runs
    cw.total_cost_waste,
    cw.avg_cost_waste_per_run,
    cw.avg_governance_score_loss,
    cw.waste_severity

from provider_ranking pr
left join cost_waste cw
    on pr.provider = cw.provider
    and pr.governance_level = cw.governance_level
    and cw.allocation_status = 'Misallocated'

order by pr.governance_level, pr.overall_rank