-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Model Registry & Pricing Configuration
-- File   : 01_seed_model_versions.sql
-- Purpose: Seed LLM provider models with enterprise pricing
-- Tiers  : lightweight / balanced / enterprise
-- Version: v2 — expanded to 5 providers, 10 models
-- =====================================================

USE llm_governance_fintech;

INSERT INTO model_versions
(
    provider,
    model_name,
    model_tier,
    input_cost_per_1k_tokens,
    output_cost_per_1k_tokens,
    pricing_version,
    currency_code,
    effective_from,
    effective_to
)
VALUES

-- =====================================================
-- OpenAI
-- =====================================================
(
    'OpenAI',
    'gpt-4o',
    'enterprise',
    0.005000,
    0.015000,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),
(
    'OpenAI',
    'gpt-4o-mini',
    'lightweight',
    0.000600,
    0.002400,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),

-- =====================================================
-- Anthropic
-- =====================================================
(
    'Anthropic',
    'claude-3-sonnet',
    'enterprise',
    0.003000,
    0.015000,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),
(
    'Anthropic',
    'claude-3-haiku',
    'lightweight',
    0.000800,
    0.004000,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),

-- =====================================================
-- Cohere
-- =====================================================
(
    'Cohere',
    'command-r-plus',
    'enterprise',
    0.003000,
    0.006000,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),
(
    'Cohere',
    'command-r',
    'balanced',
    0.001000,
    0.002000,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),

-- =====================================================
-- Google
-- =====================================================
(
    'Google',
    'gemini-1.5-pro',
    'enterprise',
    0.001250,
    0.005000,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),
(
    'Google',
    'gemini-1.5-flash',
    'lightweight',
    0.000075,
    0.000300,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),

-- =====================================================
-- Mistral
-- =====================================================
(
    'Mistral',
    'mistral-large',
    'balanced',
    0.002000,
    0.006000,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
),
(
    'Mistral',
    'mistral-small',
    'lightweight',
    0.000200,
    0.000600,
    '2026_base',
    'USD',
    '2026-01-01',
    NULL
);


-- =====================================================
-- Verification
-- =====================================================
SELECT
    provider,
    model_name,
    model_tier,
    input_cost_per_1k_tokens,
    output_cost_per_1k_tokens
FROM model_versions
ORDER BY provider, model_tier;