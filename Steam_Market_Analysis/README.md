# 🎮 Steam Market & Pricing Strategy Analysis

## 📌 Business Scenario & Overview
This project evaluates the commercial PC gaming landscape across **27,000+ Steam titles** to assist an independent game publisher with a **$250,000 budget** in making data-driven development and go-to-market decisions. 

The analysis identifies high-revenue genre opportunities, optimal pricing tier strategies, and key market saturation trends across release years.

---

## 🛠️ Tech Stack & Skills
* **Google BigQuery (SQL)**: Advanced array handling (`SPLIT`, `UNNEST`), date parsing, conditional price segmentation (`CASE WHEN`), and revenue estimation using the Boxleiter Method ($30 \times \text{Reviews}$).
* **Power BI**: Star Schema dimensional modeling ($1 : *$), bidirectional cross-filtering between dimension views, and custom DAX metrics.
* **Commercial Strategy**: Price elasticity, genre market saturation analysis, and player sentiment evaluation.

---

## 🔍 SQL Data Preparation (Google BigQuery)
Data cleaning and view transformations executed in BigQuery prior to BI ingestion:

```sql
-- 1. Main Cleaned Games View
CREATE OR REPLACE VIEW `steam_analytics.vw_cleaned_steam_games` AS
SELECT
  CAST(appid AS INT64) AS game_id,
  TRIM(name) AS game_name,
  SAFE_CAST(release_date AS DATE) AS release_date,
  EXTRACT(YEAR FROM SAFE_CAST(release_date AS DATE)) AS release_year,
  price,
  CASE
    WHEN price = 0 THEN 'Free-to-Play'
    WHEN price > 0 AND price < 5 THEN '$0.01 - $4.99'
    WHEN price >= 5 AND price < 10 THEN '$5.00 - $9.99'
    WHEN price >= 10 AND price < 20 THEN '$10.00 - $19.99'
    ELSE '$20.00+'
  END AS price_tier,
  positive_ratings,
  negative_ratings,
  (positive_ratings + negative_ratings) AS total_reviews,
  ROUND(SAFE_DIVIDE(positive_ratings, (positive_ratings + negative_ratings)), 4) AS positive_ratio,
  ROUND(((positive_ratings + negative_ratings) * 30) * price, 2) AS est_revenue
FROM `steam_analytics.raw_steam_games`
WHERE name IS NOT NULL AND release_date IS NOT NULL;

-- 2. Genre Dimension View (Unnesting Multi-Value Strings)
CREATE OR REPLACE VIEW `steam_analytics.vw_game_genres` AS
SELECT
  CAST(appid AS INT64) AS game_id,
  TRIM(genre_name) AS genre_name
FROM `steam_analytics.raw_steam_games`,
UNNEST(SPLIT(genres, ';')) AS genre_name;
