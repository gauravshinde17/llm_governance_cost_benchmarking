-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Evaluation & Scoring Layer
-- File   : 06_evaluation_results.sql
-- Purpose: Stores evaluation results for each experiment run
-- =====================================================

USE llm_governance_fintech;

CREATE TABLE evaluation_results (

    evaluation_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    run_id BIGINT NOT NULL,

    evaluation_version VARCHAR(30) NOT NULL,
    evaluation_engine VARCHAR(100) NOT NULL,

    numeric_accuracy_score DECIMAL(5,2) NOT NULL,
    hallucination_score DECIMAL(5,2) NOT NULL,
    structural_compliance_score DECIMAL(5,2) NOT NULL,

    governance_composite_index DECIMAL(6,2) NOT NULL,

    evaluation_notes TEXT NULL,

    evaluated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_evaluation_run
        FOREIGN KEY (run_id)
        REFERENCES experiment_runs(run_id)

) ENGINE=InnoDB;


SHOW CREATE TABLE evaluation_results;
SHOW INDEX FROM evaluation_results;