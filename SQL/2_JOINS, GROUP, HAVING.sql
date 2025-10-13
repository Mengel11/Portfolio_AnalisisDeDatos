-- COLUMN AND TABLE ALIASES 

SELECT
		CONCAT_WS(', ', lastName, firstname) `Full name`
FROM
		employees
ORDER BY
		`Full name`;
        
-- JOIN's --

-- INNER JOIN --
SELECT * FROM products;
SELECT * FROM productlines;

SELECT 
    orderNumber,
    orderDate,
    customerName,
    orderLineNumber,
    productName,
    quantityOrdered,
    priceEach
FROM
    orders
INNER JOIN orderdetails 
    USING (orderNumber)
INNER JOIN products 
    USING (productCode)
INNER JOIN customers 
    USING (customerNumber)
ORDER BY 
    orderNumber, 
    orderLineNumber;
    
SELECT 
    orderNumber, 
    productName, 
    msrp, 
    priceEach
FROM
    products p
INNER JOIN orderdetails o 
   ON p.productcode = o.productcode
      AND p.msrp > o.priceEach
WHERE
    p.productcode = 'S10_1678';
    
SELECT
    customerNumber,
    customerName,
    orderNumber,
    status
FROM
    customers c
INNER JOIN orders o 
    ON c.customerNumber = o.customerNumber;

-- LEFT JOIN
SELECT
	customerNumber,
	customerName,
	orderNumber,
	status
FROM
	customers
LEFT JOIN orders USING (customerNumber);

SELECT 
    lastName, 
    firstName, 
    customerName, 
    checkNumber, 
    amount
FROM
    employees
LEFT JOIN customers ON 
	salesRepEmployeeNumber = employeeNumber
LEFT JOIN payments
    USING (customerNumber)
ORDER BY 
    customerName, 
    checkNumber;
    
-- SELFJOIN --
SELECT * FROM employees;
SELECT 
    CONCAT(e2.lastName, ', ', e2.firstName) AS Manager,
    e2.jobTitle,
    CONCAT(e1.lastName, ', ', e1.firstName) AS 'Direct report'
FROM
    employees e1
INNER JOIN employees e2 ON 
    e2.employeeNumber = e1.reportsTo
ORDER BY 
    Manager;

SELECT 
    IFNULL(CONCAT(m.lastname, ', ', m.firstname),
            'Top Manager') AS 'Manager',
    CONCAT(e.lastname, ', ', e.firstname) AS 'Direct report'
FROM
    employees e
LEFT JOIN employees m ON 
    m.employeeNumber = e.reportsto
ORDER BY 
    manager DESC;
    
SELECT 
    c1.city, 
    c1.customerName, 
    c2.customerName
FROM
    customers c1
INNER JOIN customers c2 ON 
    c1.city = c2.city
    AND c1.customername < c2.customerName
ORDER BY 
    c1.city,
    c1.customerName;
    
SELECT * FROM orders
CROSS JOIN orderdetails
WHERE orders.orderNumber = orderdetails.orderNumber;

/*
	GROUP BY, HAVING
*/
SELECT 
  YEAR(orderDate) AS year, 
  SUM(quantityOrdered * priceEach) AS total 
FROM 
  orders 
  INNER JOIN orderdetails USING (orderNumber) 
WHERE 
  status = 'Shipped' 
GROUP BY 
  YEAR(orderDate);
  
SELECT 
    a.ordernumber, 
    status, 
    SUM(priceeach*quantityOrdered) total
FROM
    orderdetails a
INNER JOIN orders b 
    ON b.ordernumber = a.ordernumber
GROUP BY  
    ordernumber
HAVING 
    status = 'Shipped' AND 
    total > 1500;
    
SELECT 
	orderNumber, 
    COUNT(productCode) AS NoItems
FROM 
	orderdetails
GROUP BY 
	orderNumber
HAVING 
	NoItems > 10;
    
SELECT 
  customerName, 
  COUNT(*) order_count 
FROM 
  orders 
  INNER JOIN customers using (customerNumber) 
GROUP BY 
  customerName 
HAVING 
  order_count > 4 
ORDER BY 
  order_count;
  
CREATE TABLE sales
SELECT
    productLine,
    YEAR(orderDate) orderYear,
    SUM(quantityOrdered * priceEach) orderValue
FROM
    orderDetails
        INNER JOIN
    orders USING (orderNumber)
        INNER JOIN
    products USING (productCode)
GROUP BY
    productLine ,
    YEAR(orderDate);

SELECT * FROM sales ORDER BY productLine;

SELECT 
    productline, 
    SUM(orderValue) totalOrderValue
FROM
    sales
GROUP BY 
    productline 
UNION ALL
SELECT 
    'TOTAL', 
    SUM(orderValue) totalOrderValue
FROM
    sales;

SELECT 
    productLine, 
    orderYear,
    SUM(orderValue) totalOrderValue
FROM
    sales
GROUP BY 
    productline, 
    orderYear 
WITH ROLLUP;

SELECT 
    IF(GROUPING(orderYear),
        'All Years',
        orderYear) orderYear,
    IF(GROUPING(productLine),
        'All Product Lines',
        productLine) productLine,
    SUM(orderValue) totalOrderValue
FROM
    sales
GROUP BY 
    orderYear , 
    productline 
WITH ROLLUP;