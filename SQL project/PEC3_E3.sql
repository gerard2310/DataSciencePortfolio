-- EJERCICIO 3

-- Establecemos el entorno de trabajo en el esquema olympic para simplificar las futuras sentencias.
SET search_path = olympic;

-- Apartado B

BEGIN WORK;
-- Creamos la función que devuelve un array de elementos json.

CREATE OR REPLACE FUNCTION fn_get_info_by_sponsor_json(select_date DATE, sponsor VARCHAR(50))
RETURNS json[] AS $$
DECLARE
	json_array json[];
	json_element json;

BEGIN
-- En la iteración generamos el objeto json que estamos buscando a 
-- partir de una selección sobre los datos requeridos
	FOR json_element IN SELECT to_json(var) FROM (
				SELECT 	s.email, s.name, ath.name, d.name, r.round_number, r.register_position, 
						r.register_ts::DATE, r.register_time, r.register_measure
			  	FROM 	tb_athlete ath, 
						tb_discipline d, 
						tb_register r, 
						tb_finance f,
						tb_sponsor s
			  	WHERE 
						s.name=sponsor AND 
						register_ts::date=select_date AND
						s.name = f.sponsor_name AND
						f.athlete_id = ath.athlete_id AND
						ath.athlete_id = r.athlete_id AND
						r.discipline_id = d.discipline_id) var LOOP

-- Añadimos el elemento json de esta iteración al array de la solución
				json_array = json_array || json_element;
				END LOOP;

-- Devolvemos el array que en cada iteración ha ido creciendo con todos los registros que 
-- cumplen los requisitos de la función de sponsor y fecha
RETURN json_array;
END;
$$ LANGUAGE plpgsql;

COMMIT WORK;