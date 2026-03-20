-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Cost Attribution Layer
-- File   : 04_generate_cost_analysis.sql
-- Purpose: Calculate cost per run using actual token counts
--          and real published model pricing
-- Version: v2 — reflects variance token counts from v2 runs
-- =====================================================

USE llm_governance_fintech;

INSERT INTO cost_analysis
(
    run_id,
    input_cost,
    output_cost,
    total_cost,
    currency_code
)

SELECT
    r.run_id,

    -- Input cost
    ROUND(
        (r.input_tokens / 1000.0) * m.input_cost_per_1k_tokens,
        6
    ) AS input_cost,

    -- Output cost
    ROUND(
        (r.output_tokens / 1000.0) * m.output_cost_per_1k_tokens,
        6
    ) AS output_cost,

    -- Total cost
    ROUND(
        ((r.input_tokens  / 1000.0) * m.input_cost_per_1k_tokens)
        +
        ((r.output_tokens / 1000.0) * m.output_cost_per_1k_tokens),
        6
    ) AS total_cost,

    m.currency_code

FROM experiment_runs r
JOIN model_versions m ON r.model_id = m.model_id;


-- =====================================================
-- Verification
-- =====================================================
SELECT COUNT(*) AS total_cost_records FROM cost_analysis;

SELECT
    m.provider,
    m.model_name,
    m.model_tier,
    ROUND(AVG(c.input_cost),  6) AS avg_input_cost,
    ROUND(AVG(c.output_cost), 6) AS avg_output_cost,
    ROUND(AVG(c.total_cost),  6) AS avg_total_cost,
    ROUND(MIN(c.total_cost),  6) AS min_total_cost,
    ROUND(MAX(c.total_cost),  6) AS max_total_cost
FROM cost_analysis c
JOIN experiment_runs r ON c.run_id   = r.run_id
JOIN model_versions  m ON r.model_id = m.model_id
GROUP BY m.provider, m.model_name, m.model_tier
ORDER BY avg_total_cost DESC;




