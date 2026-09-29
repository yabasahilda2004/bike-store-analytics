# BIKE STORE SALES & INVENTORY ANALYSIS
# OVER VIEW

Analyzed revenue and sales performance, product, inventory, customer behaviour and staff performance across a multi-stor 
bike retail chain using SQL, Python, and Power BI to identify product performance, revene drivers, stock risks, and customer/staff performance patterns.

# Tools Used
SQL : Data Storage and Querying.

# Key Business Questions and findings
Revenue and Sales performance

Question1: Which product categories generate the most Revenue?
TECHNIQUE: JOIN(INNER JOIN) + GROUP BY + AGGREGATE(SUM) + MATH FUNC(ROUND)

- Mountain Bikes generate the most revenue.
- It leads the next product Road Bikes by $1049981.04.

Question2:Which Store performs best?
TECHNIQUE: INNER JOIN(3tables) + GROUP BY + AGGREGATE(SUM, COUNT DISTINCT) + MATH FUNC(ROUND) + WHERE(completed orders only) + ORDER BY

- The Baldwin Bikes Store performs best, generating the highest revenue after discounts.
- It leads the next Store Santa Cruz Bikes by $3445717.92
- This is based on revenue only; profit margin and cost data are not available.

Product and Inventory

Question1:Which products are top sellers vs slow movers?
TECHNIQUE: LEFT JOIN (3 tables) "so items that never sold also appear" + GROUP BY + AGGREGATES (SUM, COUNT) + COALESCE + WINDOW FUNCTION (NTILE) + CASE + ORDER BY

- Top 3 Top sellers are Surly Ice Cream Truck Frameset - 2016, Electra Cruiser 1 (24-Inch) - 2016 and Electra Townie Original 7D EQ- 2016 leading with the most units sold.
- Slow movers means bottom 25% compared to other products including some products that never sold a single unit in completed orders

Question2:Which products are at risk of stockout?
TECHNIQUE: CTEs (2) + INNER JOIN + LEFT JOIN + GROUP BY + AGGREGATE (SUM) + COALESCE + ARITHMETIC IN SELECT/WHERE + IN + ORDER BY

- 9 Products have 10 or less units available after accounting for pending and processing orders.
- The most at risk of stock-out is Trek Domane SLR Frameset - 2018 with only 3 units remaining.
- I would recommend prioritising restocking these products starting with the one listed as the lowest.

Customer Behaviour

Question1:Who are the top customers by total spend?
TECHNIQUE: INNER JOIN (3 tables) + GROUP BY + AGGREGATES (SUM, COUNT DISTINCT) + MATH FUNCTION (ROUND) + WHERE + ORDER BY + LIMIT

- Melanie Hayes, Shena Carter and Abram Copeland are the top three spenders with a total spend of $27050.72, $24890.62, $24607.03 and 1 order each
- This is based on completed orders only and revenue, not profit.
- The Top 10 customers together account for 3.2% of total revenue that is $213292.46

Question2: Are customers concentrated in certain states?
TECHNIQUE:GROUP BY + AGGREGATE (COUNT) + WINDOW FUNCTION (SUM OVER) + ORDER BY
 
- We find that most customers come from NewYork. A total of 1019 customers accounting for 70.5% of customers.

Staff Performance

Question1: How do staff rank by total sales within their store?
TECHNIQUE: CTE + INNER JOIN (4 tables) + GROUP BY + AGGREGATES (SUM) + WINDOW FUNCTION (RANK OVER PARTITION BY) + ORDER BY

- We find that Gena Serrano made more sales with the Santa Cruz Bikes store a total of $643627.98 sales.
- Marcelene Boyer made more sales in the Baldwin Bikes store with a total of $2405217.85 sales.
- Vargas made the most sales in the Rowlett Bikes store with a total of $375464.8 sales.
- Across all stores the top staff member at Baldwin Bikes generates more than the top staff in the other stores.
- Staff who have not completed orders do not appear and sales may reflect role differences.
