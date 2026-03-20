-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Deterministic Truth Layer
-- File   : 02_state_kpi_summary.sql
-- Purpose: Authoritative state-year KPI benchmark table
-- =====================================================

USE llm_governance_fintech;

CREATE TABLE state_kpi_summary (

    state VARCHAR(100) NOT NULL,
    year INT NOT NULL,

    total_transaction_value_rupees DECIMAL(18,2) NOT NULL,
    total_transaction_count BIGINT NOT NULL,

    yoy_value_growth DECIMAL(6,2) NOT NULL,
    yoy_count_growth DECIMAL(6,2) NOT NULL,

    state_value_rank INT NOT NULL,
    state_growth_rank INT NOT NULL,

    top_transaction_type VARCHAR(100) NOT NULL,
    top_transaction_type_share DECIMAL(5,2) NOT NULL,

    anomaly_flag BOOLEAN NOT NULL DEFAULT FALSE,

    data_version VARCHAR(20) NOT NULL,
    generated_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    kpi_hash CHAR(64) NOT NULL,

    PRIMARY KEY (state, year)

) ENGINE=InnoDB;



SHOW CREATE TABLE state_kpi_summary;