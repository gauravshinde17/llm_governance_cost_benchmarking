with base as (
    select * from {{ ref('int_governance_benchmark_base') }}
),

provider_aggregates as (
    select
        provider,
        governance_level,

        round(avg(governance_composite_index), 2)   as avg_governance_score,
        round(avg(total_cost), 6)                   as avg_cost,
        round(avg(latency_ms), 0)                   as avg_latency,

        round(
            avg(total_cost) / nullif(avg(governance_composite_index), 0),
            8
        ) as cost_per_governance_point,

        round(avg(hallucination_score), 2)          as avg_hallucination_score,
        count(*)                                    as total_runs

    from base
    group by provider, governance_level
),

ranked as (
    select
        pa.*,

        dense_rank() over (
            partition by governance_level
            order by avg_governance_score desc
        ) as governance_rank,

        dense_rank() over (
            partition by governance_level
            order by cost_per_governance_point asc
        ) as cost_efficiency_rank,

        dense_rank() over (
            partition by governance_level
            order by avg_latency asc
        ) as latency_rank,

        dense_rank() over (
            partition by governance_level
            order by avg_hallucination_score asc
        ) as hallucination_rank

    from provider_aggregates pa
),

composite_ranked as (
    select
        r.*,

        round(
            (0.40 * governance_rank)
            + (0.30 * cost_efficiency_rank)
            + (0.20 * latency_rank)
            + (0.10 * hallucination_rank),
        2) as composite_rank_score

    from ranked r
)

select
    cr.*,

    dense_rank() over (
        partition by governance_level
        order by composite_rank_score asc
    ) as overall_rank,

    case
        dense_rank() over (
            partition by governance_level
            order by composite_rank_score asc
        )
        when 1 then 'Top Performer'
        when 2 then 'Strong Performer'
        when 3 then 'Moderate Performer'
        when 4 then 'Below Average'
        else 'Underperformer'
    end as performance_tier

from composite_ranked cr