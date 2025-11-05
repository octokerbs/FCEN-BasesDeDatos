
## Terminos SQL
---

| **Término SQL Server**           | **Analogía 0+Inf Building**                                                                                                   | **Función Principal en SQL Server**                                                                                   | **Implicación de Rendimiento**                                                                                                               |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Clustered Index Seek**         | Ir **directo** al aula por su número físico.                                                                                  | Accede directamente a las filas usando el índice agrupado.                                                            | **Óptimo**. Lectura mínima de datos.                                                                                                         |
| **Non-Clustered Index Seek**     | Buscar en un **Directorio Secundario** (`0+Inf Index`).                                                                       | Accede a las filas usando la clave de un índice secundario.                                                           | **Bueno**, pero ten cuidado con los `Key Lookups` que le sigan.                                                                              |
| **Key Lookup (Clustered)**       | **Ir a la Puerta** desde el Directorio.                                                                                       | Búsqueda secundaria en el índice agrupado para obtener **columnas que faltan** en el índice no agrupado.              | **Costoso (I/O) si se hace miles de veces**. Se soluciona creando un índice de **Cobertura**.                                                |
| **Table Scan**                   | Recorrer **todos los pasillos** y puertas.                                                                                    | Lee la tabla completa porque no existe un índice agrupado o el Optimizador lo ignoró.                                 | **Peor Rendimiento**. Indica falta de índice apropiado o una consulta poco selectiva.                                                        |
| **Clustered Index Scan**         | Recorrer **todo el edificio** en orden numérico.                                                                              | Lee todas las filas en el orden del índice agrupado.                                                                  | Caro si la consulta no necesita _todas_ las filas.                                                                                           |
| **Filter**                       | El **Guarda de Seguridad** que revisa un criterio.                                                                            | Aplica la cláusula `WHERE` o `HAVING` y descarta filas.                                                               | Es bueno si filtra una gran cantidad de datos, pero si aparece tarde, significa que se leyeron muchos datos inútiles.                        |
| **Sort**                         | La operación de **reordenar** una pila de expedientes.                                                                        | Ordena un conjunto de datos (por `ORDER BY`, `GROUP BY`, `DISTINCT`, etc.).                                           | **Costoso en CPU y Memoria** si los datos no caben en la RAM.                                                                                |
| **Nested Loops Join**            | **Parejas de Búsqueda:** Por cada persona en el Aula A, revisar cada persona en el Aula B.                                    | Une dos tablas iterando sobre la tabla externa para buscar coincidencias en la interna.                               | **Ideal** cuando una entrada es pequeña y la otra tiene un `Seek` eficiente (índice).                                                        |
| **Hash Match**                   | **Clasificación Masiva:** Usar una mesa gigante para clasificar personas por una característica y luego buscar coincidencias. | Une dos tablas creando una tabla hash temporal.                                                                       | **Ideal** para grandes volúmenes de datos **sin ordenar**. **Consume mucha Memoria**.                                                        |
| **Merge Join**                   | **Combinar dos listas pre-ordenadas** en una sola.                                                                            | Une dos tablas que ya están ordenadas por la clave de unión.                                                          | **Más Rápido** para grandes volúmenes de datos, _si_ las entradas provienen de un índice agrupado o ya están ordenadas (evitando un `Sort`). |
| **Compute Scalar**               | Un **cálculo** que realiza una persona.                                                                                       | Realiza cálculos simples (funciones, conversiones, expresiones).                                                      | Bajo costo, pero indica que se está haciendo trabajo de cálculo en el motor.                                                                 |
| **Cardinality Estimation Error** | **Fila vs. Real:** El Optimizador esperaba 10 alumnos, ¡pero llegaron 1000!                                                   | Ocurre cuando la estimación de filas es muy diferente del número real (por estadísticas desactualizadas o complejas). | **Provoca la elección de un mal plan**, por ejemplo, usando un `Hash Match` costoso cuando debería haber usado un `Nested Loop` eficiente.   |
|                                  |                                                                                                                               |                                                                                                                       |                                                                                                                                              |
# Por que no se usa siempre el Clustered index seek?

Porque no siempre se busca la tabla por el indice. Tal vez buscamos por otro dato trivial de la fila. 

| **Tipo de Búsqueda** | **Consulta T-SQL**                                        | **Resultado en el Plan Estimado**                                                                                                                             |
| -------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Seek (Óptimo)**    | `SELECT * FROM Pedidos WHERE ID_Pedido = 100`             | Realiza un **`Clustered Index Seek`** porque usa la clave del índice agrupado.                                                                                |
| **Scan (Lento)**     | `SELECT * FROM Pedidos WHERE Fecha_Pedido > '2025-01-01'` | Probablemente realice un **`Clustered Index Scan`** (o un `Table Scan` si no hay índice agrupado), porque está buscando por una columna diferente a la clave. |

# Optimizaciones no tan obvias

Si en la tabla `Productos` (agrupada por `ID_Producto`), ejecutas: `SELECT * FROM Productos WHERE Nombre LIKE 'C%'`

Aunque uses el nombre del producto, si la columna `Nombre` no está indexada o si el optimizador estima que el 90% de los productos empiezan por 'C', el optimizador podría optar por un **`Clustered Index Scan`** si considera que es más rápido que ir saltando con múltiples `Index Seek`s.

El *seek* es cuando sabemos el indice de la fila y vamos directamente ahi (Tal vez un indexeo o un binary search) mientras que el scan hace una fuerza bruta leyendo toda la tabla

# Seek vs Scan

### Index Seek 

| **Característica** | **Descripción**                                                                                                                        | **Ejemplo Edificio**                                                                    |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| **Selectividad**   | **Muy alta**. La consulta busca una cantidad **pequeña** de filas en relación con el total.                                            | Buscas la oficina **1301** (solo 1 fila).                                               |
| **Mecanismo**      | **Búsqueda Logarítmica (Árbol B)**. Va del nodo raíz, pasando por los nodos intermedios, hasta llegar al nodo hoja donde está la fila. | Usas el índice maestro para ir directamente al pasillo 1300 y a la primera puerta 1301. |
| **Costo**          | Proporcional al **número de filas que califican**. Bajo I/O.                                                                           | Solo tocas las puertas y pasillos que necesitas. **Ideal**.                             |
| **Requisito**      | Las columnas del `WHERE` deben coincidir con las columnas iniciales del índice.                                                        |                                                                                         |

## Index Scan
Se lee el indice creado

Supongamos que las aulas tienen una capacidad en su fila. Supongamos que queremos buuscar un aula.

**Si la Columna `capacity` NO está en NINGÚN índice:** Ocurre un `Table Scan` (si la tabla es un Heap) o un **`Clustered Index Scan`** (si la tabla está agrupada por, digamos, `ID_Aula`). SQL Server tiene que leer _todas_ las filas para encontrar las que cumplen `capacity = 50`.

**Si la Columna `capacity` está en un Índice NO Agrupado:** Aquí la búsqueda es mucho más eficiente. Directamente tenemos un nonclsutered index que nos dice "EN este indice ordenamos el B-tree por las capacidades, las aulas con capacidad 50 son estas, mira!"

# Heap
Si no se especifica la palabra clave "clustered", la tabla se crea como un heap.
```sql
CREATE TABLE Empleados_Heap (
    ID_Empleado INT NOT NULL,
    Nombre NVARCHAR(100),
    -- La PK se crea como NONCLUSTERED por defecto.
    -- Los datos subyacentes (las filas) quedan en un HEAP.
    CONSTRAINT PK_Empleados PRIMARY KEY (ID_Empleado) 
);
```

Las filas se insertan **donde haya espacio libre** en el archivo de datos. No hay un orden lógico o físico basado en los valores de ninguna columna (como un ID o una fecha). Las filas pueden estar esparcidas por todo el archivo, incluso si fueron insertadas secuencialmente.

Para encontrar una fila en un Heap, SQL Server **no tiene otra opción** que realizar un **`Table Scan`** (Barrido de Tabla).
- El sistema debe leer **todas las páginas** de datos de la tabla, de principio a fin.
- Aplica la condición `WHERE` a cada fila que lee hasta encontrar la coincidencia.
- Esto es lo que tú llamas **fuerza bruta** o, técnicamente, una lectura secuencial completa.
- **Páginas Desocupadas:** SQL Server mantiene un seguimiento de las páginas de datos que tienen **espacio libre disponible** (utiliza estructuras especiales llamadas **IAMs** y **PFSs**).
- **Inserción:** La nueva fila se inserta en la **primera página** que el sistema encuentra que tiene espacio suficiente para ella.
- **Razón :** Si simplemente se insertara al final (añadir al archivo), el espacio libre dejado por las filas eliminadas en el medio del archivo de datos nunca se reutilizaría, lo que llevaría a un crecimiento masivo e innecesario del archivo de datos (`.mdf`) y a un desperdicio de espacio en disco.

$\therefore$ Mucha fragmentacion en el heap