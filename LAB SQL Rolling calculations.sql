LAB | SQL Rolling calculations

## In this lab, you will be using the Sakila database of movie rentals.

use sakila; ## Use the database sakila

## Instructions
## Get number of monthly active customers.

SELECT DISTINCT DATE_FORMAT(payment_date, '%Y-%m') AS month_of_payment
		FROM payment; ## this data frame has 5 distincts months with active user ('2005-05', '2005-06', '2005-07', '2005-08', '2006-02')


SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month_of_payment, COUNT(DISTINCT customer_id) AS active_customers
	FROM payment
		GROUP BY DATE_FORMAT(payment_date, "%Y-%m");
    
## Active users in the previous month.

SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers,
    LAG(COUNT(DISTINCT customer_id)) OVER (ORDER BY DATE_FORMAT(payment_date, '%Y-%m')) AS active_customers_previous_month  
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%Y-%m');

	## https://www.geeksforgeeks.org/sql-server-lag-function-overview/
	## The SQL LAG() function is a window function that allows access to a row at a specified physical offset that is before the current row.
    ## The LAG function in SQL Server is used to compare current row values ​​with values ​​from the previous row.

## Percentage change in the number of active customers.

WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM payment
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT 
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month) AS active_customers_previous_month,
    ROUND(
        (active_customers - LAG(active_customers) OVER (ORDER BY month)) / 
        LAG(active_customers) OVER (ORDER BY month) * 100, 
        2
    ) AS percentage_change_active_customers
FROM monthly_active_customers;

## Retained customers every month.

WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(payment_date, '%Y-%m') AS month, 
        COUNT(DISTINCT customer_id) AS active_customers
    FROM payment
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT 
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month) AS active_customers_previous_month,
    active_customers - LAG(active_customers) OVER (ORDER BY month) AS retained_customer_month
FROM monthly_active_customers;

	## Alternative for the exercise above:
SELECT 
    month,
    active_customers,
    previous_month_active_customers,
    retained_customers
FROM (
    SELECT 
        month,
        active_customers,
        previous_month_active_customers,
        (active_customers - previous_month_active_customers) AS retained_customers
    FROM (
        SELECT 
            DATE_FORMAT(payment_date, '%Y-%m') AS month,
            COUNT(DISTINCT customer_id) AS active_customers,
            LAG(COUNT(DISTINCT customer_id)) OVER (ORDER BY DATE_FORMAT(payment_date, '%Y-%m')) AS previous_month_active_customers
        FROM payment
        GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
    ) AS subquery
) AS subquery2;
