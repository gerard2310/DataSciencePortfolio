

CREATE SCHEMA vehiculos;

CREATE TABLE vehiculos.ventas(
combustible CHAR(3),
tipo CHAR(3),
marca CHAR(3),
ventas INTEGER,
CONSTRAINT pk_ventas PRIMARY KEY (combustible, tipo, marca),
CONSTRAINT c_combustible CHECK (combustible IN ('GAS', 'ELE')),
CONSTRAINT c_tipo CHECK (tipo IN ('VEN', 'REN')),
CONSTRAINT c_ventas CHECK (ventas >= 0)
);


INSERT INTO vehiculos.ventas VALUES ('GAS', 'VEN', 'VOL', 200);
INSERT INTO vehiculos.ventas VALUES ('GAS', 'REN', 'VOL', 400);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'VEN', 'VOL', 50);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'REN', 'VOL', 150);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'VEN', 'TES', 200);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'REN', 'TES', 150);
INSERT INTO vehiculos.ventas VALUES ('GAS', 'VEN', 'BMW', 100);
INSERT INTO vehiculos.ventas VALUES ('GAS', 'REN', 'BMW', 130);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'VEN', 'BMW', 50);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'REN', 'BMW', 80);
INSERT INTO vehiculos.ventas VALUES ('GAS', 'VEN', 'MER', 100);
INSERT INTO vehiculos.ventas VALUES ('GAS', 'REN', 'MER', 130);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'VEN', 'MER', 50);
INSERT INTO vehiculos.ventas VALUES ('ELE', 'REN', 'MER', 80);

SELECT * FROM vehiculos.ventas;

SELECT v.combustible, v.tipo, SUM(v.ventas)
FROM vehiculos.ventas v
GROUP BY
	GROUPING SETS (
	(v.combustible, v.tipo),
	(v.combustible),
	(v.tipo),
	());

SELECT v.combustible, v.tipo, SUM(v.ventas)
FROM vehiculos.ventas v
GROUP BY ROLLUP (v.combustible, v.tipo);

SELECT v.combustible, v.tipo, SUM(v.ventas)
FROM vehiculos.ventas v
GROUP BY CUBE (v.combustible, v.tipo);


CREATE SCHEMA restaurante;


DROP TABLE restaurante.ventas;

CREATE TABLE restaurante.ventas (
cliente_id INTEGER,
fecha DATE DEFAULT CURRENT_DATE,
precio_comida REAL NOT NULL,
IVA REAL NOT NULL,
factura REAL GENERATED ALWAYS AS (precio_comida*(1+(IVA/100))) STORED,
CONSTRAINT pk_restaurante PRIMARY KEY (cliente_id, fecha),
CONSTRAINT c_precio_comida CHECK (precio_comida >= 0),
CONSTRAINT c_IVA CHECK (IVA IN (0, 10, 21))
);

INSERT INTO restaurante.ventas VALUES (1, '2021-10-08', 15, 21);
INSERT INTO restaurante.ventas VALUES (2, DEFAULT, 25, 10);
INSERT INTO restaurante.ventas VALUES (3, DEFAULT, 18, 21);
INSERT INTO restaurante.ventas VALUES (4, '2021-10-23', 10, 0);
INSERT INTO restaurante.ventas VALUES (1, DEFAULT, 23, 21);
INSERT INTO restaurante.ventas VALUES (4, DEFAULT, 30, 21);

SELECT * FROM restaurante.ventas;
