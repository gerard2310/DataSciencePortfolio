-- PEC4 Ejercicio 1
-- Establecemos el entorno de trabajo en el esquema olympic para simplificar las futuras sentencias.
SET search_path = olympic;


-- APARTADO 1

BEGIN WORK;

-- Creamos la secuencia que empieza en 1001 y se incremente en una unidad
CREATE SEQUENCE seq_athlete_id INCREMENT BY 1 START WITH 1001;

-- Modificamos la tabla tb_athlete para añadir la columna id que usa la secuencia
ALTER TABLE tb_athlete
ADD COLUMN id integer DEFAULT nextval('seq_athlete_id');

-- Reseteamos la secuencia para que asigne los valores desde 1001, como actualizaremos todos
-- los valores no habrá repeticiones.
ALTER SEQUENCE seq_athlete_id RESTART;

-- Actualizamos los valores existentes
UPDATE tb_athlete
SET id = DEFAULT
FROM (	SELECT athlete_id 
	  	FROM tb_athlete
	 	ORDER BY athlete_id DESC) AS subquery
WHERE tb_athlete.athlete_id = subquery.athlete_id;

COMMIT WORK;

-- APARTADO 2

BEGIN WORK;

WITH RECURSIVE triathlon_positions AS (
	-- Consulta no recursiva, buscamos el primer clasificado en la tercera ronda de triatlon
	SELECT
		d.name, 
		r.round_number, 
		r.register_position, 
		d.discipline_id, 
		a.name AS ath_name,
		CAST (register_position || ': ' || a.name AS TEXT) AS a_position
	FROM
		tb_register r, 
		tb_discipline d, 
		tb_athlete a
	WHERE 	
		r.discipline_id = d.discipline_id AND 
		a.athlete_id=r.athlete_id AND 
		d.name = 'Triathlon' AND 
		r.round_number = 3 AND 
		r.register_position = 0
	UNION ALL
	
	-- Consulta recursiva, buscamos los atletas que han finalizado en las siguientes posiciones 
	-- y los añadimos a la columna a_position
	SELECT
		tp.name,
		sel.round_number,
		sel.register_position,
		tp.discipline_id,
		tp.ath_name,
		CAST (tp.a_position || ' -> ' || sel.register_position || ': ' || sel.ath_name AS TEXT) AS a_position
	FROM
		(SELECT 
		 	di.name, 
		 	re.round_number, 
		 	re.register_position, 
		 	di.discipline_id, 
		 	ath.name AS ath_name
		FROM 
		 	tb_register re, 
		 	tb_discipline di, 
		 	tb_athlete ath
		WHERE 
		 	re.discipline_id = di.discipline_id AND 
		 	ath.athlete_id=re.athlete_id AND 
		 	di.name = 'Triathlon' AND 
		 	re.round_number = 3) sel
		INNER JOIN triathlon_positions tp
			ON ((sel.register_position) = (tp.register_position + 1))
	WHERE
		sel.discipline_id = tp.discipline_id AND 
		tp.name = 'Triathlon' AND 
		tp.round_number = 3
)

-- Mostramos la CTE
SELECT 
	name, 
	round_number, 
	register_position, 
	a_position
FROM 
	triathlon_positions
ORDER BY 
	register_position;
	
COMMIT WORK;


-- APARTADO 3
BEGIN WORK;

SELECT
	sel.atleta,
	sel.disciplina,
	sel.pais,
	sel.mejor_tiempo,
	sel.tiempo_medio_pais_disciplina,
	sel.num_participaciones,
	SUM(sel.num_participaciones) OVER (PARTITION BY sel.disciplina, sel.pais) AS total_participantes_por_disciplina_pais
FROM
-- Subquery de la que obtendremos todas las columnas y nos permitirá operar con num_participaciones y tot_participaciones
	(
		SELECT 
			a.name AS atleta,
			d.name AS disciplina,
			a.country AS pais,
		-- Obtenemos el mejor tiempo por disciplina
			MIN(register_time) OVER (PARTITION BY d.name) AS mejor_tiempo,
		
		-- Registro promedio en una disciplina por pais
			AVG(register_time) OVER (PARTITION BY d.name, a.country) AS tiempo_medio_pais_disciplina,
		
		-- Agregación del número de participaciones de un atleta en una disciplina
			ROW_NUMBER() OVER (PARTITION BY d.name, a.country, a.name) AS num_participaciones,
		
		-- Computo del número total de participaciones de un atleta en una disciplina
			COUNT(*) OVER (PARTITION BY d.name, a.country, a.name) AS tot_participaciones
		FROM
			tb_athlete a,
			tb_discipline d,
			tb_register r	
		WHERE
			a.athlete_id = r.athlete_id AND
			d.discipline_id = r.discipline_id
		ORDER BY
			disciplina,
			pais,
			atleta
	) sel
WHERE
-- Gestión de los duplicados debido a la agregación de las participaciones de un atleta
	sel.num_participaciones = sel.tot_participaciones;

COMMIT WORK;