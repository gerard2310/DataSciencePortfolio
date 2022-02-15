-- EJERCICIO 1

-- Establecemos el entorno de trabajo en el esquema olympic para simplificar las futuras sentencias.
SET search_path = olympic;


-- APARTADO A

BEGIN WORK;
-- Cambiamos el tipo de datos de la columna register_date
ALTER TABLE tb_register 
ALTER COLUMN register_date TYPE TIMESTAMP;

-- Para que se actualice automaticamente al añadir una fila asignamos como valor por defecto NOW()
ALTER TABLE tb_register 
ALTER COLUMN register_date SET DEFAULT NOW();

-- Que no acepte nulos lo haremos mediante contraint de no nulo (NOT NULL)
ALTER TABLE tb_register 
ALTER COLUMN register_date SET NOT NULL;

-- Finalmente cambiamos el nombre de la columna a register_ts
ALTER TABLE tb_register
RENAME COLUMN register_date TO register_ts;
COMMIT WORK;


-- APARTADO B

BEGIN WORK;
-- Creamos el atributo register_updated
ALTER TABLE tb_register
ADD COLUMN register_updated TIMESTAMP;

-- Creamos la función que llamará el disparador
CREATE or REPLACE FUNCTION fn_register_inserted()
RETURNS trigger AS $$
BEGIN
	UPDATE tb_register SET register_updated = NEW.register_ts WHERE athlete_id = NEW.athlete_id AND 
																round_number = NEW.round_number AND 
																discipline_id = NEW.discipline_id;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Disparador que inicia la función tras cada inserción de un nuevo registro en tb_register
CREATE TRIGGER tg_register_inserted 
AFTER INSERT ON tb_register
FOR EACH ROW EXECUTE PROCEDURE fn_register_inserted();

COMMIT WORK;

--1c
BEGIN WORK;

-- Trigger procedure que actualiza el atributo register_updated 
-- con la hora de la actual (en el momento de la modificación)
CREATE or REPLACE FUNCTION fn_register_updated()
RETURNS trigger AS $$
BEGIN
-- Para evitar entrar en un bucle verificamos que estamos en la 
-- primera ejecución del disparador
	IF pg_trigger_depth() <> 1 THEN
		RETURN NEW;
	END IF;
	
	UPDATE tb_register SET register_updated = NOW() 
	WHERE 	athlete_id = NEW.athlete_id AND 
			round_number = NEW.round_number AND 
			discipline_id = NEW.discipline_id;
	RETURN NEW;
	
END;
$$ LANGUAGE plpgsql;

-- Disparador que inicia la función tras cada modificación de 
-- cualquier atributo de un registro en tb_register
CREATE TRIGGER tg_register_updated
AFTER UPDATE ON tb_register
FOR EACH ROW EXECUTE PROCEDURE fn_register_updated();

COMMIT WORK;