-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Cost Attribution Layer
-- File   : 07_cost_analysis.sql
-- Purpose: Stores calculated cost per experiment run
-- =====================================================

USE llm_governance_fintech;

CREATE TABLE cost_analysis (

    cost_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    run_id BIGINT NOT NULL,

    input_cost DECIMAL(12,6) NOT NULL,
    output_cost DECIMAL(12,6) NOT NULL,
    total_cost DECIMAL(12,6) NOT NULL,

    currency_code CHAR(3) NOT NULL DEFAULT 'USD',

    calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cost_run
        FOREIGN KEY (run_id)
        REFERENCES experiment_runs(run_id),

    UNIQUE (run_id)

) ENGINE=InnoDB;


SHOW CREATE TABLE cost_analysis;
SHOW INDEX FROM cost_analysis;