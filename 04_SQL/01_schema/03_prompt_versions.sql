-- =====================================================
-- Project: LLM Governance & Cost Benchmarking Framework
-- Layer  : Governance Configuration Layer
-- File   : 03_prompt_versions.sql
-- Purpose: Stores versioned LLM prompt templates
-- =====================================================

USE llm_governance_fintech;

CREATE TABLE prompt_versions (

    prompt_id INT AUTO_INCREMENT PRIMARY KEY,

    prompt_name VARCHAR(100) NOT NULL,
    governance_level VARCHAR(20) NOT NULL,

    prompt_template TEXT NOT NULL,

    version_label VARCHAR(20) NOT NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (prompt_name, version_label)

) ENGINE=InnoDB;



SHOW CREATE TABLE prompt_versions;
SHOW INDEX FROM prompt_versions;