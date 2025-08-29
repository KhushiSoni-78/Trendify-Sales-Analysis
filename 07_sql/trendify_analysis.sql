--creating table
create table trendify_analysis(
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
)

--Total revenue
select round(sum(TotalAmount),2) as TotalRevenue
from trendify_sales;

--Monthly revenue
select to_char(OrderDate,'YYYY-MM') as Month,
Round(sum(TotalAmount),2) as Revenue,
count(distinct OrderID) as Orders
from trendify_sales
group by Month
order by Revenue desc;

--sales by region
select Region,
Round(sum(TotalAmount),2) as Revenue,
count(distinct OrderID) as Orders
from trendify_sales
group by Region
order by Revenue desc;

--Top 10 products by Revenue
select ProductName,ProductCategory,
Round(sum(TotalAmount),2) as Revenue,
count(*) as TimesSold
from trendify_sales
group by ProductName,ProductCategory
order by Revenue desc
limit 10;

--Top 10 customers by spend
select CustomerID,CustomerName,
Round(sum(TotalAmount),2) as TotalSpent,
count(distinct OrderID) as Orders
from trendify_sales
group by CustomerID,CustomerName
order by TotalSpent desc
limit 10;

--Average order value(AOV)
select avg(OrderTotal) as Aov
from(select OrderID,Round(sum(TotalAmount),2) as OrderTotal
from trendify_sales
group by OrderID);

--Payment mode distribution
select PaymentMode,count(*) as Orders,
Round(100.0*count(*)/(select count(*) from trendify_sales),2) as Percentage
from trendify_sales
group by PaymentMode
order by Orders desc;

--Units Sold by category
select ProductCategory,sum(Quantity) as UnitsSold,
Round(sum(TotalAmount),2) as Revenue
from trendify_sales
group by ProductCategory
order by UnitsSold desc;

--Monthly Top Category
select to_char(OrderDate,'YYYY-MM') AS Monthh,
ProductCategory,Round(sum(TotalAmount),2) as Revenue
from trendify_sales
group by Monthh,ProductCategory
order by Monthh,Revenue desc;

--Repeat Customers
select count(distinct CustomerID) as TotalCustomers,
sum(case when t.Orders>1 then 1 else 0 end) as RepeatCustomers,
Round(100.0*sum(case when t.Orders>1 then 1 else 0 end)/count(*)) as RepeatPercent
from
(select CustomerID,count(distinct OrderID) as Orders
from trendify_sales
group by CustomerID) t;

--full table
select* from trendify_sales;