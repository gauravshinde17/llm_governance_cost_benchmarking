with source as (
    select * from llm_governance_fintech.prompt_versions
)

select
    prompt_id,
    prompt_name,
    governance_level,
    prompt_template,
    version_label,
    created_at
from source