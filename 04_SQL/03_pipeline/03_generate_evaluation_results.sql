-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Evaluation & Scoring Layer
-- File   : 03_generate_evaluation_results.sql
-- Purpose: Generate governance scores with policy-aware
--          weighting, misallocation penalties and variance
-- Tiers  : lightweight / balanced / enterprise
-- Version: v2 — 5 providers, score variance, provider profiles
-- =====================================================

USE llm_governance_fintech;

INSERT INTO evaluation_results
(
    run_id,
    evaluation_version,
    evaluation_engine,
    numeric_accuracy_score,
    hallucination_score,
    structural_compliance_score,
    governance_composite_index,
    evaluation_notes
)

WITH run_context AS (

    SELECT
        r.run_id,
        r.state,
        r.year,
        r.input_tokens,
        r.output_tokens,
        p.governance_level,
        m.model_tier,
        m.provider,
        m.model_name,

        -- Expected tier per governance policy
        CASE
            WHEN p.governance_level = 'exploratory'      THEN 'lightweight'
            WHEN p.governance_level = 'analytical'       THEN 'balanced'
            WHEN p.governance_level = 'compliance_grade' THEN 'enterprise'
        END AS expected_tier

    FROM experiment_runs r
    JOIN prompt_versions p ON r.prompt_id = p.prompt_id
    JOIN model_versions  m ON r.model_id  = m.model_id
),

scored AS (

    SELECT
        rc.*,

        -- Allocation correctness flag
        CASE
            WHEN rc.model_tier = rc.expected_tier THEN 1
            ELSE 0
        END AS is_compliant

    FROM run_context rc
),

base_scores AS (

    SELECT
        s.*,

        -- -----------------------------------------------
        -- Numeric Accuracy Base by tier
        -- -----------------------------------------------
        CASE
            WHEN s.model_tier = 'enterprise'  THEN 92
            WHEN s.model_tier = 'balanced'    THEN 85
            WHEN s.model_tier = 'lightweight' THEN 75
        END
        -- Provider accuracy profile
        + CASE s.provider
            WHEN 'OpenAI'     THEN  1
            WHEN 'Anthropic'  THEN  2
            WHEN 'Cohere'     THEN  0
            WHEN 'Google'     THEN -1
            WHEN 'Mistral'    THEN -2
        END
        -- Misallocation penalty
        - CASE
            WHEN s.governance_level = 'compliance_grade' AND s.is_compliant = 0 THEN 15
            WHEN s.governance_level = 'analytical'       AND s.is_compliant = 0 THEN 8
            ELSE 0
        END
        -- State-year micro variance
        + (MOD(LENGTH(s.state) + s.year, 5) - 2)
        AS numeric_accuracy_score,

        -- -----------------------------------------------
        -- Hallucination Score (lower is better)
        -- -----------------------------------------------
        CASE
            WHEN s.model_tier = 'enterprise'  THEN 5
            WHEN s.model_tier = 'balanced'    THEN 10
            WHEN s.model_tier = 'lightweight' THEN 18
        END
        -- Provider hallucination profile
        + CASE s.provider
            WHEN 'OpenAI'     THEN -1
            WHEN 'Anthropic'  THEN -2
            WHEN 'Cohere'     THEN  1
            WHEN 'Google'     THEN  2
            WHEN 'Mistral'    THEN  1
        END
        -- Misallocation penalty
        + CASE
            WHEN s.governance_level = 'compliance_grade' AND s.is_compliant = 0 THEN 12
            WHEN s.governance_level = 'analytical'       AND s.is_compliant = 0 THEN 6
            ELSE 0
        END
        -- Micro variance
        + (MOD(LENGTH(s.model_name) + s.year, 4) - 2)
        AS hallucination_score,

        -- -----------------------------------------------
        -- Structural Compliance Score
        -- -----------------------------------------------
        CASE
            WHEN s.model_tier = 'enterprise'  THEN 95
            WHEN s.model_tier = 'balanced'    THEN 88
            WHEN s.model_tier = 'lightweight' THEN 78
        END
        -- Provider structural profile
        + CASE s.provider
            WHEN 'OpenAI'     THEN  1
            WHEN 'Anthropic'  THEN  2
            WHEN 'Cohere'     THEN  1
            WHEN 'Google'     THEN -1
            WHEN 'Mistral'    THEN -1
        END
        -- Misallocation penalty
        - CASE
            WHEN s.governance_level = 'compliance_grade' AND s.is_compliant = 0 THEN 20
            WHEN s.governance_level = 'analytical'       AND s.is_compliant = 0 THEN 10
            ELSE 0
        END
        -- Micro variance
        + (MOD(LENGTH(s.state) + LENGTH(s.model_name), 6) - 3)
        AS structural_compliance_score

    FROM scored s
)

SELECT
    b.run_id,
    'v2_policy_engine'       AS evaluation_version,
    'SQL_POLICY_SIMULATION'  AS evaluation_engine,

    b.numeric_accuracy_score,
    b.hallucination_score,
    b.structural_compliance_score,

    -- -----------------------------------------------
    -- Governance Composite Index
    -- Weighted by governance tier
    -- -----------------------------------------------
    ROUND(
        CASE
            WHEN b.governance_level = 'exploratory' THEN
                (0.50 * b.numeric_accuracy_score)
                + (0.20 * b.structural_compliance_score)
                + (0.30 * (100 - b.hallucination_score))

            WHEN b.governance_level = 'analytical' THEN
                (0.45 * b.numeric_accuracy_score)
                + (0.35 * b.structural_compliance_score)
                + (0.20 * (100 - b.hallucination_score))

            WHEN b.governance_level = 'compliance_grade' THEN
                (0.40 * b.numeric_accuracy_score)
                + (0.30 * b.structural_compliance_score)
                + (0.30 * (100 - b.hallucination_score))
        END,
    2) AS governance_composite_index,

    CASE
        WHEN b.is_compliant = 1 THEN 'Compliant allocation'
        ELSE 'Misallocated model for governance tier'
    END AS evaluation_notes

FROM base_scores b;


-- =====================================================
-- Verification
-- =====================================================
SELECT COUNT(*) AS total_evaluations FROM evaluation_results;

SELECT
    m.provider,
    m.model_tier,
    p.governance_level,
    ROUND(AVG(e.numeric_accuracy_score),      2) AS avg_accuracy,
    ROUND(AVG(e.hallucination_score),         2) AS avg_hallucination,
    ROUND(AVG(e.structural_compliance_score), 2) AS avg_structural,
    ROUND(AVG(e.governance_composite_index),  2) AS avg_composite
FROM evaluation_results e
JOIN experiment_runs r ON e.run_id      = r.run_id
JOIN model_versions  m ON r.model_id    = m.model_id
JOIN prompt_versions p ON r.prompt_id   = p.prompt_id
GROUP BY m.provider, m.model_tier, p.governance_level
ORDER BY m.provider, p.governance_level;