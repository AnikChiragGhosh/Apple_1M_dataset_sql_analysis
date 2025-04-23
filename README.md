# Apple_1M_dataset_sql_analysis# Apple Retail Sales SQL Project

## Project Overview
This project showcases advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset contains information about products, stores, sales transactions, and warranty claims from various Apple retail locations globally. This project includes solutions to real-world business problems by leveraging SQL, enhancing your ability to analyze and extract insights from large-scale datasets.

## Entity-Relationship Diagram (ERD)
The dataset comprises five tables: `stores`, `category`, `products`, `sales`, and `warranty`. Below is the structure of the ERD that represents the relationships among these tables.

<img width="646" alt="image" src="https://github.com/user-attachments/assets/d235e45e-97ad-4382-8210-5d121f7ee02e" />

## Database Schema
### Tables and Columns
**stores**
- `store_id`: Unique identifier for each store
- `store_name`: Name of the store
- `city`: City where the store is located
- `country`: Country of the store

**category**
- `category_id`: Unique identifier for each product category
- `category_name`: Name of the category

**products**
- `product_id`: Unique identifier for each product
- `product_name`: Name of the product
- `category_id`: References the `category` table
- `launch_date`: Date when the product was launched
- `price`: Price of the product

**sales**
- `sale_id`: Unique identifier for each sale
- `sale_date`: Date of the sale
- `store_id`: References the `stores` table
- `product_id`: References the `products` table
- `quantity`: Number of units sold

**warranty**
- `claim_id`: Unique identifier for each warranty claim
- `claim_date`: Date the claim was made
- `sale_id`: References the `sales` table
- `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void)

## Objectives
The project is divided into three tiers of questions to test SQL skills of increasing complexity:

### Easy to Medium (10 Questions)
1. Find the number of stores in each country.
2. Calculate the total number of units sold by each store.
3. Identify how many sales occurred in December 2023.
4. Determine how many stores have never had a warranty claim filed.
5. Calculate the percentage of warranty claims marked as "Warranty Void".
6. Identify which store had the highest total units sold in the last year.
7. Count the number of unique products sold in the last year.
8. Find the average price of products in each category.
9. How many warranty claims were filed in 2020?
10. Identify the best-selling day for each store.

### Medium to Hard (5 Questions)
1. Identify the least selling product in each country for each year.
2. Calculate how many warranty claims were filed within 180 days of a product sale.
3. Determine how many warranty claims were filed for products launched in the last two years.
4. List the months in the last three years where sales exceeded 5,000 units in the USA.
5. Identify the product category with the most warranty claims filed in the last two years.

### Complex (5 Questions)
1. Determine the percentage chance of receiving warranty claims after each purchase for each country.
2. Analyze the year-by-year growth ratio for each store.
3. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
4. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.
5. Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends.

## Project Focus
This project emphasizes:
- **Complex Joins and Aggregations**: Advanced SQL joins and aggregations.
- **Window Functions**: Utilizing functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Time-based analysis for product performance.
- **Correlation Analysis**: Identifying relationships between variables like product price and warranty claims.
- **Real-World Problem Solving**: Addressing business challenges with SQL.
