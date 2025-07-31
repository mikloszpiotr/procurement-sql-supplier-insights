
-- ========================================
-- 📁 FILE: 02_late_delivery_analysis.sql
-- 🎯 PURPOSE: Late Delivery Analysis by Supplier
-- ========================================

SELECT
    delivery_status,
    COUNT(*) AS delivery_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM
    purchase_orders
GROUP BY
    delivery_status;

SELECT
    po.supplier_id,
    s.supplier_name,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN po.delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_deliveries,
    ROUND(SUM(CASE WHEN po.delivery_status = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_pct
FROM
    purchase_orders po
JOIN
    suppliers s ON po.supplier_id = s.supplier_id
GROUP BY
    po.supplier_id, s.supplier_name
ORDER BY
    late_pct DESC;
