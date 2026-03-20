-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Model Registry & Pricing Configuration
-- File   : 04_model_versions.sql
-- Purpose: Stores LLM provider versions and pricing
-- =====================================================

USE llm_governance_fintech;

CREATE TABLE model_versions (

    model_id INT AUTO_INCREMENT PRIMARY KEY,

    provider VARCHAR(100) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    model_tier VARCHAR(50) NOT NULL,

    input_cost_per_1k_tokens DECIMAL(10,6) NOT NULL,
    output_cost_per_1k_tokens DECIMAL(10,6) NOT NULL,

    pricing_version VARCHAR(20) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'USD',

    effective_from DATE NOT NULL,
    effective_to DATE NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (provider, model_name, pricing_version)

) ENGINE=InnoDB;


SHOW CREATE TABLE model_versions;
SHOW INDEX FROM model_versions;