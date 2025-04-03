-- 1
SELECT 
    employee_id,
    first_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS rank
FROM employees;

-- 2
SELECT 
    employee_id,
    first_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS rank,
    SUM(salary) OVER () AS total_salary
FROM employees;

-- 3
SELECT 
    last_name,
    product_name,
    cumulative_sales_value,
    RANK() OVER (ORDER BY cumulative_sales_value DESC) AS sales_rank
FROM (
    SELECT 
        e.last_name,
        p.product_name,
        SUM(s.quantity * s.price) OVER (PARTITION BY s.employee_id) AS cumulative_sales_value
    FROM sales s
    JOIN employees e ON s.employee_id = e.employee_id
    JOIN products p ON s.product_id = p.product_id
) subquery
ORDER BY sales_rank;

-- 4
SELECT 
    e.last_name,
    p.product_name,
    s.price AS product_price,
    COUNT(*) OVER (PARTITION BY s.product_id, TRUNC(s.sale_date)) AS transactions_count,
    SUM(s.quantity * s.price) OVER (PARTITION BY s.product_id, TRUNC(s.sale_date)) AS daily_total,
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date, s.sale_id) AS previous_price,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date, s.sale_id) AS next_price
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
ORDER BY s.sale_date, s.product_id;

-- 5
SELECT 
    p.product_name,
    s.price AS product_price,
    SUM(s.quantity * s.price) OVER (
         PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
    ) AS monthly_total,
    SUM(s.quantity * s.price) OVER (
         PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
         ORDER BY s.sale_date, s.sale_id
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_monthly_total
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_name, s.sale_date, s.sale_id;

-- 6
SELECT 
    p.product_name,
    p.product_category,
    s2022.sale_date AS sale_date_2022,
    s2022.price AS price_2022,
    s2023.price AS price_2023,
    s2023.price - s2022.price AS price_diff
FROM 
    sales s2022
JOIN 
    sales s2023 
      ON s2022.product_id = s2023.product_id
     AND TO_CHAR(s2022.sale_date, 'MM-DD') = TO_CHAR(s2023.sale_date, 'MM-DD')
     AND s2022.sale_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31'
     AND s2023.sale_date BETWEEN DATE '2023-01-01' AND DATE '2023-12-31'
JOIN products p ON s2022.product_id = p.product_id
ORDER BY p.product_name, s2022.sale_date;

-- 7
SELECT 
    p.product_category,
    p.product_name,
    s.price AS product_price,
    MIN(s.price) OVER (PARTITION BY p.product_category) AS min_category_price,
    MAX(s.price) OVER (PARTITION BY p.product_category) AS max_category_price,
    MAX(s.price) OVER (PARTITION BY p.product_category) - 
    MIN(s.price) OVER (PARTITION BY p.product_category) AS price_difference
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_category, p.product_name, s.price;

-- 8
SELECT 
    p.product_name,
    s.sale_date,
    s.price AS product_price,
    AVG(s.price) OVER (
        PARTITION BY s.product_id 
        ORDER BY s.sale_date 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS moving_avg_price
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_name, s.sale_date;

-- 9
SELECT 
    p.product_category,
    p.product_name,
    s.price AS product_price,
    RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS price_rank,
    ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS price_row_number,
    DENSE_RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS price_dense_rank
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_category, s.price DESC;

-- 10
SELECT 
    e.last_name,
    p.product_name,
    s.sale_date,
    s.quantity * s.price AS sale_value,
    SUM(s.quantity * s.price) OVER (
        PARTITION BY s.employee_id 
        ORDER BY s.sale_date, s.sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sales_value,
    RANK() OVER (
        ORDER BY s.quantity * s.price DESC
    ) AS global_sales_rank
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
ORDER BY e.last_name, s.sale_date, s.sale_id;

-- 11
SELECT DISTINCT 
    e.first_name,
    e.last_name,
    j.job_title
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
JOIN sales s ON e.employee_id = s.employee_id;







