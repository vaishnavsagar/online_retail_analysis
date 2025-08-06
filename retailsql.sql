SELECT COUNT(*) from cleaned_retail_data;

RENAME TABLE cleaned_retail_data TO retail_data;

-- Total Revenue
SELECT 
    ROUND(SUM(`Total Amount`), 2) AS Total_Revenue
FROM
    retail_data;

-- Monthly Sales Trend
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%M') AS MONTH,
    ROUND(SUM(`Total Amount`), 2) AS REVENUE
FROM
    retail_data
GROUP BY MONTH;

-- Monthly Active Customer
SELECT
	DATE_FORMAT(InvoiceDate, '%M-%Y') AS MONTH,
    COUNT(`Customer ID`) as Active_customer
FROM
	retail_data
GROUP BY MONTH;

-- Top 10 Selling Products (by Quantity)
SELECT 
    `Description`, SUM(Quantity) AS total_quantity
FROM
    retail_data
GROUP BY `Description`
ORDER BY total_quantity DESC
LIMIT 10;

-- Top Countries by Revenue
SELECT 
    Country, ROUND(SUM(`Total Amount`),2) AS Total_Revenue
FROM
    retail_data
GROUP BY Country
ORDER BY Total_Revenue DESC;

-- Top Customers by Revenue
SELECT DISTINCT
    `Customer ID` AS Cust_ID,
    ROUND(SUM(`Total Amount`), 2) AS Total_Spend
FROM
    retail_data
GROUP BY Cust_ID
ORDER BY Total_Spend DESC
LIMIT 10;

-- Average Order Value
SELECT 
    ROUND(SUM(`Total Amount`) / COUNT(DISTINCT Invoice), 2) AS Avg_order_value
FROM
    retail_data;

-- Repeat vs New Customers
CREATE VIEW first_purchase AS
    SELECT 
        `Customer ID`, MIN(DATE(InvoiceDate)) AS first_purchase_date
    FROM
        retail_data
    GROUP BY `Customer ID`;

SELECT 
    DATE_FORMAT(MIN(r.InvoiceDate), '%M-%Y') AS Month,
    COUNT(DISTINCT CASE
            WHEN DATE(r.InvoiceDate) = f.first_purchase_date THEN r.`Customer ID`
        END) AS New_Customers,
    COUNT(DISTINCT CASE
            WHEN DATE(r.InvoiceDate) > f.first_purchase_date THEN r.`Customer ID`
        END) AS Repeat_Customers
FROM
    retail_data r
        JOIN
    first_purchase f ON r.`Customer ID` = f.`Customer ID`
GROUP BY YEAR(r.InvoiceDate) , MONTH(r.InvoiceDate)
ORDER BY MIN(r.InvoiceDate);

-- Customer Purchase Frequency Distribution
SELECT 
    frequency, COUNT(*) AS Customer_count
FROM
    (SELECT 
        `Customer ID`, COUNT(DISTINCT Invoice) AS frequency
    FROM
        retail_data
    GROUP BY `Customer ID`) AS freq_dist
GROUP BY frequency
ORDER BY frequency limit 15;

-- Average Basket Size
SELECT 
    ROUND(AVG(Items_per_invoice), 2) AS avg_basket_size
FROM
    (SELECT 
        Invoice, SUM(Quantity) AS Items_per_invoice
    FROM
        retail_data
    GROUP BY Invoice) AS invoice_items;

-- Customer Retention - Repeat Purchase Ratio
SELECT 
    COUNT(DISTINCT CASE
            WHEN purchase_count > 1 THEN `Customer ID`
        END) AS Repeat_Customer,
    COUNT(DISTINCT `Customer ID`) AS Total_Customer,
    ROUND(COUNT(DISTINCT CASE
                    WHEN purchase_count > 1 THEN `Customer ID`
                END) / COUNT(DISTINCT `Customer ID`) * 100,
            2) AS Repeat_percentage
FROM
    (SELECT 
        `Customer ID`, COUNT(Invoice) as purchase_count
    FROM
        retail_data
    GROUP BY `Customer ID`) AS customer_freq;