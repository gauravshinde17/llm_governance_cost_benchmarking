# Data Assumptions & Governance Notes  
PhonePe Fintech Performance Analytics (2018–2024)

---

## 1. Data Source Integrity

All datasets are sourced from the PhonePe Pulse public data repository.

The raw JSON files are stored without modification in the `01_Raw_API` directory.  
All transformations occur only during the structured ETL process before SQL loading.

No synthetic or manually fabricated data has been introduced.

---

## 2. Time Coverage Assumptions

- Transaction and user data span from **2018 Q1 to 2024 Q4**.
- Insurance data begins from **2020 Q2**.
- Missing insurance data prior to 2020 Q2 is expected and not treated as data loss.

---

## 3. Aggregation Rules

To maintain analytical correctness:

- Additive metrics (transactions, value, users) → **SUM**
- Growth metrics (QoQ %, YoY %) → Pre-calculated in SQL using `LAG()` window functions
- Percentage metrics (share %, intensity %) → Never blindly summed
- Engagement ratio → Calculated as weighted ratio:
  

---

## 4. Latest Quarter Logic

KPI cards represent the **latest available quarter**.

Snapshot views in SQL ensure:
- No mixing of historical and current metrics
- Consistent filter behavior across dashboards

---

## 5. Non-Additive Metric Handling

The following metrics are treated as non-additive:

- Merchant Share %
- P2P Share %
- Regional Growth %
- Engagement Ratio
- Value Share %
- Transaction Share %

These are either:
- Calculated at correct grain in SQL
- Or computed using controlled denominator logic in Power BI

---

## 6. Regional Classification

States are mapped to 6 predefined regions:

- North
- South
- East
- West
- Central
- North-East

Mapping is maintained in `Region_Mapping.md`.

---

## 7. Governance Principles

- No business KPIs are calculated in Power BI.
- SQL defines all business logic.
- Window functions are used for growth computation.
- Manual relationships are enforced in BI model.
- No many-to-many relationships are allowed.
- No auto-detected relationships are used.

---

## 8. Scope Limitation

Insurance data is modeled within the warehouse layer  
but is currently reserved for future analytical expansion  
and not visualized in the final dashboard suite.

---

This project follows warehouse-first analytical discipline  
and prioritizes metric governance over visual complexity.
