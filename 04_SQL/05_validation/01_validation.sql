-- ============================================================
-- LLM Governance & Cost Benchmarking Framework
-- Validation Script
-- ============================================================

USE llm_governance_fintech;

-- ── Row Counts ──────────────────────────────────────────────
SELECT 'phonepe_transactions_staging' AS table_name, COUNT(*) AS row_count FROM phonepe_transactions_staging
UNION ALL SELECT 'state_kpi_summary',   COUNT(*) FROM state_kpi_summary
UNION ALL SELECT 'prompt_versions',     COUNT(*) FROM prompt_versions
UNION ALL SELECT 'model_versions',      COUNT(*) FROM model_versions
UNION ALL SELECT 'experiment_runs',     COUNT(*) FROM experiment_runs
UNION ALL SELECT 'evaluation_results',  COUNT(*) FROM evaluation_results
UNION ALL SELECT 'cost_analysis',       COUNT(*) FROM cost_analysis;

-- ── Orphan Records ──────────────────────────────────────────
SELECT 'experiment_runs → model_versions orphans'    AS check_name, COUNT(*) AS orphans FROM experiment_runs er LEFT JOIN model_versions mv ON er.model_id = mv.model_id WHERE mv.model_id IS NULL
UNION ALL SELECT 'experiment_runs → prompt_versions orphans',  COUNT(*) FROM experiment_runs er LEFT JOIN prompt_versions pv ON er.prompt_id = pv.prompt_id WHERE pv.prompt_id IS NULL
UNION ALL SELECT 'experiment_runs → state_kpi_summary orphans',COUNT(*) FROM experiment_runs er LEFT JOIN state_kpi_summary sk ON er.state = sk.state AND er.year = sk.year WHERE sk.state IS NULL
UNION ALL SELECT 'evaluation_results → experiment_runs orphans',COUNT(*) FROM evaluation_results evr LEFT JOIN experiment_runs er ON evr.run_id = er.run_id WHERE er.run_id IS NULL
UNION ALL SELECT 'cost_analysis → experiment_runs orphans',    COUNT(*) FROM cost_analysis ca LEFT JOIN experiment_runs er ON ca.run_id = er.run_id WHERE er.run_id IS NULL;

-- ── Nulls ───────────────────────────────────────────────────
SELECT 'null governance_composite_index' AS check_name, COUNT(*) AS issue_count FROM evaluation_results WHERE governance_composite_index IS NULL
UNION ALL SELECT 'null total_cost',       COUNT(*) FROM cost_analysis WHERE total_cost IS NULL
UNION ALL SELECT 'null input_tokens',     COUNT(*) FROM experiment_runs WHERE input_tokens IS NULL
UNION ALL SELECT 'null model pricing',    COUNT(*) FROM model_versions WHERE input_cost_per_1k_tokens IS NULL OR output_cost_per_1k_tokens IS NULL;

-- ── Duplicates ──────────────────────────────────────────────
SELECT 'duplicate cost_analysis run_id' AS check_name, COUNT(*) AS issue_count FROM (SELECT run_id FROM cost_analysis GROUP BY run_id HAVING COUNT(*) > 1) d
UNION ALL SELECT 'duplicate evaluation run_id', COUNT(*) FROM (SELECT run_id FROM evaluation_results GROUP BY run_id HAVING COUNT(*) > 1) d
UNION ALL SELECT 'duplicate state_kpi (state,year)', COUNT(*) FROM (SELECT state, year FROM state_kpi_summary GROUP BY state, year HAVING COUNT(*) > 1) d;

-- ── Business Logic ──────────────────────────────────────────
SELECT 'compliant runs (expect ~3772)'    AS check_name, COUNT(*) AS count FROM experiment_runs WHERE MOD(run_id, 10) <= 6
UNION ALL SELECT 'misallocated runs (expect ~1616)', COUNT(*) FROM experiment_runs WHERE MOD(run_id, 10) > 6
UNION ALL SELECT 'total spend ($)',       ROUND(SUM(total_cost), 2) FROM cost_analysis
UNION ALL SELECT 'avg governance score',  ROUND(AVG(governance_composite_index), 2) FROM evaluation_results
UNION ALL SELECT 'provider count',        COUNT(DISTINCT provider) FROM model_versions
UNION ALL SELECT 'governance tier count', COUNT(DISTINCT governance_level) FROM prompt_versions;

-- ── View Layer ──────────────────────────────────────────────
SELECT 'vw_governance_benchmark_base' AS view_name, COUNT(*) AS row_count FROM vw_governance_benchmark_base
UNION ALL SELECT 'vw_cost_per_governance_point', COUNT(*) FROM vw_cost_per_governance_point
UNION ALL SELECT 'vw_governance_efficiency',     COUNT(*) FROM vw_governance_efficiency
UNION ALL SELECT 'vw_provider_efficiency',       COUNT(*) FROM vw_provider_efficiency
UNION ALL SELECT 'vw_latency_cost_tradeoff',     COUNT(*) FROM vw_latency_cost_tradeoff
UNION ALL SELECT 'vw_misallocation_impact',      COUNT(*) FROM vw_misallocation_impact
UNION ALL SELECT 'vw_allocation_optimization',   COUNT(*) FROM vw_allocation_optimization
UNION ALL SELECT 'vw_provider_ranking',          COUNT(*) FROM vw_provider_ranking
UNION ALL SELECT 'vw_cost_waste_analysis',       COUNT(*) FROM vw_cost_waste_analysis
UNION ALL SELECT 'vw_model_stability_summary',   COUNT(*) FROM vw_model_stability_summary
UNION ALL SELECT 'vw_tier_compliance_summary',   COUNT(*) FROM vw_tier_compliance_summary;