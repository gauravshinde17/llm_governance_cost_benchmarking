with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
),

run_classified as (
    select
        b.provider,
        b.model_name,
        b.model_tier,
        b.governance_level,
        b.governance_composite_index,
        b.total_cost,
        b.hallucination_score,
        b.latency_ms,

        case
            when b.governance_level = 'exploratory'
                and b.model_tier = 'lightweight'  then 'Compliant'
            when b.governance_level = 'analytical'
                and b.model_tier = 'balanced'     then 'Compliant'
            when b.governance_level = 'compliance_grade'
                and b.model_tier = 'enterprise'   then 'Compliant'
            else 'Misallocated'
        end as allocation_status

    from base b
),

aggregated as (
    select
        governance_level,
        model_tier,
        allocation_status,

        count(*)                                        as total_runs,
        round(avg(governance_composite_index), 2)       as avg_governance_score,
        round(avg(total_cost), 6)                       as avg_cost,
        round(avg(hallucination_score), 2)              as avg_hallucination,
        round(avg(latency_ms), 0)                       as avg_latency

    from run_classified
    group by governance_level, model_tier, allocation_status
),

compliance_counts as (
    select
        governance_level,
        model_tier,

        sum(total_runs)                                 as grand_total_runs,

        sum(case when allocation_status = 'Compliant'
            then total_runs else 0 end)                 as compliant_runs,

        sum(case when allocation_status = 'Misallocated'
            then total_runs else 0 end)                 as misallocated_runs,

        round(avg(case when allocation_status = 'Compliant'
            then avg_governance_score end), 2)          as compliant_avg_score,

        round(avg(case when allocation_status = 'Misallocated'
            then avg_governance_score end), 2)          as misallocated_avg_score,

        round(avg(case when allocation_status = 'Compliant'
            then avg_cost end), 6)                      as compliant_avg_cost,

        round(avg(case when allocation_status = 'Misallocated'
            then avg_cost end), 6)                      as misallocated_avg_cost

    from aggregated
    group by governance_level, model_tier
)

select
    cc.governance_level,
    cc.model_tier,
    cc.grand_total_runs,
    cc.compliant_runs,
    cc.misallocated_runs,

    round(
        (cc.compliant_runs / nullif(cc.grand_total_runs, 0)) * 100,
    2) as compliance_rate_pct,

    round(
        (cc.misallocated_runs / nullif(cc.grand_total_runs, 0)) * 100,
    2) as misallocation_rate_pct,

    cc.compliant_avg_score,
    cc.misallocated_avg_score,

    round(
        cc.compliant_avg_score - cc.misallocated_avg_score,
    2) as governance_score_delta,

    cc.compliant_avg_cost,
    cc.misallocated_avg_cost,

    round(
        cc.misallocated_avg_cost - cc.compliant_avg_cost,
    6) as cost_delta,

    case
        when round((cc.compliant_runs / nullif(cc.grand_total_runs, 0)) * 100, 2) >= 80
            then 'Healthy'
        when round((cc.compliant_runs / nullif(cc.grand_total_runs, 0)) * 100, 2) >= 60
            then 'Moderate Risk'
        else
            'High Risk'
    end as compliance_health

from compliance_counts cc