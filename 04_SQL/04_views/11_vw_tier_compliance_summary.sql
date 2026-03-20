-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Executive Analytical Views
-- File   : 11_vw_tier_compliance_summary.sql
-- Purpose: Summarize compliant vs misallocated runs,
--          compliance rate, and governance score delta
--          per governance level and model tier
-- Technique: CTE, conditional aggregation, ROUND, CASE
-- =====================================================

USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_tier_compliance_summary AS

WITH run_classified AS (

    -- Step 1: Classify every run as compliant or misallocated
    SELECT
        b.provider,
        b.model_name,
        b.model_tier,
        b.governance_level,
        b.governance_composite_index,
        b.total_cost,
        b.hallucination_score,
        b.latency_ms,

        CASE
            WHEN b.governance_level = 'exploratory'
                AND b.model_tier = 'lightweight'  THEN 'Compliant'
            WHEN b.governance_level = 'analytical'
                AND b.model_tier = 'balanced'     THEN 'Compliant'
            WHEN b.governance_level = 'compliance_grade'
                AND b.model_tier = 'enterprise'   THEN 'Compliant'
            ELSE 'Misallocated'
        END AS allocation_status

    FROM vw_governance_benchmark_base b
),

aggregated AS (

    -- Step 2: Aggregate by governance level and model tier
    SELECT
        governance_level,
        model_tier,
        allocation_status,

        COUNT(*)                                        AS total_runs,
        ROUND(AVG(governance_composite_index), 2)       AS avg_governance_score,
        ROUND(AVG(total_cost), 6)                       AS avg_cost,
        ROUND(AVG(hallucination_score), 2)              AS avg_hallucination,
        ROUND(AVG(latency_ms), 0)                       AS avg_latency

    FROM run_classified
    GROUP BY governance_level, model_tier, allocation_status
),

compliance_counts AS (

    -- Step 3: Get total runs per governance level for rate calculation
    SELECT
        governance_level,
        model_tier,

        SUM(total_runs)                                 AS grand_total_runs,

        -- Compliant run count
        SUM(CASE WHEN allocation_status = 'Compliant'
            THEN total_runs ELSE 0 END)                 AS compliant_runs,

        -- Misallocated run count
        SUM(CASE WHEN allocation_status = 'Misallocated'
            THEN total_runs ELSE 0 END)                 AS misallocated_runs,

        -- Compliant avg score
        ROUND(AVG(CASE WHEN allocation_status = 'Compliant'
            THEN avg_governance_score END), 2)          AS compliant_avg_score,

        -- Misallocated avg score
        ROUND(AVG(CASE WHEN allocation_status = 'Misallocated'
            THEN avg_governance_score END), 2)          AS misallocated_avg_score,

        -- Compliant avg cost
        ROUND(AVG(CASE WHEN allocation_status = 'Compliant'
            THEN avg_cost END), 6)                      AS compliant_avg_cost,

        -- Misallocated avg cost
        ROUND(AVG(CASE WHEN allocation_status = 'Misallocated'
            THEN avg_cost END), 6)                      AS misallocated_avg_cost

    FROM aggregated
    GROUP BY governance_level, model_tier
)

-- Step 4: Calculate compliance rate and score delta
SELECT
    cc.governance_level,
    cc.model_tier,
    cc.grand_total_runs,
    cc.compliant_runs,
    cc.misallocated_runs,

    -- Compliance rate percentage
    ROUND(
        (cc.compliant_runs / NULLIF(cc.grand_total_runs, 0)) * 100,
    2) AS compliance_rate_pct,

    -- Misallocation rate percentage
    ROUND(
        (cc.misallocated_runs / NULLIF(cc.grand_total_runs, 0)) * 100,
    2) AS misallocation_rate_pct,

    cc.compliant_avg_score,
    cc.misallocated_avg_score,

    -- Score delta: how much governance is lost due to misallocation
    ROUND(
        cc.compliant_avg_score - cc.misallocated_avg_score,
    2) AS governance_score_delta,

    cc.compliant_avg_cost,
    cc.misallocated_avg_cost,

    -- Cost delta: how much more/less misallocated runs cost
    ROUND(
        cc.misallocated_avg_cost - cc.compliant_avg_cost,
    6) AS cost_delta,

    -- Compliance health label
    CASE
        WHEN ROUND((cc.compliant_runs / NULLIF(cc.grand_total_runs, 0)) * 100, 2) >= 80
            THEN 'Healthy'
        WHEN ROUND((cc.compliant_runs / NULLIF(cc.grand_total_runs, 0)) * 100, 2) >= 60
            THEN 'Moderate Risk'
        ELSE
            'High Risk'
    END AS compliance_health

FROM compliance_counts cc
ORDER BY governance_level, model_tier;


-- =====================================================
-- Verification
-- =====================================================
SELECT
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
    cost_delta,
    compliance_health
FROM vw_tier_compliance_summary
ORDER BY governance_level, model_tier;