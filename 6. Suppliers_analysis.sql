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
