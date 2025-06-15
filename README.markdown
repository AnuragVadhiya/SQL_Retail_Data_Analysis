# Retail Sales Data Analysis with SQL

## Introduction

This project, **Retail Sales Data Analysis**, leverages SQL to perform in-depth analysis on a retail sales dataset stored in a PostgreSQL database. The goal is to uncover actionable business insights to support data-driven decision-making in a retail environment. By analyzing key metrics such as sales performance, customer demographics, and transaction patterns, this project addresses critical business questions related to revenue optimization, customer segmentation, and operational efficiency.

The dataset, stored in a table named `retail_sales`, contains detailed transaction records with attributes including transaction ID, sale date and time, customer demographics (ID, gender, age), product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount. This project provides a robust SQL script (`SQL_Retail_DataAnalysis.sql`) that includes table creation, data cleaning, exploratory analysis, and targeted queries to solve specific business problems.

This repository is ideal for data analysts, business intelligence professionals, and retail managers looking to extract meaningful insights from sales data using SQL. The queries are designed to be simple, scalable, and easily adaptable to similar datasets.

## Dataset Description

The `retail_sales` table contains the following columns:

| Column Name       | Data Type    | Description                              |
|-------------------|--------------|------------------------------------------|
| transactions_id   | INT          | Unique identifier for each transaction   |
| sale_date         | DATE         | Date of the transaction                  |
| sale_time         | TIME         | Time of the transaction                  |
| customer_id       | INT          | Unique identifier for each customer      |
| gender            | VARCHAR(15)  | Customer's gender (e.g., Male, Female)   |
| age               | INT          | Customer's age                           |
| category          | VARCHAR(15)  | Product category (e.g., Clothing, Beauty, Electronics) |
| quantiy           | INT          | Number of units sold                     |
| price_per_unit    | FLOAT        | Price per unit of the product            |
| cogs              | FLOAT        | Cost of goods sold for the transaction   |
| total_sale        | FLOAT        | Total sale amount (quantity * price_per_unit) |

**Note**: The dataset may contain NULL values, which are addressed in the data cleaning steps of the SQL script.

## Project Structure

- **SQL_Retail_DataAnalysis.sql**: The main SQL script containing table creation, data cleaning, exploratory queries, and analytical queries.
- **README.md**: This file, providing an overview of the project, dataset, and query descriptions.

## Prerequisites

To run the SQL script, you need:
- A PostgreSQL database server (e.g., PostgreSQL 13 or later).
- A SQL client (e.g., psql, pgAdmin, DBeaver).
- The retail sales dataset in CSV format to import into the `retail_sales` table.

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/retail-sales-data-analysis.git
   cd retail-sales-data-analysis
   ```

2. **Set Up the Database**:
   - Create a PostgreSQL database:
     ```sql
     CREATE DATABASE retail_sales_db;
     ```
   - Connect to the database using your SQL client.


3. **Import the Dataset**:
   - Import your CSV data into the `retail_sales` table using the PostgreSQL `COPY` command or a SQL client’s import feature. Example:
     ```sql
     \copy retail_sales FROM 'path/to/retail_sales.csv' DELIMITER ',' CSV HEADER;
     ```

5. **Execute Queries**:
   - Run individual queries from the script in your SQL client to explore the results.

Below is a detailed description of each query in the script, focusing on the analytical queries (Q.1–Q.7) and key exploratory queries.

### Query Descriptions

#### Table Creation
```sql
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),	
    quantiy INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```
- **Purpose**: Drops any existing `retail_sales` table and creates a new one with the correct schema to store the dataset.
- **Business Value**: Ensures a clean, consistent table structure for reliable analysis.

#### Check for NULL Values
```sql
SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR 
    customer_id IS NULL OR gender IS NULL OR age IS NULL OR 
    category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR 
    cogs IS NULL OR total_sale IS NULL;
```
- **Purpose**: Identifies records with missing values across any column.
- **Business Value**: Ensures data quality by flagging incomplete records that could skew analysis.

#### Delete NULL Values
```sql
DELETE FROM retail_sales 
WHERE
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR 
    customer_id IS NULL OR gender IS NULL OR age IS NULL OR 
    category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR 
    cogs IS NULL OR total_sale IS NULL;
```
- **Purpose**: Removes records with NULL values to maintain data integrity.
- **Business Value**: Prevents inaccurate insights by ensuring only complete records are analyzed.

#### Total Sales (Exploratory)
```sql
SELECT COUNT(*) AS total_sales FROM retail_sales;
```
- **Purpose**: Counts the total number of transactions in the dataset.
- **Business Value**: Provides a baseline understanding of the dataset’s size.

#### Total Customers (Exploratory)
```sql
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM retail_sales;
```
- **Purpose**: Counts the number of unique customers.
- **Business Value**: Helps gauge customer base size for marketing planning, etc.

#### Total Categories (Exploratory)
```sql
SELECT COUNT(DISTINCT category) AS total_categories FROM retail_sales;
```
- **Purpose**: Counts the number of unique product categories.
- **Business Value**: Reveals product diversity for inventory strategy, etc.

#### Q.1: Total Sales for Each Category
```sql
SELECT 
    category,
    SUM(total_sale) AS total_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```
- **Purpose**: Calculates total revenue and number of transactions for each product category.
- **Business Value**: Identifies top-performing categories to prioritize for marketing and inventory.

#### Q.2: Average Age of Customers for Beauty Category
```sql
SELECT 
    ROUND(AVG(age), 2) AS avg_age 
FROM retail_sales
WHERE category = 'Beauty';
```
- **Purpose**: Computes the average age of customers purchasing Beauty products.
- **Business Value**: Helps target marketing for Beauty products to the right demographic.

#### Q.3: Total Transactions by Gender and Category
```sql
SELECT 
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```
- **Purpose**: Counts transactions by gender for each category.
- **Business Value**: Reveals gender-based purchasing patterns to tailor promotions.

#### Q.4: Best-Selling Month by Average Sale per Year
```sql
SELECT * FROM 
(
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sales,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY year, month
) AS rank_table
WHERE rank = 1;
```
- **Purpose**: Identifies the month with the highest average sale amount for each year.
- **Business Value**: Pinpoints peak sales periods for promotional planning.

#### Q.5: Number of Orders by Shift
```sql
WITH hourly_sales AS
(
    SELECT *,
        CASE 
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales 
)
SELECT 
    shift,
    COUNT(*) AS total_orders
FROM hourly_sales
GROUP BY shift;
```
- **Purpose**: Counts transactions by time-based shifts (Morning, Afternoon, Evening).
- **Business Value**: Optimizes staffing by identifying busy periods.

#### Q.6: Identifying High-Value Customer Segments
```sql
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
```
- **Purpose**: Segments customers by gender and age group, ranking by total revenue.
- **Business Value**: Targets high-spending demographics for personalized marketing.

#### Q.7: Customer Age and Category Preferences
```sql
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
```
- **Purpose**: Analyzes category preferences by age group based on revenue.
- **Business Value**: Aligns product marketing with age-specific preferences.


Please ensure queries are well-commented and follow the existing structure for consistency.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or feedback, please open an issue on GitHub or contact the repository owner.

---

*Last Updated: June 15, 2025*
