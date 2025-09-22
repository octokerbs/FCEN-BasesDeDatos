-- FRECUENTA(Persona, Bar)
-- SIRVE (Bar, Cerveza)
-- GUSTA(Persona, Cerveza) 

-- a
SELECT s.Bar
FROM Sirve s 
JOIN Gusta g ON g.Cerveza = s.Cerveza 
WHERE g.Persona = 'Juan K.'

-- b
SELECT f.Persona 
FROM Frecuenta f
JOIN Gusta g ON g.Persona = f.Persona 
JOIN Sirve s ON s.Cerveza = g.Cerveza 
GROUP BY f.Persona
HAVING COUNT(*) > 1

-- c
SELECT g.Persona
FROM Gusta g
WHERE NOT EXISTS (
    SELECT * 
    FROM Frecuenta f 
    JOIN SIRVE s ON f.Bar = s.Bar
    WHERE f.Persona = g.Persona AND s.Cerveza = g.Cerveza
)

-- d
SELECT f.Persona
FROM Frecuenta f
GROUP BY f.Persona
HAVING COUNT(DISTINCT f.Bar) = (SELECT COUNT(*) FROM Sirve);
