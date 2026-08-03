-- =============================================================================
-- Project: Supply Chain & Logistics Performance Analysis
-- Database: Google BigQuery
-- Description: End-to-end data preparation pipeline including summary checks,
--              delay calculations, and view creation for Power BI.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Step 1: Delivery Performance Summary
-- Inspects total order counts and delivery status distribution across categories.
-- -----------------------------------------------------------------------------
SELECT 
  `Category Name` AS category_name,
  `Delivery Status` AS delivery_status,
  COUNT(`Order Id`) AS total_orders,
  ROUND(AVG(Sales), 2) AS avg_sales
FROM `supply_chain.raw_shipments`
GROUP BY 1, 2
ORDER BY total_orders DESC;


-- -----------------------------------------------------------------------------
-- Step 2: Shipping Delay Calculation
-- Calculates actual vs. scheduled delivery days and isolates late orders.
-- -----------------------------------------------------------------------------
SELECT 
  `Order Id` AS order_id,
  `Shipping Mode` AS shipping_mode,
  `Days for shipping _real_` AS actual_days,
  `Days for shipment _scheduled_` AS scheduled_days,
  (`Days for shipping _real_` - `Days for shipment _scheduled_`) AS delay_days,
  IF(`Delivery Status` = 'Late delivery', 1, 0) AS is_late_delivery,
  Sales AS sales
FROM `supply_chain.raw_shipments`
WHERE Sales IS NOT NULL;


-- -----------------------------------------------------------------------------
-- Step 3: Production View Creation for Power BI Ingestion
-- Creates a cleaned view table (`vw_cleaned_shipments`) with standard field names
-- and calculated metrics ready for BI connection.
-- -----------------------------------------------------------------------------
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