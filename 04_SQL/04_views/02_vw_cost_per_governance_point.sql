USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_cost_per_governance_point AS

SELECT
    provider,
    model_name,
    governance_level,

    ROUND(AVG(governance_composite_index),2) AS avg_governance_score,
    ROUND(AVG(total_cost),6) AS avg_total_cost,

    ROUND(
        AVG(total_cost) / NULLIF(AVG(governance_composite_index),0),
        8
    ) AS cost_per_governance_point

FROM vw_governance_benchmark_base
GROUP BY provider, model_name, governance_level;