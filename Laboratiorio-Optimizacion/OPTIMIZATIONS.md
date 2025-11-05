# Orden de ejecucion
1. FROM
2. JOIN
3. WHERE
4. GROUP BY
5. HAVING
6. SELECT
7. ORDER BY
8. LIMIT

Si ponemos un `WHERE` sobre alguna columna de una tabla especifca (no sobre el resultado del `JOIN`), entonces primero se va a filtrar esa tabla y despues se hace el `JOIN`. Se denomica `Predicate Pushdown`. El optimizador "empuja" esta condición hacia abajo en el árbol de ejecución para que se aplique lo más cerca posible de la fuente de datos.


![[Pasted image 20251017133337.png]]

# Sargable (Search ARGument ABLE)
Son buscables. 

El  
```sql
IN 
```
no sabe que esta ordenado. Hace full scan. Busca uno, despues el otro, despues el otro, etc.

En 
```sql
BETWEEN 5678 AND 5632
```
sabe que esta ordenado. Busca esas 4 filas.

Las operaciones no son sargable.

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

## Utilidad
Sirve cuando el outer input es pequeño y el inner input es grande. 
- Una de las tablas (la tabla **externa** o _outer_) es **pequeña** (pocas filas).
- La tabla **interna** (o _inner_) tiene un **índice** eficiente en la columna de unión. Esto permite una búsqueda rápida por cada fila de la tabla externa.
- Es la opción más simple y a menudo la más rápida para **conjuntos de datos pequeños** o cuando el criterio de unión es muy **selectivo**.
- Se utiliza para todo tipo de uniones (_joins_), incluyendo las no equidad.
## Algoritmo
Para cada fila en la `Tabla A` se itera sobre *todas* las filas de la `Tabla B` y se comparan las condiciones del `ON`. Si la compracion es exitosa, se envian las filas al output del `JOIN`. Es como un filtro algoritmico, no un producto cartesiano.

`Complejidad: O(M x N)`

![[Pasted image 20251017133505.png]]
# Merge Join

## Utilidad
Solo sirve si la junta tiene al menos un predicado de igualdad. Es un método eficiente para unir grandes conjuntos de datos, especialmente cuando los datos de entrada ya están ordenados por las claves de `JOIN` o se pueden ordenar de manera eficiente.

- **Ambas entradas** de la unión ya están **ordenadas** por las columnas de la unión. Esto sucede comúnmente si las columnas de unión tienen **índices agrupados (clustered)** o si se realiza un escaneo de índice ordenado.
- Es la operación de unión **más eficiente** para conjuntos de datos **grandes** si los datos ya están ordenados.
- Si los datos no están ordenados, el optimizador podría insertar un operador `Sort` (ordenación) antes del `Merge Join`, lo que puede hacerlo **caro** para grandes volúmenes de datos debido al costo de la ordenación.
- Se utiliza principalmente para uniones de **equidad** (_equi-joins_).
## Algoritmo 
Hace uso del ordenamiento de las tablas por indice. Se asegura que las tablas esten ordenadas con respecto a la columna del join (o sea, trata de que esten ordenadas por la columna que usamos para comparar, en el ejemplo de abajo, ordena ambas tablas por su `ProductID`). Luego se tienen dos punteros indices, uno para cada tabla, y se van comparando las filas. 
- Si el valor matchea, se juntan las filas y se agregan al output. Los dos punteros avanzan a la siguiente fila.
- Si el valor no matchea, el algoritmo avanza el puntero con el valor mas pequeño.

`Complejidad: O(M*log(M) + N*log(N))`

![[Pasted image 20251017135426.png]]

# Hash Join

## Utilidad 
Solo sirve si la junta tiene al menos un predicado de igualdad. Es particularmente eficaz para conjuntos de datos grandes y cuando las columnas de clave de unión no tienen índices adecuados para otros tipos de `JOIN`.

- Se unen **conjuntos de datos grandes** y **sin ordenar**.
- **No hay índices** útiles para el _Merge Join_ o el _Nested Loop Join_.
- Es una buena opción cuando el costo de ordenar los datos (para un _Merge Join_) sería mayor que el costo de crear la tabla hash.
- Funciona mediante dos fases:
    1. **Build (Construcción):** Crea una **tabla hash** en memoria con los datos de la entrada más pequeña.
    2. **Probe (Sondeo):** Escanea la otra entrada y busca coincidencias en la tabla hash.
- Requiere suficiente **memoria** para la tabla hash. Si no hay suficiente, utiliza `tempdb`, lo que puede reducir el rendimiento.
- Se utiliza **solo** para uniones de **equidad** (_equi-joins_).
## Algoritmo

### Fase de construccion
1. Se identifica la tabla mas pequeña entre las dos (La que pueda entrar en memoria mas facilmente), se designa como `Build Input`.
2. Para cada `fila` en la `Build Input` se calcula hash de la columna seleccionada en la condicion de join (Si la query era `FROM alumno JOIN ayudante ON alumno.DNI = ayudante.DNI` entonces calculamos el hash del DNI de todos los ayudantes porque probablemente en la facultad hay menos ayudantes que alumnos). 
3. Se guardan estas filas en una tabla de hash en memoria con el `hash` como la clave.
### Fase de sondeo
1. Se designa a la tabla mas grande entre las dos como `Probe Input`.
2. Para cada `fila` en la `Probe Input`, se calcula un valor de `hash` usando el valor de la columna seleccionada en la condicion de join, usando la misma funcion de hash.
3. Se usa este valor de `hash` para ver si existe esa clave en la tabla de hash en memoria.
4. Si el valor existe, se comparan los valores de las columnas de la condicion de `JOIN` de ambas filas para asegurarse de que estamos uniendo las dos filas de ambas tablas basandose en el hash y no una colision de la hash table. (Supongamos que en la query `FROM alumno JOIN ayudante ON alumno.DNI = ayudante.DNI` no sucede que el alumno tiene el mismo `DNI` que el ayudante, pero los dos `DNI`s dieron el mismo hash con la funcion de hasheo, una colision tipica) Hay que comparar los hashes y los valores de la columnas usadas en las condiciones de `JOIN` para asegurarnos de que no sea una `hash colission`.
5. Si la condicion de `JOIN` es verdadera, se envia la fila combinada al resultado del `JOIN`.

`Complejidad: O(M + N)`

![[Pasted image 20251017140030.png]]

En este ejemplo se usa HASH JOIN porque ya no esta garantizado el orden pues el  `Predicate Pushdown` filtra la tabla del `ProductVendor` por `StandardPrice` implicando que la tabla original ordenada ya no es la misma, fue filtrada. Las filas ya no son necesariamente contiguas!
![[Pasted image 20251017150548.png]]
# Operadores generales
## Table spool - Lazy spool 
Hay muchas tablas en memoria asi que las bajamos a disco. 

## Compute scalar
- Concatenar una cadena.
- Cambiar un tipo de data. Modifica los tipos de datos. 
Los count son count_big, si usas solo `count` va a usar el compute scalar para cambiar del int grande al chico.

## Filter 
Filtrar los datos antes del select. 

## Concatenacion
El Union que junta dos tablas. El union devuelve todos menos los duplicados. 
![[Pasted image 20251017151402.png]]

El UNION ALL es menos costoso que el UNION pero tengo el problema de los duplicados. Puede ser util cuando sabemos que las tablas no tienen filas repetidas.

# Integridad Referencial
Como a.StateProvinceID es una `Foreign Key`, sabemos que no es `NULL` y que existe, por lo que no hace falta ir a la tabla de `StateProvince` para buscarla, directamente la agarramos de la tabla `Address`.
![[Pasted image 20251017151707.png]]
![[Pasted image 20251017151819.png]]
___

## Key Lookup
**Qué hace:** El optimizador encontró un **índice no agrupado (non-clustered index)** llamado `PK_Address...` que contiene la columna `City`. Utiliza este índice para encontrar de manera muy eficiente la ubicación exacta de todas las filas donde `City = 'Mentor'`.

Para no tener que leer todas las fichas una por una, la base de datos usa un truco: tiene un **índice**, que es como un pequeño cuaderno aparte.
![[Pasted image 20251017151951.png]]

#### Paso 1: Usar el Cuaderno (Index Seek)
La base de datos no mira el archivo gigante. Primero va a su **cuaderno de índice** que solo tiene dos columnas: `Ciudad` y `Nº de Ficha`.
Encuentra "Mentor" muy rápido y anota el número de la ficha donde están esos datos. Por ejemplo, anota: "Ficha #583".
Esto es el **Index Seek**. Es muy rápido, pero solo le dio la ubicación, no la información completa. Recorremos todo el heap (NONCLUSTERED) y buscamos la PK del elemento, luego con esa PK vamos al paso 2.

#### Paso 2: Ir a Buscar la Ficha (Key Lookup)
Ahora que sabe el número de la ficha (#583), va al **archivo gigante principal** y busca directamente esa ficha para sacar toda la información que pediste con `SELECT *` (la calle, el código postal, etc.).
Este segundo paso es el **Key Lookup**.

![[Pasted image 20251017152019.png]]

### La Analogía del Índice de un Libro (Mejorada)
Pensemos de nuevo en el índice de un libro. Si buscas un término importante, como "Fotosíntesis", no aparecerá una sola vez en el libro. El índice te mostrará **todas las páginas** donde se menciona:
**Índice:**
- ...
- Fotosíntesis: págs. 45, 81, 112, 113, 205
- ...
La base de datos hace exactamente lo mismo. El índice de la columna `City` tiene una entrada para `'Mentor'`, y esa entrada contiene una lista de "punteros" o "marcadores" que apuntan a la ubicación exacta de cada fila de la tabla principal que tiene 'Mentor' como ciudad.

Cuando hay muchas filas con `'Mentor'`, el plan de ejecución funciona de esta manera:
1. **Index Seek (1 vez)**: Realiza **una única y muy rápida búsqueda** en el Árbol-B para encontrar el nodo hoja de `'Mentor'` y obtener la lista completa de todas las direcciones de las filas.
2. **Nested Loops + Key Lookup (muchas veces)**: El operador `Nested Loops` toma esa lista y, **por cada dirección en la lista**, ejecuta un `Key Lookup` para ir a la tabla principal y traer los datos completos (`SELECT *`) de esa fila.

Si hay muchos (como en City = 'London') entonces le conviene revisar el cluster directamente, porque vamos a tener que recorrer la tabla.

Mucho lookup -> Conviene revisar el cluster.
Poco lookup -> Buscamos el cluster de mentor y pedimos los indices.

### Escenario 1: Pocas Filas (WHERE City = 'Mentor')
En este caso, la consulta es muy **selectiva** (devuelve un porcentaje muy pequeño de las filas totales).
- **Plan A (el que elige): Index Seek + Key Lookup**
    - **Costo:** Un viaje rápido al índice para obtener una lista corta de direcciones + unos pocos viajes a la tabla principal para buscar cada fila.
    - **Por qué es barato:** El número de "Key Lookups" (viajes a la tabla principal) es muy bajo. El costo total es menor que leer la tabla entera.
- **Plan B (el que descarta): Table Scan (Escanear Tabla Entera)**
    - **Costo:** Leer la tabla de 1 millón de filas de principio a fin para encontrar las pocas que dicen 'Mentor'.
    - **Por qué es caro:** Es un desperdicio enorme de recursos leer 999,950 filas que no sirven.

### Escenario 2: Muchas Filas (WHERE City = 'London')
En este caso, la consulta es **no selectiva** (devuelve un gran porcentaje de las filas). Supongamos que el 30% de las direcciones son de Londres.
- **Plan A (el que descarta): Index Seek + Key Lookup**
    - **Costo:** Un viaje rápido al índice para obtener una lista larguísima de 300,000 direcciones + **¡300,000 viajes individuales a la tabla principal!**
    - **Por qué es caro:** Cada "Key Lookup" es una operación de I/O aleatoria, que es costosa. Hacer cientos de miles de estas operaciones es terriblemente ineficiente. Es como ir al supermercado 300,000 veces para comprar un solo producto cada vez.
- **Plan B (el que elige): Table Scan (Escanear Tabla Entera)**
    - **Costo:** Leer la tabla entera de principio a fin una sola vez.
    - **Por qué es más barato:** Aunque lee datos innecesarios, lo hace de forma secuencial y eficiente. Es como ir al supermercado una sola vez y comprar todo lo que necesitas de una pasada. Es mucho más rápido que los 300,000 viajes pequeños.

**Resultado:** Para 'Londres', el Plan B, aunque parezca bruto, es mucho más eficiente.

# Cluster
Un **"cluster"**, en el contexto de las bases de datos, **es** el índice agrupado.
### La Analogía del Diccionario
La mejor manera de entenderlo es con la analogía de un diccionario.
- Un **diccionario** es una tabla con un **índice agrupado** en la columna "palabra".
- Las palabras no están desordenadas. El libro entero está **físicamente ordenado** alfabéticamente por las palabras.
- No necesitas un índice separado al final del libro para encontrar una palabra. Simplemente abres el diccionario en la letra correcta y buscas. La palabra y su definición (los datos) están ahí mismo.
Una tabla con un índice agrupado funciona exactamente igual. Si creas un índice agrupado en la columna `UserID`, la base de datos reorganiza toda la tabla en el disco para que las filas estén físicamente ordenadas por `UserID`.

# Heap
Si una tabla no tiene un índice agrupado, se le llama **"Heap"** (montón)
- Un **Heap** es como una caja de fichas de vocabulario que has tirado al azar.
- No tienen ningún orden físico. Para encontrar una palabra, no tienes más remedio que revisar todas las fichas, una por una, desde el principio hasta el final.
- Este proceso de revisar todo es un **Table Scan**.

Imagina que creamos una tabla simple para registrar logs de un sistema. En muchos sistemas de bases de datos como SQL Server, si no defines explícitamente una `PRIMARY KEY` o un `CLUSTERED INDEX`, la tabla se crea como un Heap.
**Creación de la Tabla:**
```sql
CREATE TABLE dbo.SystemLogs (
    LogID INT IDENTITY(1,1), -- Un identificador, pero no una clave primaria
    LogMessage NVARCHAR(500),
    EventTime DATETIME
);
```

Esta tabla `SystemLogs` es un **Heap**.

# Parameter Sniffing
El **parameter sniffing** es un comportamiento de las bases de datos donde el motor de consultas "espía" (sniffs) el valor de un parámetro la **primera vez** que se ejecuta un procedimiento almacenado o una consulta parametrizada. Luego, crea y guarda (almacena en caché) un plan de ejecución optimizado específicamente para _ese valor inicial_.

El problema ocurre cuando ese plan guardado es terrible para otros valores que se usarán en el futuro.
### La Analogía del GPS
Imagina que usas una app de GPS para planificar una ruta.
1. **La Primera Vez (El "Sniffing"):** El primer viaje que calculas es de tu casa en un pueblo pequeño a la tienda de la esquina. El GPS ve que es un viaje corto y te da la ruta ideal: "Camina por la calle principal". Guarda esta ruta porque fue muy eficiente.
2. **La Siguiente Vez (El Problema):** Al día siguiente, quieres ir a la capital, que está a 100 km. Usas la misma app (el mismo "procedimiento almacenado"), pero con un destino diferente. En lugar de calcular una nueva ruta, el GPS perezosamente reutiliza la que guardó ayer: "Camina por la calle principal". 🤦

Esto es el parameter sniffing. La base de datos crea un plan de ejecución perfecto para el primer valor ("ir a la tienda"), pero luego aplica ciegamente ese mismo plan ineficiente para un valor muy diferente ("ir a la capital"), causando un rendimiento desastroso.

# Cobertura Indice
A covering index in SQL Server is a non-clustered index that contains all the columns required to satisfy a specific query, eliminating the need for the SQL Server Database Engine to access the base table or clustered index to retrieve additional column data. This can significantly improve query performance by avoiding "Key Lookups" or "RID Lookups," which are extra steps the optimizer takes to fetch data not present in the non-clustered index itself.
![[Pasted image 20251017154930.png]]

En pocas palabras, es un "truco" para hacer que una consulta sea extremadamente rápida al crear un índice que contiene **toda la información que la consulta necesita**, para que la base de datos no tenga que tocar la tabla principal en absoluto.

### La Analogía de el "machete" para un Examen
Imagina que la tabla `Person.Address` es un **libro de texto de 500 páginas**. Tu consulta es como una pregunta de examen: "Dame los códigos postales (`PostalCode`) de la provincia con ID 42 (`StateProvinceID = 42`)".
- **El Método Lento (sin este índice):** Irías al índice del libro (un índice normal) para encontrar "Provincia 42". El índice te diría: "Esa información está en las páginas 25, 83, 150...". Luego, tendrías que ir a cada una de esas páginas para buscar y anotar el código postal. Este segundo paso de "ir a la página" es el lento y costoso **`Key Lookup`**.
- **El Método Rápido (con este índice):** El `Índice de Cobertura` que creaste es como un **machete o hoja de resumen** para el examen. En esta machete, junto al nombre del tema "Provincia 42", ya tienes anotados directamente todos los códigos postales que necesitas.
    

¡No necesitas abrir el libro de texto para nada! Toda la respuesta está en tu pequeña y súper rápida hoja de resumen.