
-- ======================================================
-- 📁 FILE: 04_lead_time_variability.sql
-- 🎯 PURPOSE: Supplier Performance Using Window Functions
-- ======================================================

WITH po_ordered AS (
    SELECT
        po_id,
        supplier_id,
        order_date,
        delivery_date,
        quantity,
        ROW_NUMBER() OVER (PARTITION BY supplier_id ORDER BY order_date) AS delivery_sequence
    FROM
        purchase_orders
),
po_with_lag AS (
    SELECT
        po_id,
        supplier_id,
        order_date,
        delivery_date,
        quantity,
        delivery_sequence,
        LAG(order_date) OVER (PARTITION BY supplier_id ORDER BY order_date) AS previous_order_date
    FROM
        po_ordered
),
final_analysis AS (
    SELECT
        supplier_id,
        po_id,
        order_date,
        delivery_date,
        delivery_sequence,
        previous_order_date,
        JULIANDAY(order_date) - JULIANDAY(previous_order_date) AS days_between_orders
    FROM
        po_with_lag
)

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(f.po_id) AS number_of_orders,
    ROUND(AVG(f.days_between_orders), 2) AS avg_days_between_orders,
    ROUND(STDDEV(f.days_between_orders), 2) AS consistency_score,
    NTILE(4) OVER (ORDER BY ROUND(STDDEV(f.days_between_orders), 2)) AS performance_quartile
FROM
    final_analysis f
JOIN
    suppliers s ON f.supplier_id = s.supplier_id
GROUP BY
    s.supplier_id, s.supplier_name
ORDER BY
    performance_quartile ASC;
