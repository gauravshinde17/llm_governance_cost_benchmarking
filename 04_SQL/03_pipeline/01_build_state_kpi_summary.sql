USE llm_governance_fintech;

INSERT INTO state_kpi_summary
(
    state,
    year,
    total_transaction_value_rupees,
    total_transaction_count,
    yoy_value_growth,
    yoy_count_growth,
    state_value_rank,
    state_growth_rank,
    top_transaction_type,
    top_transaction_type_share,
    anomaly_flag,
    data_version,
    kpi_hash
)

WITH yearly AS (
    SELECT
        state,
        year,
        SUM(transaction_amount_rupees) AS total_value,
        SUM(transaction_count) AS total_count
    FROM phonepe_transactions_staging
    GROUP BY state, year
),

yoy_calc AS (
    SELECT
        curr.state,
        curr.year,
        curr.total_value,
        curr.total_count,
        ROUND(
            ((curr.total_value - prev.total_value) / prev.total_value) * 100,
            2
        ) AS yoy_value_growth,
        ROUND(
            ((curr.total_count - prev.total_count) / prev.total_count) * 100,
            2
        ) AS yoy_count_growth
    FROM yearly curr
    LEFT JOIN yearly prev
        ON curr.state = prev.state
        AND curr.year = prev.year + 1
),

ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY year
            ORDER BY total_value DESC
        ) AS value_rank,
        RANK() OVER (
            PARTITION BY year
            ORDER BY yoy_value_growth DESC
        ) AS growth_rank
    FROM yoy_calc
),

top_type AS (
    SELECT
        state,
        year,
        transaction_type,
        SUM(transaction_amount_rupees) AS type_value,
        SUM(transaction_amount_rupees) /
        SUM(SUM(transaction_amount_rupees)) OVER (PARTITION BY state, year)
        AS share_ratio,
        RANK() OVER (
            PARTITION BY state, year
            ORDER BY SUM(transaction_amount_rupees) DESC
        ) AS type_rank
    FROM phonepe_transactions_staging
    GROUP BY state, year, transaction_type
),

top_type_final AS (
    SELECT
        state,
        year,
        transaction_type,
        ROUND(share_ratio * 100, 2) AS share_percent
    FROM top_type
    WHERE type_rank = 1
)

SELECT
    r.state,
    r.year,
    r.total_value,
    r.total_count,
    IFNULL(r.yoy_value_growth, 0),
    IFNULL(r.yoy_count_growth, 0),
    r.value_rank,
    IFNULL(r.growth_rank, 0),
    t.transaction_type,
    t.share_percent,

    CASE
        WHEN r.yoy_value_growth > 40 THEN TRUE
        WHEN r.yoy_value_growth < -20 THEN TRUE
        ELSE FALSE
    END AS anomaly_flag,

    'v1_yearly_full_build' AS data_version,

    SHA2(
        CONCAT(r.state, r.year, r.total_value, r.total_count),
        256
    ) AS kpi_hash

FROM ranked r
JOIN top_type_final t
    ON r.state = t.state
    AND r.year = t.year;
    
    
    


SELECT *
FROM state_kpi_summary
ORDER BY year, state_value_rank
LIMIT 20;
    