with source as (
    select * from llm_governance_fintech.experiment_runs
)

select
    run_id,
    model_id,
    prompt_id,
    state,
    year,
    input_tokens,
    output_tokens,
    total_tokens,
    latency_ms,
    response_text,
    run_timestamp
from source