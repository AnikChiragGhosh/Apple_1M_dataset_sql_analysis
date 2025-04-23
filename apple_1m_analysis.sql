use db_apple

-- Apple Retails Millions Rows Sales Schemas

-- Please make sure to Import as mentioned below
--1. Import first to Category TABLE
--2. Import to Product Table
--3. Import to Stores Table
--4. Import to Sales TABLE
--5. Import to Warranty Table
-- DROP TABLE commands in correct order
DROP TABLE IF EXISTS warranty;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS stores;

-- CREATE TABLE commands
CREATE TABLE stores(
    store_id VARCHAR(50) PRIMARY KEY,  -- Changed from VARCHAR(5) to VARCHAR(10)
    store_name VARCHAR(50),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE category(
    category_id VARCHAR(50) PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE products(
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(50),
    category_id VARCHAR(50),
    launch_date date,
    price FLOAT,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE sales(
    sale_id VARCHAR(50) PRIMARY KEY,
    sale_date DATE,
    store_id VARCHAR(50),  -- Now matches stores.store_id
    product_id VARCHAR(50),
    quantity INT,
    CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE warranty(
    claim_id VARCHAR(50) PRIMARY KEY,
    claim_date date,
    sale_id VARCHAR(50),
    repair_status VARCHAR(50),
    CONSTRAINT fk_orders FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);

-- Success Message
SELECT 'Schema created successful' as Success_Message;

-- Apple Sales Project - 1M rows Sales dataset

select * from category;
select * from Products;
select* from stores;
select * from sales;
select * from warranty;


CREATE INDEX sales_product_id on sales(product_id);
CREATE INDEX sales_store_id on sales(store_id);
CREATE INDEX sales_sale_date on sales(sale_date);



-- 1.Find each country and number of stores

select country, count(store_id) as Total_Stores
from stores
Group by country
order by Total_Stores desc;

-- What is the total number of units sold by each store?
select 
st.store_id,
st.store_name,
sum(quantity) as total_units
from sales sl inner join stores st
on st.store_id = sl.store_id
Group by st.store_id,st.store_name
order by total_units Desc;


-- How many sales occurred in December 2023?

SELECT
    COUNT(sale_id) AS total_sales
FROM sales
WHERE FORMAT(sale_date, 'MM-yyyy') = '12-2023'

-- 4 How many stores have never had a warranty claim filed against any of their products?
 select * from stores
 where store_id NOT IN(
 						select 
 						distinct(store_id)
 						--store_id
 						from warranty w left join sales s
 						on w.sale_id = s.sale_id);-- recieved warranty claims stores

select count(*) as total_stores_not_claimed_warranty from stores
where store_id NOT IN(
 						select 
 						distinct(store_id)
 						--store_id
 						from warranty w left join sales s
 						on w.sale_id = s.sale_id);-- recieved warranty claims stores

-- 5. What percentage of warranty claims are marked as "Warranty Void"?
SELECT 
    ROUND(
        COUNT(claim_id) * 100.0 / 
        (SELECT COUNT(*) FROM warranty),2 )AS warranty_void_percentage
FROM warranty 
WHERE repair_status = 'Warranty Void';

-- 6. Which store had the highest total units sold in the last year?
SELECT 
    store_id,
    SUM(quantity) AS Total_units_sold
FROM sales
WHERE sale_date > DATEADD(YEAR, -1, CAST(GETDATE() AS DATE))
GROUP BY store_id
ORDER BY SUM(quantity) DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

-- 7. Count the number of unique products sold in the last year.

SELECT * FROM sales;

SELECT 
    COUNT(DISTINCT product_id) AS unique_products
FROM sales
WHERE sale_date >= DATEADD(YEAR, -1, CAST(GETDATE() AS DATE));


--8. What is the average price of products in each category?
SELECT
    c.category_id,
    c.category_name,
    ROUND(AVG(p.price), 0) AS average_price
FROM 
    products p 
    JOIN category c ON p.category_id = c.category_id
GROUP BY 
    c.category_id, 
    c.category_name
ORDER BY 
    average_price DESC;

--9. How many warranty claims were filed in 2020?

SELECT 
    COUNT(claim_id) AS warranty_claims
FROM warranty
WHERE YEAR(claim_date) = 2020;

--10. Identify each store and best selling day based on highest qty sold

SELECT * 
FROM
(
    SELECT
        store_id,
        DATENAME(WEEKDAY, sale_date) AS day_name,
        SUM(quantity) AS total_unit_sold,
        RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rank 
    FROM sales
    GROUP BY store_id, DATENAME(WEEKDAY, sale_date)
) AS t1
WHERE rank = 1;

--11.Identify least selling product of each country for each year based on total unit sold
WITH product_sales AS (
    SELECT
        st.country,
        p.product_name,
        YEAR(sl.sale_date) AS sales_year,
        SUM(sl.quantity) AS total_units_sold,
        RANK() OVER(
            PARTITION BY st.country, YEAR(sl.sale_date)
            ORDER BY SUM(sl.quantity) ASC  -- Note: ASC for least selling
        ) AS sales_rank
    FROM
        stores st
        JOIN sales sl ON st.store_id = sl.store_id
        JOIN products p ON sl.product_id = p.product_id
    GROUP BY
        st.country, p.product_name, YEAR(sl.sale_date)
)
SELECT
    country,
    product_name,
    sales_year,
    total_units_sold
FROM product_sales
WHERE sales_rank = 1  -- Only show the lowest ranked (least sold)
ORDER BY
    country,
    sales_year;


-- 12. How many warranty claims were filed within 180 days of a product sale?

SELECT
    w.*,
    s.sale_date,
    DATEDIFF(DAY, s.sale_date, w.claim_date) AS Claim_days
FROM warranty w 
LEFT JOIN sales s ON s.sale_id = w.sale_id
WHERE DATEDIFF(DAY, s.sale_date, w.claim_date) BETWEEN 0 AND 180;


  SELECT 
    COUNT(w.claim_id) AS warranty_claims_within_180_days
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
WHERE DATEDIFF(DAY, s.sale_date, w.claim_date) BETWEEN 0 AND 180;

-- 13. How many warranty claims have been filed for products launched in the last two years?

SELECT
    p.product_id,
    p.product_name,
    p.launch_date,
    COUNT(w.claim_id) AS claims
FROM warranty w
JOIN sales s ON s.sale_id = w.sale_id
JOIN products p ON p.product_id = s.product_id
WHERE 
    p.launch_date >= DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
GROUP BY 
    p.product_id,
    p.product_name,
    p.launch_date
ORDER BY 
    claims DESC;

-- 14 List the months in the last three years where sales exceeded 5,000 units in the USA.

SELECT 
    FORMAT(s.sale_date, 'MM-yyyy') AS month_year,
    SUM(s.quantity) AS Total_sales
FROM sales s
JOIN stores st ON s.store_id = st.store_id
WHERE 
    st.country = 'USA'
    AND s.sale_date >= DATEADD(YEAR, -3, CAST(GETDATE() AS DATE))
GROUP BY FORMAT(s.sale_date, 'MM-yyyy')
HAVING SUM(s.quantity) > 5000
ORDER BY month_year;

-- Q.15 Identify the product category with the most warranty claims filed in the last two years.

SELECT
    c.category_name,
    COUNT(w.claim_id) AS total_claims
FROM warranty w
LEFT JOIN sales s ON w.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE 
    w.claim_date >= DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
GROUP BY 
    c.category_name
ORDER BY 
    total_claims DESC;

-- Complex Problems
-- Q.16 Determine the percentage chance of receiving warranty claims after each purchase for each country!

SELECT
    country,
    total_sales,
    total_claims,
    ROUND(COALESCE(CAST(total_claims AS FLOAT) / NULLIF(CAST(total_sales AS FLOAT), 0) * 100, 0), 2) AS percentage_warranty_claims
FROM
    (SELECT 
        st.country,
        SUM(s.quantity) AS total_sales,
        COUNT(w.claim_id) AS total_claims
     FROM sales s
     JOIN stores st ON s.store_id = st.store_id
     LEFT JOIN warranty w ON s.sale_id = w.sale_id
     GROUP BY st.country) t1
ORDER BY percentage_warranty_claims DESC;


-- Q.17 Analyze the year-by-year growth ratio for each store.

WITH yearly_sales AS (
    SELECT 
        st.store_id,
        st.store_name,
        YEAR(s.sale_date) AS year,
        SUM(p.price * s.quantity) AS total_sale
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    JOIN stores st ON s.store_id = st.store_id
    GROUP BY st.store_id, st.store_name, YEAR(s.sale_date)
),
Growth_Ratio AS (
    SELECT
        store_name,
        year,
        LAG(total_sale, 1) OVER (PARTITION BY store_name ORDER BY year) AS last_year_sale,
        total_sale AS current_year_sale
    FROM yearly_sales
)

SELECT 
    store_name,
    year,
    last_year_sale,
    current_year_sale,
    ROUND((CAST(current_year_sale - last_year_sale AS FLOAT) / NULLIF(CAST(last_year_sale AS FLOAT), 0)) * 100, 3
    ) AS growth_ratio
FROM Growth_Ratio
WHERE last_year_sale IS NOT NULL
  AND year <> YEAR(GETDATE());

-- Q.18 Calculate the correlation between product price and warranty claims for 
-- products sold in the last five years, segmented by price range.

SELECT
    CASE
        WHEN p.price < 500 THEN 'LESS EXPENSIVE PRODUCT'
        WHEN p.price BETWEEN 500 AND 1000 THEN 'MID RANGE PRODUCT'
        ELSE 'EXPENSIVE PRODUCT'
    END AS price_segment,
    COUNT(w.claim_id) AS total_claims
FROM warranty AS w
LEFT JOIN sales AS s ON w.sale_id = s.sale_id
JOIN products AS p ON p.product_id = s.product_id
WHERE w.claim_date >= DATEADD(YEAR, -5, CAST(GETDATE() AS DATE))
GROUP BY
    CASE
        WHEN p.price < 500 THEN 'LESS EXPENSIVE PRODUCT'
        WHEN p.price BETWEEN 500 AND 1000 THEN 'MID RANGE PRODUCT'
        ELSE 'EXPENSIVE PRODUCT'
    END;

-- Q.19 Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed

WITH paid_repair AS (
    SELECT 
        s.store_id,
        COUNT(w.claim_id) AS paid_repaired
    FROM sales AS s
    RIGHT JOIN warranty AS w ON s.sale_id = w.sale_id
    WHERE w.repair_status = 'Paid Repaired'
    GROUP BY s.store_id
),
total_repaired AS (
    SELECT 
        s.store_id,
        COUNT(w.claim_id) AS total_repaired
    FROM sales AS s
    RIGHT JOIN warranty AS w ON s.sale_id = w.sale_id
    GROUP BY s.store_id
)
SELECT
    tr.store_id,
    st.store_name,
    pr.paid_repaired,
    tr.total_repaired,
    ROUND(
        CAST(pr.paid_repaired AS FLOAT) / NULLIF(CAST(tr.total_repaired AS FLOAT), 0) * 100,
        2
    ) AS percentage_paid_repaired
FROM paid_repair AS pr
JOIN total_repaired AS tr ON pr.store_id = tr.store_id
JOIN stores AS st ON st.store_id = tr.store_id
ORDER BY percentage_paid_repaired DESC;

-- -- Q.20 Write a query to calculate the monthly running total of sales for each store
-- over the past four years and compare trends during this period.

WITH monthly_sales AS (
    SELECT
        s.store_id,
        YEAR(s.sale_date) AS year,
        MONTH(s.sale_date) AS month,
        SUM(p.price * s.quantity) AS total_revenue
    FROM sales AS s
    JOIN products AS p ON p.product_id = s.product_id
    GROUP BY s.store_id, YEAR(s.sale_date), MONTH(s.sale_date)
)
SELECT 
    store_id,
    month,
    year,
    total_revenue,
    SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year, month) AS running_total
FROM monthly_sales
ORDER BY store_id, year, month;


