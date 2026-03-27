with source as (
    select * from llm_governance_fintech.evaluation_results
)

select
    evaluation_id,
    run_id,
    evaluation_version,
    evaluation_engine,
    numeric_accuracy_score,
    hallucination_score,
    structural_compliance_score,
    governance_composite_index,
    evaluation_notes,
    evaluated_at
from source