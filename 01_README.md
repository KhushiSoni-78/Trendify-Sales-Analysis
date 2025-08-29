# Trendify Sales Analysis — End‑to‑End Portfolio Project

This repository contains an end‑to‑end **Retail/E‑commerce Sales Analysis** built from a 3,000‑row mini dataset and delivered with **PostgreSQL + Excel**.

## 1) Business Requirements (Client Demands)
**Sales Analysis**
- Total sales revenue (monthly & overall)
- Best‑selling **product categories** and **items**
- **Sales by region**
- **Payment mode** preferences

**Customer Insights**
- **Unique customers**
- **Repeat vs one‑time buyers**
- Region‑wise customer trends

**Management Dashboard (Excel)**
- Monthly Sales Trend (line chart)
- Top Products & Categories (bar charts)
- Region‑wise Sales (bar chart)
- Payment Mode split (pie chart)
- At‑a‑glance KPIs: **Total Sales**, **Total Orders**, **Total Customers**, **Average Order Value (AOV)**

**Database Queries (SQL)**
- Monthly revenue
- Top 5 products by revenue
- Region with highest sales
- Average order value (AOV)
- Top 10 loyal customers (highest spend / repeat orders)

**Final Deliverables**
- SQL scripts (`trendify_analysis.sql`)
- Excel dashboard (`Trendify_sales.xlsb.xlsx`)
- This README (business case + dataset + insights)

---

## 2) Dataset
- File: `trendify_mini_ecommerce_3000.csv`
- Fields (typical): `OrderID, OrderDate, CustomerID, CustomerName, Region, ProductCategory, ProductName, Quantity, UnitPrice, TotalAmount, PaymentMode`

> Note: `TotalAmount = Quantity * UnitPrice` in the prepared data.

---

## 3) PostgreSQL Setup

### 3.1 Create Table
```sql
CREATE TABLE trendify_sales (
  OrderID TEXT PRIMARY KEY,
  OrderDate TIMESTAMP,
  CustomerID TEXT,
  CustomerName TEXT,
  Region TEXT,
  ProductCategory TEXT,
  ProductName TEXT,
  Quantity INT,
  UnitPrice NUMERIC(10,2),
  TotalAmount NUMERIC(12,2),
  PaymentMode TEXT
);
```

### 3.2 Load Data
Using `COPY` (adjust absolute path and permissions per your system):
```sql
COPY trendify_sales
FROM '/absolute/path/to/trendify_mini_ecommerce_3000.csv'
DELIMITER ',' CSV HEADER;
```

---

## 4) Core SQL Queries (PostgreSQL)

> A full script is provided in `trendify_analysis.sql`. Below are the **exact queries** that satisfy each requirement.

### 4.1 Total Revenue (overall & monthly)
**Overall**
```sql
SELECT ROUND(SUM(TotalAmount), 2) AS total_revenue
FROM trendify_sales;
```
**Monthly**
```sql
SELECT TO_CHAR(OrderDate, 'YYYY-MM') AS month,
       ROUND(SUM(TotalAmount), 2) AS revenue,
       COUNT(DISTINCT OrderID) AS orders
FROM trendify_sales
GROUP BY month
ORDER BY month;
```

### 4.2 Best‑Selling Categories & Items
**Top Categories by Revenue**
```sql
SELECT ProductCategory,
       ROUND(SUM(TotalAmount), 2) AS revenue,
       SUM(Quantity) AS units_sold
FROM trendify_sales
GROUP BY ProductCategory
ORDER BY revenue DESC;
```
**Top 5 Products by Revenue**
```sql
SELECT ProductName, ProductCategory,
       ROUND(SUM(TotalAmount), 2) AS revenue,
       COUNT(*) AS times_sold
FROM trendify_sales
GROUP BY ProductName, ProductCategory
ORDER BY revenue DESC
LIMIT 5;
```

### 4.3 Sales by Region (find the best region)
```sql
SELECT Region,
       ROUND(SUM(TotalAmount), 2) AS revenue,
       COUNT(DISTINCT OrderID) AS orders
FROM trendify_sales
GROUP BY Region
ORDER BY revenue DESC
LIMIT 1;  -- Highest revenue region
```

### 4.4 Average Order Value (AOV)
```sql
WITH order_totals AS (
  SELECT OrderID, ROUND(SUM(TotalAmount), 2) AS order_total
  FROM trendify_sales
  GROUP BY OrderID
)
SELECT ROUND(AVG(order_total), 2) AS aov
FROM order_totals;
```

### 4.5 Top 10 Loyal Customers
(Loyalty defined by **highest spend**; also available by **repeat orders**.)
```sql
-- Highest total spend
SELECT CustomerID, CustomerName,
       ROUND(SUM(TotalAmount), 2) AS total_spent,
       COUNT(DISTINCT OrderID) AS orders
FROM trendify_sales
GROUP BY CustomerID, CustomerName
ORDER BY total_spent DESC
LIMIT 10;

-- Most repeat orders (optional alt)
SELECT CustomerID, CustomerName, COUNT(DISTINCT OrderID) AS orders
FROM trendify_sales
GROUP BY CustomerID, CustomerName
ORDER BY orders DESC
LIMIT 10;
```

### 4.6 Payment Mode Preferences
```sql
SELECT PaymentMode,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM trendify_sales), 2) AS percentage
FROM trendify_sales
GROUP BY PaymentMode
ORDER BY orders DESC;
```

### 4.7 Repeat vs One‑time Buyers
```sql
WITH cust AS (
  SELECT CustomerID, COUNT(DISTINCT OrderID) AS orders
  FROM trendify_sales
  GROUP BY CustomerID
)
SELECT COUNT(*) FILTER (WHERE orders > 1) AS repeat_customers,
       COUNT(*) FILTER (WHERE orders = 1) AS one_time_customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE orders > 1) / COUNT(*), 2) AS repeat_pct
FROM cust;
```

---

## 5) Excel Management Dashboard

- File: `Trendify_sales.xlsb.xlsx`
- Interactive slicers for `ProductCategory`, `Region`, and `PaymentMode`.
- Charts and KPIs:
  - **Monthly Sales Trend** (line) — `Monthly.png`
  - **Top Categories** (bar) — `Category.png`
  - **Top 10 Products** (bar) — `TopProducts.png`
  - **Payment Mode Split** (pie) — `Payment.png`
  - **KPI Cards**: Total Sales, Orders, Customers, and AOV

### Preview
![Dashboard](trendify_dashboard.png)
![Monthly Revenue](Monthly.png)
![Top 10 Products](TopProducts.png)
![Top Category](Category.png)
![Payment Mode](Payment.png)

---

## 6) Key Insights (from current build)
- **UPI ≈ 50%** of orders; **Credit Card ≈ 30%** → digital first.
- **Clothing & Shoes** dominate category revenue; **Accessories** lag.
- **North & South** regions lead revenue.
- **May** peaks, **June** dips — seasonality worth investigating.
- **AOV ≈ ₹1,694** (from current dataset/dashboard).

---

## 7) How to Reproduce
1. Create the table (Section 3.1) and import the CSV (3.2).
2. Run `trendify_analysis.sql` to generate analysis tables/outputs.
3. Open `Trendify_sales.xlsb.xlsx` → refresh PivotTables → interact with slicers.
4. Compare/validate KPIs in Excel with SQL outputs.

---

## 8) Project Structure
```
/Trendify
 ├─ trendify_analysis.sql
 ├─ Trendify_sales.xlsb.xlsx
 ├─ trendify_mini_ecommerce_3000.csv
 ├─ README_Trendify_Project.md
 └─ images (Dashboard, Monthly, TopProducts, Category, Payment)
```

---

## 9) Attribution
Built for a business stakeholder requesting a compact retail analytics pack with **PostgreSQL + Excel**. Dashboards and SQL created by the project author.
