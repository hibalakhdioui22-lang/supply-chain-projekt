  ABC ANALYSE - LIEFERANTEN
-- Gewichteter Score:
--   Qualität 40% + Zuverlässigkeit 35% + Preis 25%
-- ============================================================


WITH scored AS (
    SELECT
        supplier_id,
        supplier_name,
        country,
        quality_score,
        price_score,
        reliability_score,
        ROUND(
            (quality_score * 0.40) +
            (reliability_score * 0.35) +
            (price_score * 0.25),
        2) AS weighted_score
    FROM suppliers
),
total AS (
    SELECT SUM(weighted_score) AS grand_total FROM scored
),
cumulative AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.country,
        s.quality_score,
        s.reliability_score,
        s.price_score,
        s.weighted_score,
        SUM(s.weighted_score) OVER (ORDER BY s.weighted_score DESC) AS cumulative_score,
        t.grand_total
    FROM scored s, total t
)
SELECT
    supplier_id,
    supplier_name,
    country,
    quality_score,
    reliability_score,
    price_score,
    weighted_score,
    ROUND(cumulative_score * 100.0 / grand_total, 1) AS cumulative_pct,
    CASE
        WHEN cumulative_score * 100.0 / grand_total <= 70 THEN 'A'
        WHEN cumulative_score * 100.0 / grand_total <= 90 THEN 'B'
        ELSE                                                    'C'
    END AS abc_class
FROM cumulative
ORDER BY weighted_score DESC;

--  BONUS: Lieferanten + Umsatz kombiniert
-- Wer liefert am meisten Umsatz UND hat den besten Score?
-- ============================================================

WITH supplier_revenue AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.quality_score,
        s.reliability_score,
        s.price_score,
        ROUND((s.quality_score * 0.40) + (s.reliability_score * 0.35) + (s.price_score * 0.25), 2) AS weighted_score,
        SUM(f.revenue) AS total_revenue,
        COUNT(DISTINCT f.order_id) AS total_orders
    FROM suppliers s
    JOIN dim_product p ON s.supplier_id = p.supplier_id
    JOIN fact_order_items f ON p.product_id = f.product_id
    GROUP BY s.supplier_id, s.supplier_name
)
SELECT
    supplier_name,
    weighted_score,
    total_revenue,
    total_orders,
    CASE
        WHEN weighted_score >= 8.0 THEN 'A'
        WHEN weighted_score >= 7.0 THEN 'B'
        ELSE                            'C'
    END AS abc_class
FROM supplier_revenue
ORDER BY total_revenue DESC;

