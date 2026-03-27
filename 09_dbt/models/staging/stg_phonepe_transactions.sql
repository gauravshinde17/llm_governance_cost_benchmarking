with source as (
    select * from llm_governance_fintech.phonepe_transactions_staging
)

select
    state,
    year,
    quarter,
    transaction_type,
    transaction_count,
    transaction_amount_rupees,
    transaction_amount_crore,
    avg_transaction_value,
    region
from source