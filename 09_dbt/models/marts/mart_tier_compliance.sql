{{
    config(
        materialized='table'
    )
}}

with tier_compliance as (
    select * from {{ ref('int_tier_compliance_summary') }}
)

select
    governance_level,
    model_tier,
    grand_total_runs,
    compliant_runs,
    misallocated_runs,
    compliance_rate_pct,
    misallocation_rate_pct,
    compliant_avg_score,
    misallocated_avg_score,
    governance_score_delta,
    compliant_avg_cost,
    misallocated_avg_cost,
    cost_delta,
    compliance_health

from tier_compliance

order by governance_level, model_tier