with source as (
    select * from llm_governance_fintech.model_versions
)

select
    model_id,
    provider,
    model_name,
    model_tier,
    input_cost_per_1k_tokens,
    output_cost_per_1k_tokens,
    pricing_version,
    currency_code,
    effective_from,
    effective_to,
    created_at
from source