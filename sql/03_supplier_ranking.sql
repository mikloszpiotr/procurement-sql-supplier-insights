
-- ============================================
-- 📁 FILE: 03_supplier_ranking.sql
-- 🎯 PURPOSE: Supplier Lead Time Variability & Ranking
-- ============================================

WITH po_with_lead_time AS (
    SELECT
        po_id,
        supplier_id,
        order_date,
        delivery_date,
        JULIANDAY(delivery_date) - JULIANDAY(order_date) AS lead_time_days
    FROM
        purchase_orders
)

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(p.po_id) AS total_orders,
    ROUND(AVG(p.lead_time_days), 2) AS avg_lead_time_days,
    ROUND(STDDEV(p.lead_time_days), 2) AS stddev_lead_time_days
FROM
    po_with_lead_time p
JOIN
    suppliers s ON p.supplier_id = s.supplier_id
GROUP BY
    s.supplier_id, s.supplier_name
ORDER BY
    stddev_lead_time_days ASC;
