USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_latency_cost_tradeoff AS

SELECT
    provider,
    model_name,
    governance_level,

    ROUND(AVG(latency_ms),0) AS avg_latency,
    ROUND(AVG(total_cost),6) AS avg_cost,
    ROUND(AVG(governance_composite_index),2) AS avg_score

FROM vw_governance_benchmark_base
GROUP BY provider, model_name, governance_level;