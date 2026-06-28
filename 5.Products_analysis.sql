WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(f.revenue) AS total_revenue
    FROM dim_product p
    JOIN fact_order_items f ON p.product_id = f.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
total AS (
    SELECT SUM(total_revenue) AS grand_total FROM product_revenue
),
cumulative AS (
    SELECT
        pr.product_id,
        pr.product_name,
        pr.category,
        pr.total_revenue,
        SUM(pr.total_revenue) OVER (ORDER BY pr.total_revenue DESC) AS cumulative_revenue,
        t.grand_total
    FROM product_revenue pr, total t
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue,
    ROUND(cumulative_revenue * 100.0 / grand_total, 2) AS cumulative_pct,
    CASE
        WHEN cumulative_revenue * 100.0 / grand_total <= 70 THEN 'A'
        WHEN cumulative_revenue * 100.0 / grand_total <= 90 THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM cumulative
ORDER BY total_revenue DESC;
