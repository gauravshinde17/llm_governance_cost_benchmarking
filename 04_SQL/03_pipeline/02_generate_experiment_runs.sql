-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Execution & Experiment Tracking
-- File   : 02_generate_experiment_runs.sql
-- Purpose: Generate experiment runs with governance-aware
--          allocation logic and realistic variance
-- Tiers  : lightweight / balanced / enterprise
-- Version: v2 — 5 providers, 10 models, token & latency variance
-- =====================================================

USE llm_governance_fintech;

INSERT INTO experiment_runs
(
    model_id,
    prompt_id,
    state,
    year,
    input_tokens,
    output_tokens,
    total_tokens,
    latency_ms,
    response_text
)

WITH base_runs AS (

    SELECT
        s.state,
        s.year,
        p.prompt_id,
        p.governance_level,

        -- Expected model tier by governance policy
        CASE
            WHEN p.governance_level = 'exploratory'      THEN 'lightweight'
            WHEN p.governance_level = 'analytical'       THEN 'balanced'
            WHEN p.governance_level = 'compliance_grade' THEN 'enterprise'
        END AS expected_model_tier

    FROM state_kpi_summary s
    JOIN prompt_versions p
        ON p.governance_level IN ('exploratory', 'analytical', 'compliance_grade')
),

allocation_logic AS (

    SELECT
        b.*,

        -- 70% compliant / 30% misallocated (deterministic, reproducible)
        CASE
            WHEN MOD(b.year + LENGTH(b.state), 10) < 7
                THEN b.expected_model_tier
            ELSE
                CASE
                    WHEN b.expected_model_tier = 'enterprise'  THEN 'lightweight'
                    WHEN b.expected_model_tier = 'lightweight' THEN 'enterprise'
                    ELSE 'lightweight'
                END
        END AS assigned_model_tier

    FROM base_runs b
),

model_selected AS (

    SELECT
        a.*,
        m.model_id,
        m.model_name,
        m.provider,
        m.model_tier
    FROM allocation_logic a
    JOIN model_versions m
        ON m.model_tier = a.assigned_model_tier
),

variance_applied AS (

    SELECT
        m.*,

        -- -----------------------------------------------
        -- Input token variance
        -- Base per governance level ± provider-based offset
        -- -----------------------------------------------
        CASE
            WHEN m.governance_level = 'exploratory'      THEN 500
            WHEN m.governance_level = 'analytical'       THEN 800
            WHEN m.governance_level = 'compliance_grade' THEN 1300
        END
        +
        -- Provider offset: adds realistic variation between providers
        CASE m.provider
            WHEN 'OpenAI'     THEN 30
            WHEN 'Anthropic'  THEN 20
            WHEN 'Cohere'     THEN -20
            WHEN 'Google'     THEN 40
            WHEN 'Mistral'    THEN -30
        END
        +
        -- State-level micro variance (deterministic)
        MOD(LENGTH(m.state) * m.year, 50) - 25
        AS input_tokens,

        -- -----------------------------------------------
        -- Output token variance
        -- Base per governance level ± model-based offset
        -- -----------------------------------------------
        CASE
            WHEN m.governance_level = 'exploratory'      THEN 400
            WHEN m.governance_level = 'analytical'       THEN 700
            WHEN m.governance_level = 'compliance_grade' THEN 1100
        END
        +
        -- Model offset: premium models tend to be more verbose
        CASE m.model_tier
            WHEN 'enterprise'  THEN 50
            WHEN 'balanced'    THEN 20
            WHEN 'lightweight' THEN -30
        END
        +
        -- Model-level micro variance
        MOD(LENGTH(m.model_name) * m.year, 40) - 20
        AS output_tokens,

        -- -----------------------------------------------
        -- Latency variance
        -- Base per tier ± provider-based offset
        -- -----------------------------------------------
        CASE m.model_tier
            WHEN 'lightweight' THEN 600
            WHEN 'balanced'    THEN 900
            WHEN 'enterprise'  THEN 1200
        END
        +
        -- Provider latency profile
        CASE m.provider
            WHEN 'OpenAI'     THEN -50
            WHEN 'Anthropic'  THEN -30
            WHEN 'Cohere'     THEN 100
            WHEN 'Google'     THEN -80
            WHEN 'Mistral'    THEN 60
        END
        +
        -- State-year micro variance
        MOD(m.year + LENGTH(m.state), 100) - 50
        AS latency_ms

    FROM model_selected m
)

SELECT
    v.model_id,
    v.prompt_id,
    v.state,
    v.year,

    v.input_tokens,
    v.output_tokens,

    -- Total tokens
    v.input_tokens + v.output_tokens AS total_tokens,

    v.latency_ms,

    -- Simulated structured response
    CONCAT(
        '{ "state": "', v.state,
        '", "year": ',  v.year,
        ', "governance_level": "', v.governance_level,
        '", "provider": "', v.provider,
        '", "model": "', v.model_name,
        '" }'
    ) AS response_text

FROM variance_applied v;


-- =====================================================
-- Verification
-- =====================================================
SELECT COUNT(*) AS total_runs FROM experiment_runs;

SELECT
    p.governance_level,
    m.provider,
    m.model_tier,
    COUNT(*)        AS run_count,
    AVG(r.input_tokens)  AS avg_input_tokens,
    AVG(r.output_tokens) AS avg_output_tokens,
    AVG(r.latency_ms)    AS avg_latency
FROM experiment_runs r
JOIN model_versions  m ON r.model_id  = m.model_id
JOIN prompt_versions p ON r.prompt_id = p.prompt_id
GROUP BY p.governance_level, m.provider, m.model_tier
ORDER BY p.governance_level, m.provider;