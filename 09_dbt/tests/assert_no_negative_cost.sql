-- Custom test: assert no negative total_cost in mart_cost_waste_summary
-- A negative total_cost indicates a data pipeline error
-- This test returns rows that FAIL — dbt expects 0 rows for a passing test

select
    provider,
    governance_level,
    allocation_status,
    avg_actual_cost
from {{ ref('mart_cost_waste_summary') }}
where avg_actual_cost < 0