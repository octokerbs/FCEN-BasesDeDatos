# Elementos del edificio

| **ELEMENTO DE LA BASE DE DATOS** | **ELEMENTO DE LA ANALOGIA DEL EDIFICIO**  | **FUNCION**                                                                                                                                                                                |
| -------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Tabla**                        | **El Edificio Completo**                  | Contiene todos los datos (aulas, oficinas, pasillos, etc.).                                                                                                                                |
| **Fila de Datos**                | **Un Aula o Espacio Específico**          | Contiene la información completa de una entidad (e.g., el aula 1301 con su capacidad, equipo, etc.).                                                                                       |
| **Índice (Clustered)**           | **El Orden Físico del Edificio**          | La forma en que las aulas están físicamente dispuestas y numeradas. **Solo puede haber uno** (el edificio solo tiene una disposición principal).                                           |
| **Índice (Non-Clustered)**       | **Un Cartel de Directorio en la Entrada** | Un mapa o lista ordenado por un criterio diferente (e.g., ordenado por "tipo de aula" o "capacidad"). Indica dónde buscar sin tener que recorrer todo el edificio. **Puede haber muchos**. |
| **Columnas Indexadas**           | **El Criterio de Búsqueda**               | El número de aula o el nombre del espacio que usas para buscar (ej. el número `1301`).                                                                                                     |
| **Table Scan**                   | **Recorrer Pasillo por Pasillo**          | Tienes que ir a cada aula y leer el cartel de la puerta para ver si es la que buscas. **Lento**.                                                                                           |
| **Index Seek**                   | **Mirar el Cartel de Directorio**         | Miras el mapa o la lista ordenada y te dirige directamente al pasillo y puerta correctos. **Rápido**.                                                                                      |

![[Pasted image 20251104203654.png]]
![[Pasted image 20251104203701.png]]

## CREACIÓN DE LA TABLA AULAS
```sql
CREATE TABLE Aula
(
    ID_Aula INT NOT NULL PRIMARY KEY CLUSTERED,
    -- Clave Agrupada: Define el orden físico
    Nombre_Aula NVARCHAR(50) NOT NULL,
    Piso INT NOT NULL,
    Capacidad SMALLINT NOT NULL,
    Equipamiento NVARCHAR(100)
);

-- 2. CREACIÓN DE ÍNDICES NO AGRUPADOS
-- Este índice permite búsquedas rápidas por Capacidad y Piso
CREATE NONCLUSTERED INDEX IX_Capacidad_Piso
ON Aulas (Capacidad, Piso);

-- Si generalmente usamos la capacidad para filtrar y el piso para ordenar, este índice es adecuado.
```

| **Operador de Plan**                   | **Consulta T-SQL (Ejemplo Práctico)**                                   | **Explicación y Analogía**                                                                                                                                                                                                                                                                        |
| -------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Clustered Index Seek** (Óptimo)      | `sql SELECT Nombre_Aula, Equipamiento FROM Aulas WHERE ID_Aula = 1301;` | **Analogía:** Sabes el número exacto del aula. El sistema va **directamente** a la ubicación física de la fila en el disco usando el orden de la clave agrupada (`ID_Aula`).                                                                                                                      |
| **Non-Clustered Index Seek**           | `sql SELECT Nombre_Aula FROM Aulas WHERE Capacidad = 50 AND Piso = 3;`  | **Analogía:** Buscas el aula por un criterio alternativo (Capacidad). El sistema usa el índice `IX_Capacidad_Piso` para **saltar** a las filas, ya que `Capacidad` es la columna líder del índice.                                                                                                |
| **Key Lookup** (Malo si es recurrente) | `sql SELECT Nombre_Aula, Equipamiento FROM Aulas WHERE Capacidad = 50;` | **Analogía:** El Directorio Secundario (`IX_Capacidad_Piso`) te dice qué aulas tienen capacidad 50. Como la consulta pide el `Equipamiento` (que **no** está en el índice secundario), debe usar el `ID_Aula` (la clave de agrupación) para **buscar** el resto de la información en el edificio. |
| **Clustered Index Scan**               | `sql SELECT * FROM Aulas WHERE Equipamiento = 'PCs';`                   | **Analogía:** Quieres las aulas con "PCs". El orden físico es por `ID_Aula`, no por `Equipamiento`. SQL Server debe **recorrer todo el edificio** (fila por fila, en orden numérico) y verificar el equipo de cada aula.                                                                          |
| **Index Scan** (En Índice No Agrupado) | `sql SELECT Capacidad, Piso FROM Aulas;`                                | **Analogía:** Quieres saber la capacidad y el piso de **todas** las aulas. SQL Server **barre completamente** el índice `IX_Capacidad_Piso`. Esto es eficiente porque lee solo ese índice estrecho (solo dos columnas + el puntero) y no el archivo de datos principal completo.                  |
| **Sort** (Costoso)                     | `sql SELECT * FROM Aulas ORDER BY Equipamiento DESC;`                   | **Analogía:** Las aulas están ordenadas por `ID_Aula`. Para ordenar por `Equipamiento`, el sistema debe **copiar todas las filas relevantes a memoria (o disco)** y ordenarlas. Este es un trabajo extra que consume CPU/Memoria.                                                                 |


