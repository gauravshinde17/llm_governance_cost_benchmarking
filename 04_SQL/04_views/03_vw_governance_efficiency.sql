USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_governance_efficiency AS

SELECT
    provider,
    model_name,
    governance_level,

    ROUND(
        AVG(governance_composite_index) / NULLIF(AVG(total_cost),0),
        2
    ) AS governance_efficiency_index

FROM vw_governance_benchmark_base
GROUP BY provider, model_name, governance_level;