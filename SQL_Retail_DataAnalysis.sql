" SQL RETAIL DATASET PROJECT "

--- CREATING TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
             transactions_id INT PRIMARY KEY,
	         sale_date DATE,
	         sale_time TIME,
	         customer_id INT,
	         gender VARCHAR(15),
	         age INT,
	         category VARCHAR(15),	
	         quantiy INT,
	         price_per_unit	FLOAT,
	         cogs FLOAT,
	         total_sale FLOAT
);

--- Importing and understadning data
SELECT * FROM retail_sales;

SELECT COUNT (*) FROM retail_sales;

--checking for NULL values

SELECT * FROM retail_sales
WHERE 
     transactions_id is NULL
	 OR
	 sale_date is NULL
	 OR
	 sale_time is NULL
	 OR 
	 customer_id is NULL
	 OR 
	 gender is NULL
	 OR
	 age is NULL
	 OR
	 category is NULL
	 OR
	 quantiy is NULL
	 OR
	 price_per_unit is NULL
	 OR
	 cogs is NULL
	 OR
	 total_sale is NULL;


--- DELETING null values

DELETE from retail_sales 
WHERE
     transactions_id is NULL
	 OR
	 sale_date is NULL
	 OR
	 sale_time is NULL
	 OR 
	 customer_id is NULL
	 OR 
	 gender is NULL
	 OR
	 age is NULL
	 OR
	 category is NULL
	 OR
	 quantiy is NULL
	 OR
	 price_per_unit is NULL
	 OR
	 cogs is NULL
	 OR
	 total_sale is NULL;


--- Data Exploration

--- total sales
SELECT COUNT (*) ASFROM total_sales FROM retail_sales;

---total customers
SELECT COUNT (DISTINCT customer_id) ASFROM total_customers FROM retail_sales;

---total categories
SELECT COUNT (DISTINCT category) ASFROM total_categories FROM retail_sales;

--- Key problems / Analysis 
-- Q.1 Total sales for each category.

SELECT 
	category,
	SUM(total_sale) as total_sale,
	COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1;

-- Q.2 Average age of customers who purchased items from the 'Beauty' category.

SELECT 
	round(AVG(age), 2) as avg_age 
	FROM retail_sales
	WHERE category = 'Beauty';

-- Q.3 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
	category,
	gender,
	COUNT(*) as total_transactions
FROM retail_sales
GROUP BY 
	category,
	gender
ORDER BY 1;

-- Q.4 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year 

SELECT * FROM 

( SELECT 
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date) as month,
	AVG(total_sale) as avg_sales,
	RANK() OVER(PARTITION by extract(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as rank_table

WHERE rank = 1;

-- Q.5 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sales
AS
(
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales 
)
SELECT 
	shift,
	COUNT(*) as total_orders
FROM hourly_sales
group by shift;

-- Q.6 Identifying High-Value Customer Segments
SELECT 
    gender,
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age >= 60 THEN '60+'
        ELSE 'Unknown'
    END AS age_group,
    SUM(total_sale) AS total_revenue,
    COUNT(DISTINCT customer_id) AS unique_customers,
    AVG(total_sale) AS avg_purchase_value
FROM retail_sales
GROUP BY gender, age_group
ORDER BY total_revenue DESC
LIMIT 5;

-- Q.7 Customer Age and Category Preferences
SELECT 
    CASE 
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 50 THEN '30-50'
        WHEN age > 50 THEN 'Over 50'
        ELSE 'Unknown'
    END AS age_group,
    category,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY age_group, category
ORDER BY age_group, total_revenue DESC;


--END