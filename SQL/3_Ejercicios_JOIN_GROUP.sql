-- EJERCICIOS --

/*
	1. Calcula, para un año concreto (usa 2004), el importe total vendido por cada cliente y muestra el top 10, incluyendo el nombre del cliente y el total. 
		Ordena del mayor al menor.
*/
-- SOLUCIÓN --
SELECT 
	c.customerName AS Nombre,
    SUM( od.quantityOrdered * od.priceEach ) AS Total_vendido
FROM 
	customers AS c
	LEFT JOIN orders AS o 
		ON c.customerNumber = o.customerNumber
	LEFT JOIN orderdetails AS od 
		ON o.orderNumber = od.orderNumber
WHERE YEAR(o.orderDate) = 2004
GROUP BY c.customerNumber
ORDER BY Total_vendido DESC;


/*
	2. Muestra todos los clientes con su número de pedidos (incluye a quienes no han pedido nada). Ordena por ese conteo descendente y, en caso de empate, por el 
	   nombre del cliente.
*/
-- SOLUCIÓN --
SELECT 
	c.customerNumber,
    customerName,
    COUNT(o.orderNumber) AS Numero_de_pedidos
FROM 
	customers AS c 
    LEFT JOIN orders AS o 
		ON c.customerNumber = o.customerNumber 
GROUP BY 
	c.customerNumber
ORDER BY 
	Numero_de_pedidos DESC,
    customerName;


    
/*
	3. Para cada pedido, calcula el número de renglones y el importe total del pedido. Muestra solo los que tengan al menos 4 renglones y un total superior a 20,000. 
       Ordena por total descendente.
*/
SELECT * FROM payments WHERE customerNumber = 141
ORDER BY paymentDate;

-- SOLUCIÓN --
SELECT 
	orderNumber, 
	COUNT(productCode) AS Items_Number, 
    CONCAT( '$ ', FORMAT( SUM( quantityOrdered * priceEach ), 2 ) ) AS Subtotal 
FROM 
	orderdetails
GROUP BY 
	orderNumber
HAVING
	Items_Number >= 4 AND
    SUM( quantityOrdered * priceEach ) > 20000
ORDER BY 
	SUM( quantityOrdered * priceEach ) DESC;
    
    
    
/*
	4. Por cada familia de productos, devuelve el importe total vendido y el número de clientes distintos que compraron algo de esa familia. Muestra las 5 familias 
       con mayor importe.
*/
SELECT * FROM products;
SELECT * FROM orders LEFT JOIN orderdetails USING (orderNumber) WHERE productCode IS NULL; -- Todas las ordenes tienen registrados al menos un producto
SELECT * FROM orderdetails LEFT JOIN orders USING (orderNumber) WHERE orderDate IS NULL; -- Todos los productos tienen asignada su correspondiente orden
SELECT * FROM orders LEFT JOIN orderdetails USING (orderNumber);
SELECT * FROM orders AS o LEFT JOIN orderdetails AS od ON o.orderNumber = od.orderNumber;

-- SOLUCIÓN --
SELECT 
	productLine AS Product_Line,
    CONCAT('$ ', FORMAT(SUM( quantityOrdered * priceEach ), 2) ) AS Total_sale,
    COUNT( DISTINCT customerNumber ) AS No_Customers
FROM 
	orders 
    LEFT JOIN orderdetails USING (orderNumber)
    LEFT JOIN products USING (productCode)
GROUP BY 
	productLine
ORDER BY 
	SUM( quantityOrdered * priceEach ) DESC
LIMIT 5;



/*
	5. Para cada representante comercial (los que tienen clientes asignados), muestra su nombre completo, cuántos clientes atiende, cuántos pedidos se han hecho desde 
       sus clientes y el importe total de esas ventas. Si un representante no tiene ventas, debe aparecer con ceros.
*/

SELECT * FROM customers WHERE salesRepEmployeeNumber IS NULL; -- Hay 22 clientes sin un representant de ventas asignado
-- Todos los que tienen asignado un cliente tienen el cargo de "Sales Rep"
SELECT DISTINCT jobTitle FROM employees AS e LEFT JOIN customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber WHERE salesRepEmployeeNumber IS NOT NULL;
-- Tom King y Yoshimi Kato son los unicos "Sales Rep" sin clientes asignados
SELECT * FROM employees AS e LEFT JOIN customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber WHERE salesRepEmployeeNumber IS NULL;
-- Clientes que atiende cada empleado --
SELECT 
	CONCAT(e.firstName, ' ', e.lastName) AS Full_Name,
    COUNT(c.customerNumber) AS Customers_Atended
FROM 
	employees AS e 
    LEFT JOIN customers AS c 
		ON e.employeeNumber = c.salesRepEmployeeNumber
WHERE 
	jobTitle = 'Sales Rep'
GROUP BY 
	employeeNumber
ORDER BY 
	Full_Name;

-- SOLUCIÓN --
SELECT 
	CONCAT(e.firstName, ' ', e.lastName) AS Full_Name,
    COUNT(DISTINCT c.customerNumber) AS Customers_Atended,
    COUNT( DISTINCT orderNumber) AS Oders_Made,
    CONCAT('$',
			FORMAT( 
					IFNULL(SUM( quantityOrdered * priceEach),0), 
                    2
				  ) 
		  ) AS Total_Sale
FROM 
	employees AS e 
    LEFT JOIN customers AS c 
		ON e.employeeNumber = c.salesRepEmployeeNumber
	LEFT JOIN orders USING (customerNumber)
    LEFT JOIN orderdetails USING (orderNumber)
WHERE
	jobTitle = "Sales Rep"
GROUP BY 
	e.employeeNumber
HAVING
	Customers_Atended > 0
ORDER BY 
	Full_Name; 
    
/*
	6. Identifica los pedidos que incluyen productos de más de una familia y muestra el número de familias distintas involucradas en cada uno. Ordena por ese número 
       descendente y, en empates, por el identificador del pedido.
 */
 
 SELECT * FROM orderdetails WHERE productCode = "S23"; -- Cuando no encuentrta registros regresa una fila de puros NULL
 SELECT * FROM offices;			-- Todas las tablas aparecen con una fila NULL al final cuando las imprimo
 SELECT * FROM products;
 SELECT * FROM customers;
 SELECT * FROM orderdetails;
 SELECT * FROM orders;
 SELECT * FROM payments;
 
 -- Todos los productos de orderdetails estan registrados en la tabla products
SELECT * FROM orderdetails AS od LEFT JOIN products AS p ON od.productCode = p.productCode WHERE p.productCode IS NULL;

-- SOLUCIÓN --
SELECT 
	orderNumber,
	COUNT(DISTINCT productLine) AS Number_Family 
 FROM 
	orderdetails AS od 
    LEFT JOIN products AS p 
		ON od.productCode = p.productCode
 GROUP BY 
	orderNumber
 HAVING 
	Number_Family > 1
ORDER BY
	Number_Family DESC,
    orderNumber;
    
/*
	7. Calcula, para cada mes de 2004, el importe total vendido y compáralo con el mes anterior mostrando la diferencia (mes actual − mes previo). Hazlo sin funciones 
       de ventana.
*/

SELECT 
	MONTH(orderDate) AS Month, 
    SUM(quantityOrdered * priceEach) AS Total_Sale 
FROM 
	orders 
    JOIN orderdetails USING(orderNumber) 
WHERE 
	YEAR(orderDate) = 2004
GROUP BY 
	Month;

SELECT MAX(orderDate) FROM orders;

-- SOLUCIÓN --
SELECT 
	MONTH(o1.orderDate) AS Month,
    CONCAT( '$', FORMAT( SUM( DISTINCT od1.quantityOrdered * od1.priceEach ), 2 ) ) AS Month_Sale,
    CONCAT( '$', FORMAT( SUM( DISTINCT od2.quantityOrdered * od2.priceEach ), 2 ) ) AS Past_Month_Sale,
    CONCAT( '$', 
			FORMAT( 
					SUM( DISTINCT od1.quantityOrdered * od1.priceEach ) - SUM( DISTINCT od2.quantityOrdered * od2.priceEach ), 
                    2 
				  ) 
		  ) AS `Present - Past`
FROM 
	orders o1 
    LEFT JOIN orders o2 
		ON MONTH(o1.orderDate) - MONTH(o2.orderDate) = 1 AND
		   YEAR(o1.orderDate) = YEAR(o2.orderDate)
	JOIN orderdetails od1
		ON o1.orderNumber = od1.orderNumber
	LEFT JOIN orderdetails od2
		ON o2.orderNumber = od2.orderNumber
WHERE 
	YEAR(o1.orderDate) = 2004
GROUP BY 
	MONTH(o1.orderDate);
    


/*
	8. Para cada país, encuentra el producto más vendido por importe total (usa todo el histórico). Muestra país, código y nombre del producto ganador y el importe. 
       Evita funciones de ventana.
*/
-- SOLUCION --
WITH 
saleCountryProduct AS (
	SELECT
		country,
		productCode,
		productName,
		SUM( quantityOrdered * priceEach ) AS Total_Sale
	FROM
		products
		RIGHT JOIN orderdetails USING( productCode )
		JOIN orders             USING( orderNumber )
		RIGHT JOIN customers    USING( customerNumber )
	GROUP BY 
		country,
		productCode
	ORDER BY 
		country,
		Total_Sale DESC
	),

hightestSale as (
SELECT 
	country,
	MAX( Total_Sale ) AS Total_Sale
FROM 
	saleCountryProduct
GROUP BY 
	country)
    
SELECT 
	country,
    CONCAT( '$', FORMAT(Total_Sale, 2) ) AS Sale,
    productName,
    productCode
FROM 
	hightestSale 
    LEFT JOIN saleCountryProduct USING (country, Total_Sale);
    


/*
	9. Para cada cliente, calcula el importe total de sus pedidos, el importe total pagado y el saldo (pedidos − pagos). Muestra solo 
       quienes tienen saldo positivo. Ordena por saldo descendente.
*/
-- SOLUCIÓN --
WITH paymentsCustomer AS (
	SELECT
		customerNumber,
		SUM( amount ) AS Total_Pagado
	FROM 
		payments 
	GROUP BY
		customerNumber
	),

ordersCustomer AS (
	SELECT
		customerNumber,
		SUM( quantityOrdered * priceEach ) AS Total_Pedido
	FROM
		 orders
		 JOIN orderdetails USING( orderNumber )
	GROUP BY 
		customerNumber
	)
    
SELECT 
	*, Total_Pedido - Total_Pagado AS Saldo 
FROM 
	paymentsCustomer 
    JOIN ordersCustomer USING( customerNumber )
WHERE 
	Total_Pedido - Total_Pagado > 0
ORDER BY 
	Saldo DESC;
    
    

/*
	10. Devuelve un resumen jerárquico del importe vendido por familia y el gran total general en una sola salida. En la fila total, 
		muestra una etiqueta clara en lugar del valor nulo.
*/
-- SOLUCIÓN --
SELECT
	IFNULL(productLine, '*** TOTAL ***') AS productLine,
    SUM( quantityOrdered * priceEach ) AS Total_Sale
FROM 
	orders 
    JOIN orderdetails USING( orderNumber )
    LEFT JOIN products USING( productCode )
GROUP BY
	productLine
    WITH ROLLUP