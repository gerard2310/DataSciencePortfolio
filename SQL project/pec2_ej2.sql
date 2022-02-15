--EJERCICIO 2

-- 2 a

SELECT *
FROM olimpic.tb_athlete a
WHERE a.name LIKE 'PE%'
ORDER BY a.athlete_id DESC;

-- 2 b

SELECT d.name AS discipline_name, a.name AS athlete_name, a.athlete_id
FROM (olimpic.tb_discipline d INNER JOIN olimpic.tb_play p ON d.discipline_id=p.discipline_id) INNER JOIN 
	olimpic.tb_athlete a ON p.athlete_id=a.athlete_id
WHERE a.country='FRA' AND d.type='JUMP'
ORDER BY d.name ASC, a.name DESC;

-- 2 c
SELECT d.discipline_id, d.name, COUNT(*) AS total_athletes
FROM (olimpic.tb_discipline d INNER JOIN olimpic.tb_play p ON d.discipline_id=p.discipline_id) INNER JOIN 
	olimpic.tb_athlete a ON p.athlete_id=a.athlete_id
GROUP BY d.discipline_id
HAVING COUNT(*) = (SELECT MAX(total_athletes)
							 		FROM (SELECT d1.discipline_id, COUNT(*) AS total_athletes
											FROM (olimpic.tb_discipline d1 INNER JOIN olimpic.tb_play p1 ON 
												  	d1.discipline_id=p1.discipline_id) INNER JOIN 
													olimpic.tb_athlete a1 ON p1.athlete_id=a1.athlete_id
											GROUP BY d1.discipline_id) AS subquery);
											
-- 2 d
SELECT a.athlete_id, a.name, a.country, COUNT(*) AS disciplines_practiced
FROM (olimpic.tb_discipline d INNER JOIN olimpic.tb_play p ON d.discipline_id=p.discipline_id) INNER JOIN 
	olimpic.tb_athlete a ON p.athlete_id=a.athlete_id
GROUP BY a.athlete_id
HAVING COUNT(*) > 1;

-- 2 e
SELECT a.athlete_id, a.name, d.name, COUNT(*) AS rounds_participated
FROM (olimpic.tb_athlete a INNER JOIN olimpic.tb_register r ON a.athlete_id=r.athlete_id) INNER JOIN
	olimpic.tb_discipline d ON d.discipline_id=r.discipline_id
GROUP BY a.athlete_id, d.name
HAVING COUNT(*) = (SELECT MAX(rounds_participated)
							 		FROM (SELECT a1.athlete_id, d1.name, COUNT(*) AS rounds_participated
											FROM (olimpic.tb_athlete a1 INNER JOIN olimpic.tb_register r1 ON 
												  	a1.athlete_id=r1.athlete_id) INNER JOIN
													olimpic.tb_discipline d1 ON d1.discipline_id=r1.discipline_id
											GROUP BY a1.athlete_id, d1.name) AS subquery);