-- PREGUNTAS
/* 
	1. ¿Cuál es el porcentaje de victorias de cada atleta?
    2. ¿Cuál es el porcentaje de victorias sin contar zona del peligro ni eliminación?
    3. ¿Quién no le ha ganado a KOKE, MATI y al MONO?
    4. ¿Cuál ha sido el marcador de cada uno de los juegos?
    5. ¿Cuantos relevos han sucedido?
    6. ¿Cuál es el porcentaje de victorias de cada atleta sobre los atletas que tienen porcentaje de victorias positivo?
    7. ¿Cuántos juegos se han llevado acabo en cada circuito?
*/

USE exatlon;

-- ====================================================================================================================================
-- 1. ¿Cuál es el porcentaje de victorias de cada atleta?
-- ====================================================================================================================================

SELECT * FROM atletas;
SELECT * FROM enfrentamientos;

-- CHECK
SELECT idJuego, COUNT(numero) FROM enfrentamientos GROUP BY idJuego;

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

SELECT DISTINCT nombre FROM juegos;
SELECT * FROM atletas;

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

/*
	Comparando con la tabla que presento Rosique en el primer duelo de eliminación Femenil 
	los porcentajes toman en cuenta todo (incluyendo Zona del peligro) y son redondeados a 0 decimales ,
    donde no hay coincidencia es con 
    Matí que tiene 75% pero yo calcule un 66%
    Doris que tiene 65% pero yo calcule un 73%
    Karen que tiene 28% pero yo calcule un 33%
    
    Antes de pasar a la siguiente pregunta necesito todos los enfrentamientos entre MATI vs Doris o Karen,
    juego, fecha, programa y numero
*/

SELECT 
	idJuego,
    numero,
    tiradorGanador,
    tiradorPerdedor,
    fecha,
    programa
FROM 
	enfrentamientos JOIN juegos USING(idJuego)
WHERE 
	tiradorGanador IN (SELECT idAtleta FROM atletas WHERE nombre IN ('Mati','Doris','Karen') )
    AND tiradorPerdedor IN (SELECT idAtleta FROM atletas WHERE nombre IN ('Mati','Doris','Karen') )
    AND idJuego <= 25
ORDER BY idJuego, numero;
/*
	idJuego | numero
	8			16            Mati gana y yo registre que gana Karen
    8			18			  Mati gana y yo registre que gana Doris
*/

-- Resta por encontrar el enfrentamiento donde registré que Doris le gana a Matí y no es verdad
SELECT 
	idJuego,
    numero,
    tiradorGanador,
    tiradorPerdedor,
    programa
FROM 
	enfrentamientos JOIN juegos USING(idJuego)
WHERE 
	tiradorGanador IN (SELECT idAtleta FROM atletas WHERE nombre = 'Doris' )
    AND tiradorPerdedor IN (SELECT idAtleta FROM atletas WHERE nombre = 'Mati' )
    AND idJuego <= 25
ORDER BY idJuego, numero;

-- Todas estan registradas correctamente a excepción de la que ya habia encontrado
-- Hay que revisar todas las derrotas de Mati
SELECT 
	idJuego,
    numero,
    tiradorGanador,
    tiradorPerdedor,
    programa
FROM 
	enfrentamientos JOIN juegos USING(idJuego)
WHERE 
    tiradorPerdedor IN (SELECT idAtleta FROM atletas WHERE nombre = 'Mati' )
    AND idJuego <= 25
ORDER BY idJuego, numero;

-- Las derrotas de Mati estan bien registradas, a exepción de las dos que ya encontramos
-- Lo más seguro es que el Exatlón registro mal un enfrentamiento entre Doris y Mati, dandole una v+ a Mati

/*
	Ya actualice la tabla Enfrentamientos, le agregue dos victorias a Matí y concluimos que el exatlón le dio 
    una de mas, y a Doris una menos, en la presentación de los porcentajes de la primera eliminación femenil (programa 12) 
*/

-- Un tablero donde se presente el porcentaje de victorias dividido por equipo y sexo y donde pueda filtrar un rango de fechas


-- ====================================================================================================================================
-- 3. ¿Quién le ha ganado a KOKE, MATI y al MONO?
-- ====================================================================================================================================

SELECT 
	"Mati" AS Campeón,
	CONCAT( nombre, ' ', apellido) AS Atleta_vencedor
FROM atletas 
WHERE 
	idAtleta IN (SELECT tiradorGanador FROM enfrentamientos 
					 WHERE 
						tiradorPerdedor = (SELECT idAtleta FROM atletas WHERE nombre = 'Mati')
					 );
                     
SELECT DISTINCT 
	tiradorGanador,
    tiradorPerdedor
FROM
	enfrentamientos;

-- SOLUCIÓN
SELECT 
	CONCAT( a2.nombre, ' ', a2.apellido )AS Campeón,
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
-- Tabla con juego del nombre y marcador en formato "Azul-Rojo"
/*
	1. Enfrentamientos la voy a cruzar con atletas para obtener el color del atleta ganador
    2. Para cada juego cuento cuantos azules hay
*/

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
/*
	1. Encontrar a los atletas con record positivo
    2. Encontrar vicotrias y derrotas contra los positivos
    3. Unir victorias y derrotas contra positivos
*/

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
