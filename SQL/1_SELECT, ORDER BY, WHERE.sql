/* 
	SELECT sin usar FROM 
*/
SELECT NOW();

SELECT CONCAT("Miguel", " ", "Angel!") "My Example";

SELECT NOW(), CURDATE(), CURTIME(), UTC_DATE(), UTC_TIME(), UTC_TIMESTAMP(), SYSDATE();

SELECT NOW(), ADDTIME(NOW(),20);

SHOW TABLES;
SELECT * FROM productlines;
SELECT * FROM products WHERE buyPrice <= MSRP;
SELECT * FROM offices;
SELECT * FROM customers;
SELECT * FROM orderdetails WHERE orderNumber = 10100;
SELECT * FROM orders;

/*
	ORDER BY
*/
SELECT
  *
FROM 
  customers 
ORDER BY 
  contactLastname, contactFirstName;
  
SELECT orderNumber, 
		productCode, 
        quantityOrdered * priceEach AS `SubTotal Price`
FROM orderdetails
ORDER BY `SubTotal Price` DESC;

SELECT FIELD('A','B','A','C');

SELECT orderNumber, status FROM orders
ORDER BY 
	FIELD(status, 
    'In Process', 
    'On Hold', 
    'Cancelled', 
    'Resolved', 
    'Disputed', 
    'Shipped');

SELECT * FROM orders
ORDER BY comments;

/* 
	WHERE
*/
SELECT * FROM employees;

SELECT * FROM employees WHERE lastName LIKE "%son";

SELECT employeeNumber, firstName, lastName 
FROM employees
WHERE employeeNumber IN (1056,1143);

SELECT * FROM employees WHERE reportsTo IS NOT NULL;

/*
	DISTINCT
*/
SELECT DISTINCT state FROM customers;

/*
	AND y OR
*/
SELECT 1 AND 0, 0 AND 1, 0 AND 0, 1 AND 1, 0 AND NULL, NULL AND 0, 1 AND NULL, NULL AND 1, NULL AND NULL;
SELECT 1/0;
SELECT 
    customername, 
    country, 
    state
FROM
    customers
WHERE
    country = "USA" AND 
    state = 'CA';
    
SELECT * FROM customers
WHERE (country = 'USA' OR 
	  country = 'France') AND 
      creditLimit > 10000;
      
SELECT * FROM customers
WHERE customerName BETWEEN 'A' AND 'H'
ORDER BY customerName;

SELECT * FROM products WHERE productDescription REGEXP "^[0-9]";

SELECT * FROM customers;
SELECT customerNumber, customerName, Country, creditLimit 
FROM customers
ORDER BY creditLimit DESC
LIMIT 5;

SELECT customerName, salesRepEmployeeNumber 
FROM customers
WHERE salesRepEmployeeNumber IS NULL
ORDER BY customerName;

-- EJERCICIOS --

SELECT 
	productCode, 
    productName, 
    productLine, 
    LENGTH(productName) AS 'name_len'
FROM products
WHERE productLine = 'Classic Cars'
ORDER BY 4 DESC
LIMIT 7;

/*
2. Lista el identificador del cliente, su nombre y su teléfono para aquellos cuyos teléfonos empiecen 
con (212 o 212, y que no tengan registrada una segunda línea de dirección. Ordena por ciudad y luego 
por nombre del cliente.
*/
SELECT 
	customerNumber, 
    customerName, 
    phone 
FROM 
	customers
WHERE 
	(phone LIKE '(212%' OR 
    phone LIKE '212%') AND
    addressLine2 IS NULL
ORDER BY 
	city,
    customerName;
    
/*
3. Muestra el número de pedido, sus fechas clave y los días de retraso cuando el envío ocurrió después 
de la fecha requerida. Ordena por retraso de mayor a menor y limita a 10 filas.
*/
SELECT 
	orderNumber,
    orderDate,
    requiredDate,
    shippedDate,
    DATEDIFF(shippedDate, requiredDate) AS `Delay days`
FROM 
	orders
WHERE 
	shippedDate > requiredDate
ORDER BY 
	`Delay days` DESC
LIMIT 10;

/*
4. Para las líneas de pedido, muestra el número de pedido, el código de producto, cantidades, precio 
unitario y el subtotal (cantidad × precio). Filtra solo las filas con precio unitario alto (≥ 80) y 
cantidad entre 25 y 60. Ordena por subtotal descendente y, en caso de empate, por número de pedido 
ascendente.
*/
SELECT 
	orderNumber,
    productCode,
    quantityOrdered,
    priceEach,
    quantityOrdered * priceEach AS Subtotal
FROM 
	orderdetails
WHERE 
	priceEach >= 80 AND
	quantityOrdered BETWEEN 25 AND 60
ORDER BY
	Subtotal DESC,
    orderNumber;
    
-- DUDAS: 
/*
	3. Explicame porque no funciona shippedDate - requiredDate y se debe usar DATEDIFF ¿y si quiero la diferencia en Meses como se hace?
	4. ¿Hay alguna manera de darle formato de moneda a la columna Subtotal para que sea más fácil de leer y pase de 10286.40 a $10,286.40?
*/

/*
	5. Devuelve el código y el nombre de productos cuyos códigos comienzan con S10_ (el guion bajo 
    debe interpretarse como carácter literal). Ordena por el código.
*/
SELECT 
	productCode,
    productName
FROM 
	products
WHERE 
	productCode LIKE 'S10\_%'
ORDER BY
	productCode;

/*
	6. Muestra el identificador, nombre, apellido, puesto y referencia al jefe para empleados sin 
    jefe asignado y cuyo puesto empiece por “Sales”. Ordena por la oficina y luego por apellidos y 
    nombres. (Puede devolver 0 filas según los datos de ejemplo).
*/
SELECT 
	employeeNumber, 
    firstName, 
    lastName, 
    jobTitle, 
    reportsTo 
FROM employees
WHERE 
	reportsTo IS NULL AND
	jobTitle LIKE 'Sales%'
ORDER BY 
	officeCode,
    lastName,
    firstName;
    
/*
	7. Obtén los pagos realizados en 2004, ordénalos por el monto de mayor a menor y muestra la 
    segunda página suponiendo 10 resultados por página.
*/
SELECT * FROM payments;
SELECT YEAR('2004-10-19') = 2004;
SELECT * FROM payments 
WHERE YEAR(paymentDate) = 2004
ORDER BY amount DESC
LIMIT 10, 10;

/*
	8. Ordena el catálogo de productos primero por el prefijo del código (lo que está antes del 
    guion bajo) y luego por la parte numérica que va después, interpretando esa parte como número.
    Muestra el código y el nombre.
*/
SELECT 
	productCode, 
    productName,
    LEFT(productCode, LOCATE('_', productCode) - 1),
    SUBSTRING_INDEX(productCode, '_', -1),
    RIGHT( productCode, 4 )
FROM products 
ORDER BY 
	LEFT( productCode, LOCATE('_', productCode) - 1 ),
    RIGHT( productCode, 4 );
    
/*
	9. Devuelve el identificador, nombre, país, ciudad y límite de crédito de clientes que sean 
    de “USA” o “France”, cuya ciudad empiece con “S” y que tengan un alto límite de crédito (al 
    menos 100,000). Ordena por país ascendente y, dentro de cada uno, por límite de crédito 
    descendente.
*/
SELECT 
	customerNumber,
	customerName,
    Country,
    City,
    creditLimit
FROM customers
WHERE 
	Country IN ('UsA', 'FrAnce') AND
    city LIKE 's%' AND
    creditLimit >= 100000
ORDER BY
	Country,
    creditLimit DESC;
    
/*
	10. Considera los pedidos de 2004 cuyo estado pertenezca a un conjunto dado (enviado, 
    resuelto, en espera, cancelado). Muéstralos ordenados con la siguiente prioridad: primero 
    “Shipped”, luego “Resolved”, después “On Hold” y al final “Cancelled”. Dentro de cada 
    grupo, ordena por la fecha del pedido de más reciente a más antiguo. Devuelve el número 
    de pedido, su estado y la fecha.
*/
SELECT DISTINCT status FROM orders;
SELECT 
	orderNumber,
    status,
    orderDate
FROM orders
WHERE 
	YEAR(orderDate) = 2004
	AND status IN ('Shipped', 'Resolved', 'On Hold', 'Cancelled')
ORDER BY
	FIELD(status,'Shipped', 'Resolved', 'On Hold', 'Cancelled'),
    orderDate DESC;