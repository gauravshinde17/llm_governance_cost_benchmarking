-- Custom test: assert governance_composite_index is within 0-100 range
-- Scores outside this range indicate a scoring logic error
-- This test returns rows that FAIL — dbt expects 0 rows for a passing test

select
    run_id,
    provider,
    governance_level,
    governance_composite_index
from {{ ref('int_governance_benchmark_base') }}
where governance_composite_index < 0
   or governance_composite_index > 100