
# Procurement Supplier Analytics: SQL-Based Insights for Operational Efficiency

## 🎯 Business Problem

In a manufacturing company, delays in procurement operations directly impact production schedules, inventory levels, and customer satisfaction. 
Procurement managers often struggle with:

- **Late deliveries** that disrupt production planning  
- **Unreliable lead times** causing excess safety stock  
- **Overuse of non-preferred suppliers** leading to cost inefficiencies  
- **Lack of visibility** into supplier-level performance and delivery risks

To solve these problems, we use structured **SQL analysis** across multiple procurement-related tables. The goal is to deliver **actionable insights** into supplier performance, delivery patterns, and optimization areas.

---

## 🧠 Why SQL?

SQL allows us to:
- Join multiple procurement tables (orders, suppliers, materials)
- Aggregate key KPIs by supplier and material category
- Apply advanced analytics with window functions to track delivery patterns
- Flag anomalies and risks using CASE logic
- Provide performance quartiles and ranking logic

SQL is optimal here due to its **declarative power**, ease of scaling over 1000+ POs, and direct integration into BI/reporting tools.

---

## 🧪 Data Sources (CSV Files)

| Table | Description |
|-------|-------------|
| `purchase_orders.csv` | PO-level transactions with quantity, dates, unit prices, and delivery status |
| `suppliers.csv` | Master data for supplier name, country, preferred status |
| `materials.csv` | Material name and category |
| `procurement_calendar.csv` | Working day calendar used in delivery timelines |

---

## 🔍 Business Questions and SQL Approaches

### 1️⃣ What is our total procurement volume and spend?

We start with a basic aggregation:

```sql
SELECT
    COUNT(DISTINCT po_id) AS total_pos,
    SUM(quantity * unit_price) AS total_spend
FROM purchase_orders;
```

This gives procurement leadership a top-level view of activity and cost impact.

---

### 2️⃣ Which suppliers most frequently deliver late?

```sql
SELECT
    supplier_id,
    SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS late_pct
FROM purchase_orders
GROUP BY supplier_id
ORDER BY late_pct DESC;
```

This helps identify which vendors need escalation or replacement.

---

### 3️⃣ What is the average and variability of supplier lead times?

```sql
WITH po_lead_time AS (
  SELECT
    supplier_id,
    JULIANDAY(delivery_date) - JULIANDAY(order_date) AS lead_time_days
  FROM purchase_orders
)

SELECT
  supplier_id,
  ROUND(AVG(lead_time_days), 2) AS avg_lead,
  ROUND(STDDEV(lead_time_days), 2) AS variability
FROM po_lead_time
GROUP BY supplier_id;
```

This evaluates delivery **consistency**, not just speed.

---

### 4️⃣ Which suppliers are consistent over time?

We use `LAG()` and `ROW_NUMBER()` to measure delivery gaps:

```sql
SELECT
  supplier_id,
  po_id,
  JULIANDAY(order_date) - JULIANDAY(LAG(order_date) OVER (PARTITION BY supplier_id ORDER BY order_date)) AS days_between_orders
FROM purchase_orders;
```

Then we rank suppliers into **quartiles** with `NTILE(4)`.

---

### 5️⃣ Which orders are at risk of causing stockouts?

```sql
SELECT
  *,
  CASE WHEN (JULIANDAY(delivery_date) - JULIANDAY(order_date)) > 20 THEN '⚠️ At Risk' ELSE '✅ Safe' END AS risk_flag
FROM purchase_orders;
```

This proactive flag supports inventory planning and buffer adjustments.

---

### 6️⃣ Are we overusing non-preferred suppliers?

```sql
SELECT
  supplier_id,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM purchase_orders WHERE material_id = p.material_id) AS usage_pct
FROM purchase_orders p
JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE s.is_preferred = FALSE;
```

If usage > 20%, we recommend **supplier consolidation** to improve compliance and reduce costs.

---

## 🏁 Conclusion

Using SQL across multiple procurement datasets, we:

- Quantified supplier performance with custom KPIs
- Applied advanced logic with `CASE`, `LAG`, `STDDEV`, and `NTILE`
- Flagged potential stockout risks and process inefficiencies
- Provided a robust framework for supplier-based decision-making

This analysis can be directly translated into dashboards, monthly reviews, and sourcing strategies.

