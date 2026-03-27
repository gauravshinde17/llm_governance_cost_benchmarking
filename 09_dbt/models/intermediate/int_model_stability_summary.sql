with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
),

state_level_scores as (
    select
        provider,
        model_name,
        model_tier,
        governance_level,
        state,

        avg(governance_composite_index)     as state_avg_score,
        avg(total_cost)                     as state_avg_cost,
        avg(hallucination_score)            as state_avg_hallucination,
        count(*)                            as state_run_count

    from base
    group by provider, model_name, model_tier, governance_level, state
),

stability_calculated as (
    select
        provider,
        model_name,
        model_tier,
        governance_level,

        count(distinct state)                           as states_evaluated,
        sum(state_run_count)                            as total_runs,

        round(avg(state_avg_score), 2)                  as avg_governance_score,
        round(avg(state_avg_cost), 6)                   as avg_cost,
        round(avg(state_avg_hallucination), 2)          as avg_hallucination,

        round(stddev(state_avg_score), 4)               as score_stddev,
        round(stddev(state_avg_hallucination), 4)       as hallucination_stddev,
        round(stddev(state_avg_cost), 6)                as cost_stddev,

        round(min(state_avg_score), 2)                  as min_state_score,
        round(max(state_avg_score), 2)                  as max_state_score,

        round(max(state_avg_score) - min(state_avg_score), 2) as score_range

    from state_level_scores
    group by provider, model_name, model_tier, governance_level
)

select
    sc.*,

    round(
        (sc.score_stddev / nullif(sc.avg_governance_score, 0)) * 100,
    2) as score_cv_pct,

    case
        when sc.score_stddev < 1.0  then 'Highly Stable'
        when sc.score_stddev < 2.0  then 'Stable'
        when sc.score_stddev < 3.0  then 'Moderate Variance'
        else                             'High Variance'
    end as stability_label,

    case
        when sc.avg_governance_score >= 85
            and sc.score_stddev < 2.0   then 'Reliable — High Quality'
        when sc.avg_governance_score >= 85
            and sc.score_stddev >= 2.0  then 'High Quality — Inconsistent'
        when sc.avg_governance_score < 85
            and sc.score_stddev < 2.0   then 'Consistent — Lower Quality'
        else                                 'Unreliable — Review Required'
    end as reliability_label,

    dense_rank() over (
        partition by governance_level
        order by score_stddev asc
    ) as stability_rank

from stability_calculated sc