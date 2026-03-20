USE llm_governance_fintech;

CREATE OR REPLACE VIEW vw_provider_efficiency AS

SELECT
    provider,
    governance_level,

    ROUND(AVG(governance_composite_index),2) AS avg_score,
    ROUND(AVG(total_cost),6) AS avg_cost,
    ROUND(AVG(latency_ms),0) AS avg_latency,

    ROUND(
        AVG(total_cost) / NULLIF(AVG(governance_composite_index),0),
        8
    ) AS cost_per_governance_point

FROM vw_governance_benchmark_base
GROUP BY provider, governance_level;