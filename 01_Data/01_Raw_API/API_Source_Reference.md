# Raw Data Source Reference  

PhonePe Fintech Performance Analytics (2018–2024)

---

## 1. Official Data Repository

All raw datasets used in this project are sourced from the official PhonePe Pulse public repository:

GitHub Repository:
https://github.com/PhonePe/pulse

Data Directory:
https://github.com/PhonePe/pulse/tree/master/data

Official Website:
https://www.phonepe.com/pulse/

---

## 2. Datasets Used

The following aggregated datasets were used:

- aggregated/transaction (State-level)
- aggregated/user (State-level)
- aggregated/insurance (National-level)

---

## 3. Time Coverage

- Transactions & Users: 2018 Q1 – 2024 Q4
- Insurance: 2020 Q2 – 2024 Q4

Insurance data prior to 2020 Q2 is not available in the public repository.

---

## 4. Ingestion Methodology

Raw JSON files were programmatically fetched and flattened using Python.

Steps performed:

1. Iterated year × quarter directories
2. Extracted nested transaction and user objects
3. Standardized column names
4. Validated record counts
5. Exported structured CSV files for warehouse loading

---

## 5. Storage Policy

Raw JSON snapshots were stored locally during ingestion  
and are not included in this repository to avoid redundancy and size inflation.

All analytical outputs are derived strictly from official PhonePe Pulse data.

---

This project maintains full traceability to the original public data source.
