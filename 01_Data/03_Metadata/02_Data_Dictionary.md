# Data Dictionary  
PhonePe Fintech Performance Analytics (2018–2024)

---

## 1. Transactions Dataset

**Source:** PhonePe Pulse – Aggregated Transactions  
**Granularity:** State × Quarter × Transaction Type  

| Column Name | Data Type | Description |
|-------------|----------|-------------|
| state | String | Name of the Indian state |
| region | String | Mapped region (North, South, East, West, Central, North-East) |
| year | Integer | Calendar year |
| quarter | Integer | Quarter number (1–4) |
| year_quarter | String | Formatted quarter label (e.g., 18-Q1) |
| transaction_type | String | Type of transaction (Merchant, P2P, Recharge & Bill, Financial Services, Others) |
| transaction_count | Bigint | Total number of transactions |
| transaction_amount_rupees | Decimal | Total transaction value in INR |
| transaction_amount_crore | Decimal | Transaction value converted to Crore INR |
| avg_transaction_value | Decimal | Average transaction value (amount ÷ count) |

---

## 2. Users Dataset

**Source:** PhonePe Pulse – Aggregated Users  
**Granularity:** State × Quarter  

| Column Name | Data Type | Description |
|-------------|----------|-------------|
| state | String | Name of the Indian state |
| region | String | Region classification |
| year | Integer | Calendar year |
| quarter | Integer | Quarter number (1–4) |
| year_quarter | String | Formatted quarter label |
| registered_users | Bigint | Total registered PhonePe users |
| app_opens | Bigint | Total app opens recorded |

Derived Metrics (SQL Layer):

| Metric | Description |
|--------|-------------|
| qoq_user_growth_percent | Quarter-over-quarter growth in registered users |
| yoy_user_growth_percent | Year-over-year growth in registered users |
| qoq_app_opens_growth_percent | Quarter-over-quarter growth in app opens |
| engagement_ratio | app_opens ÷ registered_users (weighted) |

---

## 3. Insurance Dataset

**Source:** PhonePe Pulse – Aggregated Insurance  
**Granularity:** National × Quarter  

**Coverage:** Begins from 2020 Q2  

| Column Name | Data Type | Description |
|-------------|----------|-------------|
| year | Integer | Calendar year |
| quarter | Integer | Quarter number (1–4) |
| insurance_type | String | Type of insurance product |
| policy_count | Bigint | Total number of policies issued |
| insurance_amount_rupees | Decimal | Total premium value in INR |
| insurance_amount_crore | Decimal | Premium value converted to Crore INR |
| avg_policy_value | Decimal | Average policy value (premium ÷ policy count) |

---

## 4. Regional Aggregation Views

These views are created in SQL for analytical reporting.

### vw_core_quarterly_regional_transactions
Granularity: Region × Quarter  

| Column | Description |
|--------|-------------|
| total_transactions | Total transaction count per region |
| total_transaction_value_crore | Total transaction value per region |
| short_year_quarter | Display label for BI |

---

### vw_regional_growth

| Column | Description |
|--------|-------------|
| qoq_growth_transactions_percent | QoQ transaction growth % |
| yoy_growth_transactions_percent | YoY transaction growth % |
| qoq_growth_value_percent | QoQ value growth % |
| yoy_growth_value_percent | YoY value growth % |

---

### vw_regional_merchant_intensity

| Column | Description |
|--------|-------------|
| merchant_value | Merchant transaction value |
| merchant_intensity_percent | Merchant value ÷ total regional value |
| merchant_share_percent | Merchant share of total |

---

## 5. Snapshot & Ranking Views

### vw_state_leaderboard
Latest quarter state ranking by transaction value.

### vw_master_kpi_summary
Latest quarter national KPI snapshot.

### vw_historical_master_kpi
One row per quarter with aligned KPIs.

---

## Data Governance Notes

- Additive metrics → Aggregated using SUM
- Percentage metrics → Pre-calculated in SQL
- Growth metrics → Calculated using window functions (LAG)
- Engagement ratio → Weighted calculation
- No KPI logic is defined in Power BI
