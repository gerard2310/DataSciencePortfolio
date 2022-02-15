-- EJERCICIO 2

-- Establecemos el entorno de trabajo en el esquema olympic para simplificar las futuras sentencias.
SET search_path = olympic;
SET datestyle = YMD;


-- APARTADO A
BEGIN WORK;

-- Generamos un dominio para email_type
CREATE DOMAIN email_type AS text
CHECK ( value ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' );

-- Creamos la columna email en las tablas tb_sponsor y tb_collaborator
ALTER TABLE tb_sponsor
ADD COLUMN email email_type;

ALTER TABLE tb_collaborator
ADD COLUMN email email_type;

COMMIT WORK;


-- APARTADO B

BEGIN WORK;
-- Generamos la tabla tb_athletes_info_log
CREATE TABLE olympic.tb_athletes_info_log (
	athlete_id CHARACTER(7) NOT NULL,
	discipline_id INTEGER NOT NULL,
	round_number INTEGER NOT NULL,
	athlete_name VARCHAR(50) NOT NULL,
	discipline_name VARCHAR(50) NOT NULL,
	mark VARCHAR(12) NOT NULL,
	rating INTEGER NOT NULL,
	info_log_dt DATE,
	CONSTRAINT pk_log PRIMARY KEY (athlete_id, discipline_id, round_number),
	CONSTRAINT fk_log_register FOREIGN KEY (athlete_id, discipline_id, round_number) 
	REFERENCES olympic.tb_register(athlete_id, discipline_id, round_number)
);

COMMIT WORK;


-- APARTADO C

BEGIN WORK;

CREATE OR REPLACE FUNCTION fn_athletes_info()
RETURNS trigger AS $$
DECLARE
mark_var VARCHAR(12);
ath_name tb_athlete.name%TYPE;
dis_name tb_discipline.name%TYPE;

BEGIN

-- Inserción de una fila
	IF (TG_OP = 'INSERT') THEN

-- Gestión de un bucle infinito, debe devolver NEW para continuar 
-- con el procedimiento tras insertar la fila en tb_register

		IF pg_trigger_depth() <> 1 THEN
			RETURN NEW;
		END IF;
	
-- Almacenamos las distintas variables
		IF (SELECT NEW.register_time IS NOT NULL) THEN
			mark_var = CAST (NEW.register_time AS VARCHAR(12));
		
		ELSE
			mark_var = CAST (NEW.register_measure AS VARCHAR(12));
		END IF;
		
		SELECT name INTO ath_name
		FROM tb_athlete
		WHERE athlete_id = NEW.athlete_id;

		SELECT name INTO dis_name
		FROM tb_discipline
		WHERE discipline_id = NEW.discipline_id;

-- Como el disparador es un BEFORE debemos insertar la fila en tb_register
-- y devolver NULL, para que el disparador no lo haga tras la ejecución
-- de este trigger procedure
		INSERT INTO olympic.tb_register(athlete_id, discipline_id, 
									round_number, register_ts, 
									register_position, register_time, 
									register_measure) 
		VALUES(NEW.athlete_id, NEW.discipline_id, NEW.round_number, 
			   NEW.register_ts, NEW.register_position, NEW.register_time,
			   NEW.register_measure);


-- Finalmente gestionamos si el valor ya existe en tb_athletes_info_log
		IF (SELECT EXISTS (SELECT athlete_id 
				   FROM tb_athletes_info_log 
				   WHERE athlete_id = NEW.athlete_id AND
				  discipline_id = NEW.discipline_id AND
				  round_number = NEW.round_number)) THEN
			RETURN NULL;
		ELSE
			INSERT INTO tb_athletes_info_log VALUES
					(NEW.athlete_id, NEW.discipline_id, NEW.round_number, ath_name,
					 dis_name,  mark_var, NEW.register_position, CURRENT_DATE);
			
			RETURN NULL;
		END IF;		
		RETURN NULL;
	END IF;

-- Actualización de una fila
	IF (TG_OP = 'UPDATE') THEN

-- Asignamos las distintas variables
			IF (SELECT NEW.register_time IS NOT NULL) THEN
				mark_var = CAST (NEW.register_time AS VARCHAR(12));

			ELSE
				mark_var = CAST (NEW.register_measure AS VARCHAR(12));
			END IF;

			SELECT name INTO ath_name
			FROM tb_athlete
			WHERE athlete_id = NEW.athlete_id;

			SELECT name INTO dis_name
			FROM tb_discipline
			WHERE discipline_id = NEW.discipline_id;

-- Si el valor existe en la tabla de auditoria solo tendremos que actualizarlo
		IF (SELECT EXISTS (SELECT athlete_id 
						   FROM tb_athletes_info_log 
						   WHERE athlete_id = NEW.athlete_id AND
						  discipline_id = OLD.discipline_id AND
						  round_number = OLD.round_number)) THEN
		
			UPDATE tb_athletes_info_log SET 
				(athlete_id, discipline_id, round_number,athlete_name, 
				 discipline_name, mark, rating, info_log_dt) = 
				(NEW.athlete_id, NEW.discipline_id, NEW.round_number, ath_name,
				dis_name, mark_var, NEW.register_position, CURRENT_DATE)
			WHERE 	athlete_id = NEW.athlete_id AND 
					round_number = NEW.round_number AND 
					discipline_id = NEW.discipline_id;

			RETURN NEW;

-- Si el valor no existe en la tabla de auditoria debemos añadirlo
		ELSE 
			INSERT INTO tb_athletes_info_log VALUES
			(NEW.athlete_id, NEW.discipline_id, NEW.round_number, 
			 ath_name,
			 dis_name,
			 mark_var,
			 NEW.register_position,
			 CURRENT_DATE
			);
			RETURN NEW;
	  	END IF;
	END IF;

-- Eliminación de un registro
	IF (TG_OP = 'DELETE') THEN
	
-- Solo tendremos que eliminar el registro si este existe en la tabla de logs
		IF (SELECT EXISTS (SELECT athlete_id 
						   FROM tb_athletes_info_log 
						   WHERE athlete_id = OLD.athlete_id AND
						  discipline_id = OLD.discipline_id AND
						  round_number = OLD.round_number)) THEN
			
			DELETE FROM tb_athletes_info_log WHERE 	athlete_id = OLD.athlete_id AND 
													round_number = OLD.round_number AND 
													discipline_id = OLD.discipline_id;
			RETURN OLD;
			
		ELSE
			RETURN OLD;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER tg_athletes_info
BEFORE INSERT OR DELETE OR UPDATE ON tb_register
FOR EACH ROW EXECUTE PROCEDURE fn_athletes_info();

COMMIT WORK;

--APARTADO D

BEGIN WORK;

-- Generamos un tipo de datos para almacenar 
-- los datos requeridos en el procedimiento almacenado.
CREATE TYPE sponsor_registers AS (
	email_sponsor email_type,
	sponsor_name VARCHAR(100),
	athlete_name VARCHAR(50),
	discipline_name VARCHAR(50),
	round_number INT,
	mark VARCHAR(12),
	rating INT,
	register_date DATE
);


-- Creamos la función 
CREATE OR REPLACE FUNCTION fn_get_info_by_sponsor(select_date DATE, sponsor VARCHAR(50))
RETURNS SETOF sponsor_registers AS $$
DECLARE
	datos_clientes sponsor_registers;
	email_sponsor email_type;
	sponsor_name VARCHAR(100);
	athlete_name VARCHAR(50);
	discipline_name VARCHAR(50);
	round_number INT;
	mark VARCHAR(12);
	rating INT;
	register_date DATE;
	register_time TIME;
	register_measure REAL;
	
BEGIN
-- Creamos un loop que nos devuelva las siguientes variables obtenidas de un conjunto de tablas
	FOR email_sponsor, sponsor_name, athlete_name, discipline_name, 
	round_number, rating, register_date, register_time, register_measure 
	IN 
	SELECT s.email, s.name, ath.name, d.name, r.round_number, r.register_position,
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
								r.discipline_id = d.discipline_id
								LOOP
  		
-- Asignamos al registro la marca dependiendo si es de tiempo o distancia
		IF (SELECT register_time IS NOT NULL) THEN
			mark = CAST (register_time AS VARCHAR(12));

		ELSE
			mark = CAST (register_measure AS VARCHAR(12));
		END IF;
-- Almacenamos los datos en la variable creada al principio y la devolvemos.	
		datos_clientes = (email_sponsor, sponsor_name, athlete_name, 
						  discipline_name, round_number, mark, rating, register_date);
		RETURN NEXT datos_clientes;
	END LOOP;
RETURN;
END;
$$ LANGUAGE plpgsql;

COMMIT WORK;