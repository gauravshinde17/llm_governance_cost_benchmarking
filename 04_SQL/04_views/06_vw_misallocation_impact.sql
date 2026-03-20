USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_misallocation_impact AS

SELECT
    governance_level,
    model_tier,

    ROUND(AVG(governance_composite_index),2) AS avg_score,
    ROUND(AVG(total_cost),6) AS avg_cost

FROM vw_governance_benchmark_base
GROUP BY governance_level, model_tier;