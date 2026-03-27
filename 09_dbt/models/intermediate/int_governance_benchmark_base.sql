with experiment_runs as (
    select * from {{ ref('stg_experiment_runs') }}
),

evaluation_results as (
    select * from {{ ref('stg_evaluation_results') }}
),

cost_analysis as (
    select * from {{ ref('stg_cost_analysis') }}
),

prompt_versions as (
    select * from {{ ref('stg_prompt_versions') }}
),

model_versions as (
    select * from {{ ref('stg_model_versions') }}
)

select
    r.run_id,
    r.state,
    r.year,
    p.governance_level,
    p.prompt_name,
    p.version_label,

    m.provider,
    m.model_name,
    m.model_tier,

    e.numeric_accuracy_score,
    e.hallucination_score,
    e.structural_compliance_score,
    e.governance_composite_index,

    c.input_cost,
    c.output_cost,
    c.total_cost,
    c.currency_code,

    r.latency_ms

from experiment_runs r
join evaluation_results e on r.run_id = e.run_id
join cost_analysis c on r.run_id = c.run_id
join prompt_versions p on r.prompt_id = p.prompt_id
join model_versions m on r.model_id = m.model_id