-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Execution & Experiment Tracking
-- File   : 05_experiment_runs.sql
-- Purpose: Logs every LLM execution instance
-- =====================================================

USE llm_governance_fintech;

CREATE TABLE experiment_runs (

    run_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    model_id INT NOT NULL,
    prompt_id INT NOT NULL,

    state VARCHAR(100) NOT NULL,
    year INT NOT NULL,

    input_tokens INT NOT NULL,
    output_tokens INT NOT NULL,
    total_tokens INT NOT NULL,

    latency_ms INT NOT NULL,

    response_text LONGTEXT NOT NULL,

    run_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraints

    CONSTRAINT fk_experiment_model
        FOREIGN KEY (model_id)
        REFERENCES model_versions(model_id),

    CONSTRAINT fk_experiment_prompt
        FOREIGN KEY (prompt_id)
        REFERENCES prompt_versions(prompt_id),

    CONSTRAINT fk_experiment_truth
        FOREIGN KEY (state, year)
        REFERENCES state_kpi_summary(state, year)

) ENGINE=InnoDB;


SHOW CREATE TABLE experiment_runs;
SHOW INDEX FROM experiment_runs;