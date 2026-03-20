USE llm_governance_fintech;


CREATE OR REPLACE VIEW vw_allocation_optimization AS

SELECT
    governance_level,
    model_tier,

    AVG(governance_composite_index) AS avg_governance_score,

    AVG(total_cost) AS avg_total_cost,

    -- Lower is better
    AVG(total_cost) / AVG(governance_composite_index) 
        AS cost_per_governance_point,

    -- Higher is better
    AVG(governance_composite_index) / AVG(total_cost) 
        AS governance_efficiency_index

FROM vw_governance_benchmark_base

GROUP BY
    governance_level,
    model_tier;