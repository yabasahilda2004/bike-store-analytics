-- CREATING A DATABASE FOR MY PROJECT WHERE MY PYTHON SCRIPT CONNECTION STRING WILL POINT AT

CREATE DATABASE project1_raw;
CREATE DATABASE project1;
USE project1;


               -- REVENUE AND SALES PERFORMANCE
               
-- QUESTION1: WHICH PRODUCT CATEGORIES GENERATE THE MOST REVENUE?
-- TECHNIQUE: JOIN(INNER JOIN) + GROUP BY + AGGREGATE(SUM) + MATH FUNC(ROUND)

SELECT*
FROM order_items; -- contains product_id, list_price and dicount which is used to calculate Revenue.

SELECT*
FROM categories;

SELECT*
FROM products; -- contains category_id

SELECT
category_name,
ROUND(SUM(o_items.quantity * prod.list_price * (1-o_items.discount)), 2) AS total_revenue
FROM order_items AS o_items
JOIN products AS prod
	ON o_items.product_id = prod.product_id
JOIN categories AS cat 
    ON prod.category_id = cat.category_id
GROUP BY category_name
ORDER BY total_revenue DESC;

-- CONCLUSION:
-- Mountain Bikes generate the most revenue.
-- It leads the next product Road Bikes by $1049981.04.


-- QUESTION2: WHICH STORE PERFORMS BEST?
-- METRIC: Best = Highest Total Revenue (quantity * list_price * (1-discount))
-- TECHNIQUE: INNER JOIN(3tables) + GROUP BY + AGGREGATE(SUM, COUNT DISTINCT) + MATH FUNC(ROUND) + WHERE(completed orders only) + ORDER BY

SELECT*
FROM ORDERS;

SELECT*
FROM ORDER_ITEMS;

SELECT*
FROM STORES;

SELECT DISTINCT order_status
FROM orders; 

SELECT
	s.store_id,
    s.store_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity* oi.list_price *(1 - oi.discount)),2) AS total_revenue
FROM orders AS o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores s ON o.store_id = s.store_id
WHERE o.order_status = 4
GROUP BY s.store_id, s.store_name
ORDER BY total_revenue DESC;

-- CONCLUSION:
-- The Baldwin Bikes Store performs best, generating the highest revenue after discounts.
-- It leads the next Store Santa Cruz Bikes by $3445717.92
-- This is based on revenue only; profit margin and cost data are not available.

               -- PRODUCT AND INVENTORY
-- QUESTION1: WHICH PRODUCTS ARE TOP SELLERS VS SLOW MOVERS?
-- METRIC: Units sold and revenue per product
-- TECHNIQUE: LEFT JOIN (3 tables) "so items that never sold also appear" + GROUP BY + AGGREGATES (SUM, COUNT) + COALESCE + WINDOW FUNCTION (NTILE) + CASE + ORDER BY

SELECT*
FROM PRODUCTS;

SELECT*
FROM order_items;

SELECT*
FROM ORDERS;

SELECT
	p.product_id,
	p.product_name,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    ROUND(COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),0), 2) AS total_revenue,
	CASE NTILE(4) OVER (ORDER BY COALESCE(SUM(oi.quantity), 0) DESC)
		WHEN 1 THEN 'Top Seller'
        WHEN 4 THEN 'Slow mover'
        ELSE 'Mid Performer'
	END AS sales_tier
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status = 4
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC;

-- CONCLUSION:
-- Top 3 Top sellers are Surly Ice Cream Truck Frameset - 2016, Electra Cruiser 1 (24-Inch) - 2016 and Electra Townie Original 7D EQ - 2016 leading with the most units sold.
-- Slow movers means bottom 25% compared to other products including some products that never sold a single unit in completed orders

-- QUESTION2: WHICH PRODUCTS ARE AT RISK OF STOCKOUT?
-- METRIC: Available stock = units on hand - units committed (pending or processing)
-- TECHNIQUE: CTEs (2) + INNER JOIN + LEFT JOIN + GROUP BY + AGGREGATE (SUM) + COALESCE + ARITHMETIC IN SELECT/WHERE + IN + ORDER BY
-- NOTE:Only unfulfilled orders (status 1 = Pending, 2 = Processing) are subtracted. Completed sales are already reflected in stocks.
-- LEFT JOIN keeps products with no open orders, COALESCE turns their NULL into 0.Products available below 10 are considered being at the risk of stock out.
SELECT*
FROM STOCKS;

SELECT*
FROM ORDERS;

SELECT*
FROM ORDER_ITEMS;

WITH stock_on_hand AS (
    SELECT product_id,
    SUM(quantity) AS units_on_hand
    FROM stocks
    GROUP BY product_id
),
committed AS (
    SELECT oi.product_id,
    SUM(oi.quantity) AS units_committed
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status IN (1, 2) -- Taking status 1-Pending, 2-Processing, 3-Rejected, 4-Completed and reflected in stocks
    GROUP BY oi.product_id
)
SELECT
    p.product_name,
    s.units_on_hand,
    COALESCE(c.units_committed, 0) AS units_committed,
    s.units_on_hand - COALESCE(c.units_committed, 0) AS available_after_orders
FROM stock_on_hand s
JOIN products p ON s.product_id = p.product_id
LEFT JOIN committed c ON s.product_id = c.product_id
WHERE s.units_on_hand - COALESCE(c.units_committed, 0) <= 10
ORDER BY available_after_orders ASC;

    
-- CONCLUSION:
-- 9 Products have 10 or less units available after accounting for pending and processing orders.
-- The most at risk of stock-out is Trek Domane SLR Frameset - 2018 with only 3 units remaining.
-- I would recommend prioritising restocking these products starting with the one listed as the lowest.

            -- CUSTOMER BEHAVIOUR
-- QUESTION1: WHO ARE THE TOP CUSTOMERS BY TOTAL SPEND?
-- METRIC: Net revenue per customer (quantity * list_price * (1 - discount))
-- TECHNIQUE: INNER JOIN (3 tables) + GROUP BY + AGGREGATES (SUM, COUNT DISTINCT) + MATH FUNCTION (ROUND) + WHERE + ORDER BY + LIMIT
-- NOTE: Completed orders only. This shows the top 10 only.
 SELECT *
 FROM customers;

SELECT *
FROM orders;

SELECT *
FROM order_items;

SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_spend
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_spend DESC
LIMIT 10;

-- Conclusion:
-- Melanie Hayes, Shena Carter and Abram Copeland are the top three spenders with a total spend of $27050.72, $24890.62, $24607.03 and 1 order each
-- This is based on completed orders only and revenue, not profit.

WITH customer_spend AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spend
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY o.customer_id
),
top10 AS (
    SELECT total_spend
    FROM customer_spend
    ORDER BY total_spend DESC
    LIMIT 10
)
SELECT
    ROUND(SUM(total_spend), 2) AS top10_spend,
    ROUND(100.0 * SUM(total_spend) / (SELECT SUM(total_spend) FROM customer_spend), 1) AS percentage_of_total
FROM top10;

-- CONCLUSION:
-- The Top 10 customers together account for 3.2% of total revenue that is $213292.46

-- QUESTION2:ARE CUSTOMERS CONCENTRATED IN CERTAIN STATES?
-- TECHNIQUE:GROUP BY + AGGREGATE (COUNT) + WINDOW FUNCTION (SUM OVER) + ORDER BY

SELECT 
state,
COUNT(*) AS num_customers,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS percentage_of_customers
FROM customers
GROUP BY state
ORDER BY num_customers DESC;

-- We find that most customers come from NewYork. A total of 1019 customers accounting for 70.5% of customers.

            -- STAFF PERFORMANCE
-- QUESTION1:HOW DO STAFF RANK BY TOTAL SALES WITHIN THEIR STORE?
-- METRIC: Net revenue from completed orders handled by each staff member
-- TECHNIQUE: CTE + INNER JOIN (4 tables) + GROUP BY + AGGREGATES (SUM) + WINDOW FUNCTION (RANK OVER PARTITION BY) + ORDER BY

SELECT*
FROM STAFFS;

SELECT *
FROM ORDERS;

WITH staff_sales AS (
    SELECT
        st.store_id,
        st.store_name,
        s.staff_id,
        s.first_name,
        s.last_name,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN staffs s ON o.staff_id = s.staff_id
    JOIN stores st ON s.store_id = st.store_id
    WHERE o.order_status = 4
    GROUP BY st.store_id, st.store_name, s.staff_id, s.first_name, s.last_name
)
SELECT
	store_name,
    first_name,
    last_name,
    total_sales,
    RANK() OVER (PARTITION BY store_id ORDER BY total_sales DESC) AS rank_in_store
FROM staff_sales
ORDER BY store_id, rank_in_store;

-- CONCLUSION:
-- We find that Gena Serrano made more sales with the Santa Cruz Bikes store a total of $643627.98 sales.
-- Marcelene Boyer made more sales in the Baldwin Bikes store with a total of $2405217.85 sales.
-- Vargas made the most sales in the Rowlett Bikes store with a total of $375464.8 sales.
-- Across all stores the top staff member at Baldwin Bikes generates more than the top staff in the other stores.
-- Staff who have not completed orders do not appear and sales may reflect role differences.

