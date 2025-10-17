# Orden de ejecucion
1. FROM
2. JOIN
3. WHERE
4. GROUP BY
5. HAVING
6. SELECT
7. ORDER BY
8. LIMIT
![[Pasted image 20251017133337.png]]

# Sargable (Search ARGument ABLE)
Comparar columnas con valores especificos. Se escriben siguiendo las siguientes reglas:
- Evitar usar funciones o calculos de indices en el `WHERE`.
- Usar comparaciones directas cuando sea posible.
- Si necesitamos usar una funcion sobre una columna, considerar crear una columna computada o una funcion basada en indices, si la base de datos lo soporta.
## Consulta sargable
```sql
SELECT * FROM Usuarios WHERE edad = 30;
```
## Consulta no sargable
```sql
SELECT * FROM Usuarios WHERE YEAR(fecha_creacion) = 2023;
```
Al aplicar la función `YEAR()` a la columna `fecha_creacion`, el motor de la base de datos no puede usar un índice directamente sobre esa columna y, en su lugar, tendría que procesar cada fila para obtener el año, lo que es mucho más lento.

# Nested Loops Join

## Algoritmo
Para cada fila en la `Tabla A` se itera sobre *todas* las filas de la `Tabla B` y se comparan las condiciones del `ON`. Si la compracion es exitosa, se envian las filas al motor para que las guarde. Es como un filtro algoritmico, no un producto cartesiano.

![[Pasted image 20251017133505.png]]