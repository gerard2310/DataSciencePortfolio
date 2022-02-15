-- EJERCICIO 3

-- 3 a
INSERT INTO olimpic.tb_athlete
VALUES ('0000001','REMBRAND Luc', 'FRA', NULL);

INSERT INTO olimpic.tb_athlete
VALUES ('0000002', 'SMITH Mike', 'ENG', NULL);

INSERT INTO olimpic.tb_athlete
VALUES ('0000003', 'LEWIS Carl', 'USA', NULL);

-- 3 b
ALTER TABLE olimpic.tb_athlete
ADD CONSTRAINT c_substitute_country CHECK 
((country='ESP' AND substitute_id IS NOT NULL) OR (country<>'ESP'));

-- 3 c
CREATE VIEW olimpic.exercise33 AS
SELECT *
FROM olimpic.tb_athlete a
WHERE a.name LIKE 'PE%'
ORDER BY a.athlete_id DESC
WITH CHECK OPTION; 


-- 3 d
ALTER TABLE olimpic.tb_athlete
ADD COLUMN date_add DATE NOT NULL DEFAULT CURRENT_DATE;

-- 3 e
CREATE USER registerer WITH PASSWORD '1234' NOINHERIT;

GRANT USAGE ON SCHEMA olimpic TO registerer;
GRANT SELECT, INSERT, UPDATE, DELETE ON olimpic.tb_register TO registerer;
GRANT SELECT ON olimpic.tb_athlete TO registerer;