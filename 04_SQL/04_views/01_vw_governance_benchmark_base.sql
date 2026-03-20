USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_governance_benchmark_base AS

SELECT
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

FROM experiment_runs r
JOIN evaluation_results e ON r.run_id = e.run_id
JOIN cost_analysis c ON r.run_id = c.run_id
JOIN prompt_versions p ON r.prompt_id = p.prompt_id
JOIN model_versions m ON r.model_id = m.model_id;