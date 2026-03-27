with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
),

run_details as (
    select
        b.run_id,
        b.provider,
        b.model_name,
        b.model_tier,
        b.governance_level,
        b.total_cost,
        b.governance_composite_index,
        b.latency_ms,

        case
            when b.governance_level = 'exploratory'
                and b.model_tier = 'lightweight'  then 'Compliant'
            when b.governance_level = 'analytical'
                and b.model_tier = 'balanced'     then 'Compliant'
            when b.governance_level = 'compliance_grade'
                and b.model_tier = 'enterprise'   then 'Compliant'
            else 'Misallocated'
        end as allocation_status,

        case
            when b.governance_level = 'exploratory'      then 'lightweight'
            when b.governance_level = 'analytical'       then 'balanced'
            when b.governance_level = 'compliance_grade' then 'enterprise'
        end as expected_tier

    from base b
),

compliant_benchmarks as (
    select
        governance_level,
        round(avg(total_cost), 6)                   as benchmark_cost,
        round(avg(governance_composite_index), 2)   as benchmark_score
    from run_details
    where allocation_status = 'Compliant'
    group by governance_level
),

waste_calculated as (
    select
        rd.provider,
        rd.model_name,
        rd.model_tier,
        rd.governance_level,
        rd.allocation_status,
        rd.total_cost                               as actual_cost,
        cb.benchmark_cost,
        rd.governance_composite_index               as actual_score,
        cb.benchmark_score,

        round(rd.total_cost - cb.benchmark_cost, 6) as cost_waste_per_run,

        round(cb.benchmark_score - rd.governance_composite_index, 2)
                                                    as governance_score_loss

    from run_details rd
    join compliant_benchmarks cb
        on rd.governance_level = cb.governance_level
)

select
    provider,
    governance_level,
    allocation_status,

    count(*)                                        as total_runs,

    round(avg(actual_cost), 6)                      as avg_actual_cost,
    round(avg(benchmark_cost), 6)                   as avg_benchmark_cost,

    round(sum(cost_waste_per_run), 6)               as total_cost_waste,
    round(avg(cost_waste_per_run), 6)               as avg_cost_waste_per_run,

    round(avg(actual_score), 2)                     as avg_actual_score,
    round(avg(benchmark_score), 2)                  as avg_benchmark_score,
    round(avg(governance_score_loss), 2)            as avg_governance_score_loss,

    case
        when abs(avg(cost_waste_per_run)) < 0.001   then 'Low Waste'
        when abs(avg(cost_waste_per_run)) < 0.005   then 'Moderate Waste'
        else                                             'High Waste'
    end as waste_severity

from waste_calculated
group by provider, governance_level, allocation_status