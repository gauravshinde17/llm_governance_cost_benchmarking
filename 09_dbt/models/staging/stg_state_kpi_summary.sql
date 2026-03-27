with source as (
    select * from llm_governance_fintech.state_kpi_summary
)

select
    state,
    year,
    total_transaction_value_rupees,
    total_transaction_count,
    yoy_value_growth,
    yoy_count_growth,
    state_value_rank,
    state_growth_rank,
    top_transaction_type,
    top_transaction_type_share,
    anomaly_flag,
    data_version,
    generated_timestamp,
    kpi_hash
from source