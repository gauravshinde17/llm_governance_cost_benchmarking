-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Executive Analytical Views
-- File   : 10_vw_model_stability_summary.sql
-- Purpose: Measure governance score consistency per model
--          across different states using STDDEV
--          Low variance = stable reliable model
--          High variance = inconsistent governance risk
-- Technique: STDDEV, CTE, conditional aggregation, CASE
-- =====================================================

USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_model_stability_summary AS

WITH state_level_scores AS (

    -- Step 1: Get governance scores per model per state
    SELECT
        provider,
        model_name,
        model_tier,
        governance_level,
        state,

        AVG(governance_composite_index)     AS state_avg_score,
        AVG(total_cost)                     AS state_avg_cost,
        AVG(hallucination_score)            AS state_avg_hallucination,
        COUNT(*)                            AS state_run_count

    FROM vw_governance_benchmark_base
    GROUP BY provider, model_name, model_tier, governance_level, state
),

stability_calculated AS (

    -- Step 2: Calculate stability metrics across states
    SELECT
        provider,
        model_name,
        model_tier,
        governance_level,

        COUNT(DISTINCT state)                           AS states_evaluated,
        SUM(state_run_count)                            AS total_runs,

        -- Core performance metrics
        ROUND(AVG(state_avg_score), 2)                  AS avg_governance_score,
        ROUND(AVG(state_avg_cost), 6)                   AS avg_cost,
        ROUND(AVG(state_avg_hallucination), 2)          AS avg_hallucination,

        -- Stability metrics — lower STDDEV = more consistent
        ROUND(STDDEV(state_avg_score), 4)               AS score_stddev,
        ROUND(STDDEV(state_avg_hallucination), 4)       AS hallucination_stddev,
        ROUND(STDDEV(state_avg_cost), 6)                AS cost_stddev,

        -- Min and Max scores across states
        ROUND(MIN(state_avg_score), 2)                  AS min_state_score,
        ROUND(MAX(state_avg_score), 2)                  AS max_state_score,

        -- Score range: difference between best and worst state
        ROUND(MAX(state_avg_score) - MIN(state_avg_score), 2) AS score_range

    FROM state_level_scores
    GROUP BY provider, model_name, model_tier, governance_level
)

-- Step 3: Assign stability labels and rank
SELECT
    sc.*,

    -- Coefficient of variation: normalized measure of variability
    ROUND(
        (sc.score_stddev / NULLIF(sc.avg_governance_score, 0)) * 100,
    2) AS score_cv_pct,

    -- Stability label based on STDDEV
    CASE
        WHEN sc.score_stddev < 1.0  THEN 'Highly Stable'
        WHEN sc.score_stddev < 2.0  THEN 'Stable'
        WHEN sc.score_stddev < 3.0  THEN 'Moderate Variance'
        ELSE                             'High Variance'
    END AS stability_label,

    -- Reliability label combining score and stability
    CASE
        WHEN sc.avg_governance_score >= 85
            AND sc.score_stddev < 2.0   THEN 'Reliable — High Quality'
        WHEN sc.avg_governance_score >= 85
            AND sc.score_stddev >= 2.0  THEN 'High Quality — Inconsistent'
        WHEN sc.avg_governance_score < 85
            AND sc.score_stddev < 2.0   THEN 'Consistent — Lower Quality'
        ELSE                                 'Unreliable — Review Required'
    END AS reliability_label,

    -- Stability rank per governance level (1 = most stable)
    DENSE_RANK() OVER (
        PARTITION BY governance_level
        ORDER BY score_stddev ASC
    ) AS stability_rank

FROM stability_calculated sc
ORDER BY governance_level, stability_rank;


-- =====================================================
-- Verification
-- =====================================================
SELECT
    provider,
    model_name,
    model_tier,
    governance_level,
    states_evaluated,
    avg_governance_score,
    score_stddev,
    score_range,
    score_cv_pct,
    stability_label,
    reliability_label,
    stability_rank
FROM vw_model_stability_summary
ORDER BY governance_level, stability_rank;