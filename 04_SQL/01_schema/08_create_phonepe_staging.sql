USE llm_governance_fintech;

CREATE TABLE phonepe_transactions_staging (
    
    staging_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    state VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    transaction_type VARCHAR(100) NOT NULL,
    
    transaction_count BIGINT NOT NULL,
    
    transaction_amount_rupees DECIMAL(18,2) NOT NULL,
    transaction_amount_crore DECIMAL(18,4) NOT NULL,
    avg_transaction_value DECIMAL(18,4) NOT NULL,
    
    region VARCHAR(100) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

) ENGINE=InnoDB;


select count(*) 
from phonepe_transactions_staging;