-- PREGUNTAS
/* 
	1. ¿Cuál es el porcentaje de victorias de cada atleta?
    2. ¿Cuál es el porcentaje de victorias sin contar eliminación?
    3. ¿Quién le ha ganado a KOKE, MATI y al MONO?
    4. ¿Cuál ha sido el marcador de cada uno de los juegos?
    5. ¿Cuantos relevos han sucedido?
    6. ¿Cuál es el porcentaje de victorias de cada atleta sobre los atletas que tienen porcentaje de victorias positivo?
    7. ¿Cuántos juegos se han llevado acabo en cada circuito?
	8. ¿Quién lleva la ventaja Psicológica en los enfrentamientos Mati vs. Evelyn y Koke vs. Mono?
*/

USE exatlon;

-- ====================================================================================================================================
-- 1. ¿Cuál es el porcentaje de victorias de cada atleta?
-- ====================================================================================================================================

-- SOLUCIÓN
WITH victorias AS (
	SELECT 
		tiradorGanador,
		COUNT(tiradorGanador) AS Victorias
	FROM enfrentamientos
	GROUP BY tiradorGanador
), 
derrotas AS(
	SELECT 
		tiradorPerdedor,
		COUNT(tiradorPerdedor) AS Derrotas
	FROM enfrentamientos
	GROUP BY tiradorPerdedor
)
SELECT 
	a.nombre,
    a.apellido,
	Victorias,
    Derrotas,
    Victorias / (Victorias + Derrotas) AS `%V`
FROM 
	atletas AS a 
    LEFT JOIN victorias AS v 
		ON a.idAtleta = v.tiradorGanador
    LEFT JOIN derrotas AS d 
		ON a.idAtleta = d.tiradorPerdedor
ORDER BY `%V` DESC;



-- ====================================================================================================================================
-- 2. ¿Cuál es el porcentaje de victorias sin contar eliminación?
-- ==================================================================================================================================== 

-- SOLUCIÓN
WITH victorias AS (
	SELECT 
		tiradorGanador,
		COUNT(tiradorGanador) AS Victorias
	FROM 
		enfrentamientos 
        JOIN juegos USING(idJuego)
	WHERE 
		juegos.nombre NOT IN ('Eliminación')
        AND idJuego <= 25
	GROUP BY tiradorGanador
), 
derrotas AS(
	SELECT 
		tiradorPerdedor,
		COUNT(tiradorPerdedor) AS Derrotas
	FROM 
		enfrentamientos 
        JOIN juegos USING(idJuego)
	WHERE 
		juegos.nombre NOT IN ('Eliminación')
        AND idJuego <= 25
	GROUP BY tiradorPerdedor
)

SELECT 
	a.nombre,
    a.apellido,
	Victorias,
    Derrotas,
    CONCAT( ROUND(Victorias / (Victorias + Derrotas) * 100, 0), '%' )AS `%V`
FROM 
	atletas AS a 
    LEFT JOIN victorias AS v 
		ON a.idAtleta = v.tiradorGanador
    LEFT JOIN derrotas AS d 
		ON a.idAtleta = d.tiradorPerdedor
WHERE 
	a.sexo = 'F' 
    AND a.nombreEquipo = 'Azul'
ORDER BY `%V` DESC;



-- ====================================================================================================================================
-- 3. ¿Quién le ha ganado a KOKE, MATI y al MONO?
-- ====================================================================================================================================

-- SOLUCIÓN
SELECT 
	CONCAT( a2.nombre, ' ', a2.apellido ) AS Campeón,
    CONCAT( a1.nombre, ' ', a1.apellido ) AS `Vencio al campeón`
FROM 
	(SELECT DISTINCT 
		tiradorGanador,
		tiradorPerdedor
	FROM
		enfrentamientos) encuentros_distintos
	LEFT JOIN atletas AS a1 ON a1.idAtleta = tiradorGanador
    LEFT JOIN atletas AS a2 ON a2.idAtleta = tiradorPerdedor
WHERE 
	encuentros_distintos.tiradorPerdedor IN (SELECT idAtleta 
											 FROM atletas 
                                             WHERE nombre IN ('Koke', 'Mario', 'Mati') )
ORDER BY 1,2;



-- ====================================================================================================================================
-- 4. ¿Cuál ha sido el marcador de cada uno de los juegos?
-- ====================================================================================================================================

-- SOLUCIÓN
WITH VictoriasAzules AS (
	SELECT 
		idJuego, 
		COUNT( nombreEquipo ) AS victorias
	FROM 
		enfrentamientos AS e 
		LEFT JOIN atletas AS a 
			ON e.tiradorGanador = a.idAtleta
	WHERE 
		nombreEquipo = 'Azul'
	GROUP BY 
		idJuego
	ORDER BY 
		idJuego
	),
VictoriasRojas AS (
	SELECT 
		idJuego, 
		COUNT( nombreEquipo ) AS victorias
	FROM 
		enfrentamientos AS e 
		LEFT JOIN atletas AS a 
			ON e.tiradorGanador = a.idAtleta
	WHERE 
		nombreEquipo = 'Rojo'
	GROUP BY 
		idJuego
	ORDER BY 
		idJuego
)
SELECT 
	idJuego AS Numero,
	nombre AS Juego,
    CONCAT(VA.victorias,'-',VR.victorias) AS `Marcador (A-R)`
FROM 
	VictoriasAzules AS VA
	INNER JOIN VictoriasRojas AS VR USING(idJuego)
    INNER JOIN juegos USING( idJuego )
WHERE 
	nombre NOT IN ('Zona del peligro','Eliminación');
    


-- ====================================================================================================================================
-- 5. ¿Cuantos relevos han sucedido?
-- ====================================================================================================================================

SELECT 
	idJuego AS Numero,
	nombre AS Juego,
    CONCAT(VA.victorias,'-',VR.victorias) AS `Marcador (A-R)`
FROM 
	(SELECT 
		idJuego, 
		COUNT( nombreEquipo ) AS victorias
	FROM 
		enfrentamientos AS e 
		LEFT JOIN atletas AS a 
			ON e.tiradorGanador = a.idAtleta
	WHERE 
		nombreEquipo = 'Azul'
	GROUP BY 
		idJuego
	ORDER BY 
		idJuego) AS VA
	INNER JOIN 
		(SELECT 
			idJuego, 
			COUNT( nombreEquipo ) AS victorias
		FROM 
			enfrentamientos AS e 
			LEFT JOIN atletas AS a 
				ON e.tiradorGanador = a.idAtleta
		WHERE 
			nombreEquipo = 'Rojo'
		GROUP BY 
			idJuego
		ORDER BY 
			idJuego) AS VR USING(idJuego)
    INNER JOIN juegos USING( idJuego )
WHERE 
	nombre NOT IN ('Zona del peligro','Eliminación')
    AND ABS(VA.victorias - VR.victorias) = 1;

    

-- ====================================================================================================================================
-- 6. ¿Cuál es el porcentaje de victorias de cada atleta sobre los atletas que tienen porcentaje de victorias positivo?
-- ====================================================================================================================================

-- SOLUCIÓN
WITH victorias AS (
	SELECT 
		tiradorGanador,
		COUNT(tiradorGanador) AS Victorias
	FROM 
		enfrentamientos 
        JOIN juegos USING(idJuego)
	WHERE 
		juegos.nombre NOT IN ('Eliminación')
	GROUP BY tiradorGanador
), 
derrotas AS(
	SELECT 
		tiradorPerdedor,
		COUNT(tiradorPerdedor) AS Derrotas
	FROM 
		enfrentamientos 
        JOIN juegos USING(idJuego)
	WHERE 
		juegos.nombre NOT IN ('Eliminación')
	GROUP BY tiradorPerdedor
),
atletasPositivos AS (
	SELECT 
		a.idAtleta,
		CONCAT( ROUND(Victorias / (Victorias + Derrotas) * 100, 0), '%' )AS `%V`
	FROM 
		atletas AS a 
		LEFT JOIN victorias AS v 
			ON a.idAtleta = v.tiradorGanador
		LEFT JOIN derrotas AS d 
			ON a.idAtleta = d.tiradorPerdedor
	WHERE 
		ROUND(Victorias / (Victorias + Derrotas)) >= 0.5
	ORDER BY 
		`%V` DESC
),
victoContraPositivos AS (
	SELECT 
		tiradorGanador,
		COUNT(tiradorGanador) AS Victorias
	FROM 
		enfrentamientos 
        JOIN juegos USING(idJuego)
	WHERE 
		juegos.nombre NOT IN ('Eliminación')
        AND tiradorPerdedor IN (SELECT idAtleta FROM atletasPositivos)
	GROUP BY tiradorGanador
),
derroContraPositivos AS (
	SELECT 
		tiradorPerdedor,
		COUNT(tiradorPerdedor) AS Derrotas
	FROM 
		enfrentamientos 
        JOIN juegos USING(idJuego)
	WHERE 
		juegos.nombre NOT IN ('Eliminación')
        AND tiradorGanador IN (SELECT idAtleta FROM atletasPositivos)
	GROUP BY tiradorPerdedor
)
SELECT 
	CONCAT( a.nombre, ' ', a.apellido) AS Nombre,
	CONCAT( 
		ROUND( COALESCE( Victorias / (Victorias + Derrotas ), 0) * 100, 0), 
        '%' ) AS `%V`
FROM 
	atletas AS a 
	LEFT JOIN victoContraPositivos AS vCP 
		ON a.idAtleta = vCP.tiradorGanador
	LEFT JOIN derrotas AS dCP 
		ON a.idAtleta = dCP.tiradorPerdedor
ORDER BY 
	Victorias / (Victorias + Derrotas) DESC;



-- ====================================================================================================================================
-- 7. ¿Cuántos juegos se han llevado acabo en cada circuito?
-- ====================================================================================================================================

-- SOLUCIÓN
SELECT 
	idCircuito AS Numero,
    COALESCE(nombreNarrado, nombreCircuito) AS Nombre,
    COUNT( idJuego ) AS `Número de Juegos`
FROM 
	circuitos
    JOIN juegos USING(idCircuito)
GROUP BY 
	idCircuito
ORDER BY 
	COUNT( idJuego ) DESC;
    
    
    
-- ====================================================================================================================================
-- 8. ¿Quién lleva la ventaja Psicológica en los enfrentamientos Mati vs. Evelyn y Koke vs. Mono?
-- ====================================================================================================================================

-- SOLUCIÓN
SELECT 
	CONCAT( a.nombre, ' ', a.apellido) AS Nombre,
    COUNT(tiradorGanador) AS Victorias
FROM 
	enfrentamientos e 
    JOIN atletas a ON a.idAtleta = e.tiradorGanador
    JOIN atletas a2 ON a2.idAtleta = e.tiradorPerdedor
WHERE 
	tiradorGanador IN (SELECT idAtleta FROM atletas WHERE nombre IN ('Mati', 'Evelyn', 'Koke', 'Mario'))
    AND tiradorPerdedor IN (SELECT idAtleta FROM atletas WHERE nombre IN ('Mati', 'Evelyn', 'Koke', 'Mario'))
GROUP BY 
	tiradorGanador
ORDER BY 
	a.sexo DESC,
    tiradorGanador;
    