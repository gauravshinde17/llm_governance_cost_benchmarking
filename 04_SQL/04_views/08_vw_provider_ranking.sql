-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Executive Analytical Views
-- File   : 07_vw_provider_ranking.sql
-- Purpose: Rank providers across governance, cost, and
--          latency dimensions using window functions
-- Technique: DENSE_RANK, CTE, multi-dimensional scoring
-- =====================================================

USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_provider_ranking AS

WITH provider_aggregates AS (

    -- Step 1: Aggregate core metrics per provider and governance level
    SELECT
        provider,
        governance_level,

        ROUND(AVG(governance_composite_index), 2) AS avg_governance_score,
        ROUND(AVG(total_cost), 6)                 AS avg_cost,
        ROUND(AVG(latency_ms), 0)                 AS avg_latency,

        ROUND(
            AVG(total_cost) / NULLIF(AVG(governance_composite_index), 0),
            8
        ) AS cost_per_governance_point,

        ROUND(AVG(hallucination_score), 2)        AS avg_hallucination_score,
        COUNT(*)                                   AS total_runs

    FROM vw_governance_benchmark_base
    GROUP BY provider, governance_level
),

ranked AS (

    -- Step 2: Apply DENSE_RANK across each dimension
    SELECT
        pa.*,

        -- Governance rank: higher score = better = rank 1
        DENSE_RANK() OVER (
            PARTITION BY governance_level
            ORDER BY avg_governance_score DESC
        ) AS governance_rank,

        -- Cost efficiency rank: lower cost per point = better = rank 1
        DENSE_RANK() OVER (
            PARTITION BY governance_level
            ORDER BY cost_per_governance_point ASC
        ) AS cost_efficiency_rank,

        -- Latency rank: lower latency = better = rank 1
        DENSE_RANK() OVER (
            PARTITION BY governance_level
            ORDER BY avg_latency ASC
        ) AS latency_rank,

        -- Hallucination rank: lower hallucination = better = rank 1
        DENSE_RANK() OVER (
            PARTITION BY governance_level
            ORDER BY avg_hallucination_score ASC
        ) AS hallucination_rank

    FROM provider_aggregates pa
),

composite_ranked AS (

    -- Step 3: Compute overall rank score (lower is better)
    SELECT
        r.*,

        -- Overall score: weighted sum of individual ranks
        -- Governance weighted highest for compliance-focused framework
        ROUND(
            (0.40 * governance_rank)
            + (0.30 * cost_efficiency_rank)
            + (0.20 * latency_rank)
            + (0.10 * hallucination_rank),
        2) AS composite_rank_score

    FROM ranked r
)

SELECT
    cr.*,

    -- Final overall rank per governance level
    DENSE_RANK() OVER (
        PARTITION BY governance_level
        ORDER BY composite_rank_score ASC
    ) AS overall_rank,

    -- Performance tier label based on overall rank
    CASE
        DENSE_RANK() OVER (
            PARTITION BY governance_level
            ORDER BY composite_rank_score ASC
        )
        WHEN 1 THEN 'Top Performer'
        WHEN 2 THEN 'Strong Performer'
        WHEN 3 THEN 'Moderate Performer'
        WHEN 4 THEN 'Below Average'
        ELSE 'Underperformer'
    END AS performance_tier

FROM composite_ranked cr;


-- =====================================================
-- Verification
-- =====================================================
SELECT
    governance_level,
    overall_rank,
    provider,
    performance_tier,
    avg_governance_score,
    avg_cost,
    avg_latency,
    cost_per_governance_point,
    composite_rank_score
FROM vw_provider_ranking
ORDER BY governance_level, overall_rank;