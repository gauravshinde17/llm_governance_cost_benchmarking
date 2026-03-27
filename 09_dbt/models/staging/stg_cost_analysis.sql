with source as (
    select * from llm_governance_fintech.cost_analysis
)

select
    cost_id,
    run_id,
    input_cost,
    output_cost,
    total_cost,
    currency_code,
    calculated_at
from source