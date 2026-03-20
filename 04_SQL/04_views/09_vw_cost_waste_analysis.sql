-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Executive Analytical Views
-- File   : 09_vw_cost_waste_analysis.sql
-- Purpose: Quantify exact cost waste from misallocated
--          model tier assignments vs compliant allocations
-- Technique: CTE, CASE, conditional aggregation, LAG
-- =====================================================

USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_cost_waste_analysis AS

WITH run_details AS (

    -- Step 1: Get full run context with allocation status
    SELECT
        b.run_id,
        b.provider,
        b.model_name,
        b.model_tier,
        b.governance_level,
        b.total_cost,
        b.governance_composite_index,
        b.latency_ms,

        -- Determine if run is compliant or misallocated
        CASE
            WHEN b.governance_level = 'exploratory'
                AND b.model_tier = 'lightweight'  THEN 'Compliant'
            WHEN b.governance_level = 'analytical'
                AND b.model_tier = 'balanced'     THEN 'Compliant'
            WHEN b.governance_level = 'compliance_grade'
                AND b.model_tier = 'enterprise'   THEN 'Compliant'
            ELSE 'Misallocated'
        END AS allocation_status,

        -- Expected tier for this governance level
        CASE
            WHEN b.governance_level = 'exploratory'      THEN 'lightweight'
            WHEN b.governance_level = 'analytical'       THEN 'balanced'
            WHEN b.governance_level = 'compliance_grade' THEN 'enterprise'
        END AS expected_tier

    FROM vw_governance_benchmark_base b
),

compliant_benchmarks AS (

    -- Step 2: Calculate average compliant cost per governance level
    -- This is the baseline — what a run SHOULD cost
    SELECT
        governance_level,
        ROUND(AVG(total_cost), 6)                  AS benchmark_cost,
        ROUND(AVG(governance_composite_index), 2)  AS benchmark_score
    FROM run_details
    WHERE allocation_status = 'Compliant'
    GROUP BY governance_level
),

waste_calculated AS (

    -- Step 3: Join misallocated runs against benchmark
    -- Calculate waste per run
    SELECT
        rd.provider,
        rd.model_name,
        rd.model_tier,
        rd.governance_level,
        rd.allocation_status,
        rd.total_cost                              AS actual_cost,
        cb.benchmark_cost,
        rd.governance_composite_index              AS actual_score,
        cb.benchmark_score,

        -- Cost waste: actual minus benchmark (positive = overspend)
        ROUND(rd.total_cost - cb.benchmark_cost, 6) AS cost_waste_per_run,

        -- Score loss: benchmark minus actual (positive = governance loss)
        ROUND(cb.benchmark_score - rd.governance_composite_index, 2)
            AS governance_score_loss

    FROM run_details rd
    JOIN compliant_benchmarks cb
        ON rd.governance_level = cb.governance_level
)

-- Step 4: Aggregate waste by provider and governance level
SELECT
    provider,
    governance_level,
    allocation_status,

    COUNT(*)                                        AS total_runs,

    ROUND(AVG(actual_cost), 6)                      AS avg_actual_cost,
    ROUND(AVG(benchmark_cost), 6)                   AS avg_benchmark_cost,

    -- Total waste across all runs
    ROUND(SUM(cost_waste_per_run), 6)               AS total_cost_waste,
    ROUND(AVG(cost_waste_per_run), 6)               AS avg_cost_waste_per_run,

    ROUND(AVG(actual_score), 2)                     AS avg_actual_score,
    ROUND(AVG(benchmark_score), 2)                  AS avg_benchmark_score,
    ROUND(AVG(governance_score_loss), 2)            AS avg_governance_score_loss,

    -- Waste severity label
    CASE
        WHEN ABS(AVG(cost_waste_per_run)) < 0.001   THEN 'Low Waste'
        WHEN ABS(AVG(cost_waste_per_run)) < 0.005   THEN 'Moderate Waste'
        ELSE                                              'High Waste'
    END AS waste_severity

FROM waste_calculated
GROUP BY provider, governance_level, allocation_status
ORDER BY governance_level, allocation_status, provider;


-- =====================================================
-- Verification
-- =====================================================
SELECT
    provider,
    governance_level,
    allocation_status,
    total_runs,
    avg_actual_cost,
    avg_benchmark_cost,
    total_cost_waste,
    avg_governance_score_loss,
    waste_severity
FROM vw_cost_waste_analysis
ORDER BY governance_level, allocation_status;