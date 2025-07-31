
-- ========================================
-- 📁 FILE: 01_basic_metrics.sql
-- 🎯 PURPOSE: Basic Procurement KPIs
-- ========================================

-- 1️⃣ Total purchase orders, total quantity, total spend
SELECT
    COUNT(DISTINCT po_id) AS total_pos,
    SUM(quantity) AS total_units_ordered,
    SUM(quantity * unit_price) AS total_spend
FROM
    purchase_orders;

-- 2️⃣ Top 5 suppliers by total spend
SELECT
    po.supplier_id,
    s.supplier_name,
    s.country,
    s.is_preferred,
    SUM(po.quantity * po.unit_price) AS supplier_spend,
    COUNT(DISTINCT po.po_id) AS number_of_orders
FROM
    purchase_orders po
JOIN
    suppliers s ON po.supplier_id = s.supplier_id
GROUP BY
    po.supplier_id, s.supplier_name, s.country, s.is_preferred
ORDER BY
    supplier_spend DESC
LIMIT 5;

-- 3️⃣ Top 5 most frequently ordered materials
SELECT
    po.material_id,
    m.material_name,
    m.category,
    COUNT(po.po_id) AS times_ordered,
    SUM(po.quantity) AS total_quantity_ordered
FROM
    purchase_orders po
JOIN
    materials m ON po.material_id = m.material_id
GROUP BY
    po.material_id, m.material_name, m.category
ORDER BY
    times_ordered DESC
LIMIT 5;
