# Region Mapping Reference  
PhonePe Fintech Performance Analytics (2018–2024)

---

## Purpose

This document defines the standardized regional classification used across:

- Data warehouse dimension tables
- SQL aggregation views
- Power BI dashboards
- Structural dominance analysis
- Growth comparison matrices

All states are mapped to one of six analytical regions to ensure consistent aggregation.

---

## Region Classification Framework

The project uses a 6-region model:

1. North
2. South
3. East
4. West
5. Central
6. North-East

This mapping is fixed and used in `dim_region` and `dim_state`.

---

## State-to-Region Mapping

### North
- Delhi
- Haryana
- Himachal Pradesh
- Jammu & Kashmir
- Punjab
- Uttar Pradesh
- Uttarakhand

---

### South
- Andhra Pradesh
- Karnataka
- Kerala
- Tamil Nadu
- Telangana

---

### East
- Bihar
- Jharkhand
- Odisha
- West Bengal

---

### West
- Gujarat
- Maharashtra
- Rajasthan
- Goa

---

### Central
- Madhya Pradesh
- Chhattisgarh

---

### North-East
- Arunachal Pradesh
- Assam
- Manipur
- Meghalaya
- Mizoram
- Nagaland
- Sikkim
- Tripura

---

## Governance Rules

- Region classification is static and not dynamically derived.
- Regional aggregations in SQL depend on this mapping.
- No region-level metric is calculated without consistent state mapping.
- All dashboards use `dim_region` for filtering.

---

## Analytical Importance

Regional mapping enables:

- Structural dominance analysis
- Growth dispersion evaluation
- Engagement intensity comparison
- Monetization distribution tracking
- Concentration and hierarchy assessment

This mapping ensures analytical consistency across all dashboards and views.
