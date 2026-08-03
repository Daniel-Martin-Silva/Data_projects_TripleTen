# Supply Chain & Logistics Performance Analysis

## 📌 Project Overview
This project analyzes end-to-end supply chain logistics performance to evaluate shipping delivery delays, identify high-risk fulfillment channels, and optimize regional delivery operations.

---

## 🛠️ Tech Stack & Skills
* **Google BigQuery (SQL)**: Data aggregation, filtering non-null transaction records, calculating actual vs. scheduled delay windows, and building clean view tables (`vw_cleaned_shipments`).
* **Power BI**: Star Schema data modeling (`Fact_Shipments`, `Dim_Products`, `Dim_Locations`), custom DAX measures, and dynamic report building.
* **Data Architecture**: Star Schema dimensional modeling with 1-to-Many ($1 : *$) single cross-filter relationships.

---

## 🔍 SQL Data Preparation (BigQuery)
View creation and field calculations performed prior to Power BI ingestion:

```sql
CREATE OR REPLACE VIEW `supply_chain.vw_cleaned_shipments` AS
SELECT 
  CAST(`Order Id` AS STRING) AS order_id,
  `Shipping Mode` AS shipping_mode,
  `Category Name` AS category_name,
  `Customer Country` AS customer_country,
  `Order Region` AS order_region,
  `Delivery Status` AS delivery_status,
  `Days for shipping _real_` AS actual_shipping_days,
  `Days for shipment _scheduled_` AS scheduled_shipping_days,
  (`Days for shipping _real_` - `Days for shipment _scheduled_`) AS delay_days,
  IF(`Delivery Status` = 'Late delivery', 1, 0) AS is_late_delivery,
  Sales AS sales,
  `Order Item Profit Ratio` AS profit_ratio
FROM `supply_chain.raw_shipments`;
