## 1.1 Describa brevemente limitaciones de las base de datos relacionales y con qu´e caracter´ısticas las base de datos NoSql mitigan este problema.

El problema de las bases de datos tradicionales es el costo de obtener muchos datos de diferentes entidades. Muchos JOINS son costosos. Las bases de datos NoSQL priorizan escalabilidad y disponibilidad.

**Escalabilidad Horizontal**: Se puede añadir un nuevo nodo para duplicar la capacidad de almacenamiento y procesamiento de datos.

**Esquema Flexible**: Se pueden agregar atributos sin tener que modificar el esquema de toda la base de datos.

**Consistencia Eventual**: Los *POST* pueden tardar milisegundos en replicarse en todos los nodos distribuidos, priorizando la rapidez de la escritura y la disponibilidad de la lectura sobre la consistencia.

## 1.2 Describa los cuatro tipos de base de datos NoSql.

**Key-Value**: Cada registro es una llave - valor. No tiene schema. Operaciones simples. `get`, `put` y `delete`. Se usa para cacheo, sesiones, carrito, etc.

**Document**: Se guarda la data en semi estructuras, en general JSON. Schemas flexibles, los documentos en la misma coleccion pueden tener estructuras diferentes. La BD almacena y recupera documentos. Los documentos pueden ser XML, JSON o BSON. Coleccion de pares nombre de campo:valor. Los valores pueden ser un valor simple o una estructura compleja como listas, otro documento o listas de documentos hijos.

**Wide-Column**: Cada registro tiene los valores dados por una columna particular para ese registro. No hay una estructura general en si. Se pueden tener o no los valores del schema. Hay columnas estaticas y columnas dinamicas. Una entidad tiene una partition key, los valores de las static columns, la clustering key y las columnas dinamicas. La primary key es *partition key* + *clustering key*. Si queres un dato especifico, tenes que traerlo con todos los datos especificos.

**Graph Database**: Guarda la informacion con entidades como nodos y aristas como relaciones. Se usan para relaciones. Es mas sencillo guardar la entidad y la relacion con otras entidades que usar una base de datos tradicional y hacer malabares con los joins para encontrar la conexion, muy ineficiente.

## 1.3 ¿Que es un espacio de nombres o bucket en una base de datos Key-Value?

Es una forma de segregar claves que pueden tener la misma key para el mismo producto pero diferentes valores. Por ejemplo guardar el nombre de un employee_id y su empleador. Podriamos tener Prod:12986:name en el bucket de *nombres* y un Prod:12986:name en el bucket de *empleadores*.

## 1.4. ¿De ejemplos de uso de TTL (time to live) en una base Key-Value?

Por ejemplo una key de una reserva de asientos en un sistema de cines mientras se hace la compra. Le das un TTL de 15 minutos a la reserva de asientos. Si no se efectuó la compra para entonces, se muere la reserva (se elimina de la db) y vuelven estar disponibles para otro usuario.

## 1.5. Compare Key-Value con Document Database, de ventajas y desventajas de una u otra.

Key-Value solo ve la key, es caja negra, no le interesa el valor. En Document Databse valor es típicamente JSON (o BSON), y la BD sí entiende su estructura interna.

**Key value** es extremadamente rapida pero solo permite buscar por la key, no por datos.

**Document database** permite indexar y consultar por cualquier campo dentro del documento. Ideal para aplicaciones en desarrollo ágil o con datos que evolucionan frecuentemente. El procesamiento y la indexación de documentos añaden una ligera sobrecarga.

## 1.6. Discuta ventajas y desventajas de que una Document Database sea schemaless.

Es mas facil prototipar una aplicacion, simplemente insertamos data con diferentes estructuras a medida que va avanzando el ciclo de desarrollo. Podemos traer datos en un formato conocido y printearlo sin mas para saber como esta compuesto.

Se puede hacer una bola de nieve de complejidad muy rapido. Sin estructuras fijas, la aplicacion puede sufirr en el ciclo de desarrollo, muchos ifs para detectar campos y recuperacion. Puede ser un infierno para equipos. No hay definiciones claras del sistema. Creo que si tenemos mucha data para traer, la base de datos puede sufrir de repeticion de informacion.
## 1.7. ¿En que casos puede ser conveniente desnormalizar?

Cuando queremos priorizar velocidad de lectura sobre consistencia. Insertamos los rregistros directamente y se organizan por la partition key.
## 1.8. Compare las Column Family Databases con otros tipos de bases de datos NoSQL

Las column family tienen denormalizacion, podriamos considerar a la primary key de las column family como las key de key-value donde separamos por buckets mientras que en column family separamos por clustering key + atributos especificos. Column family ofrece una serie de atributos dado la primary key mientras que key value solo te da un valor o document based te da datos no estructurados.Una vez que conseguuimos la key en column family, podemos obtener un rango de datos por la clustering key, mientras que en key value o docuument based te dan un document/valor en especifico

## 1.9. ¿A que se denomina consistencia eventual?

Que con el tiempo las escrituras se van a estandarizar en todos los nodos pero no necesariamente de forma instantanea. Puede suceder que un read lea un dato desacatualizado.

## 1.10. Explique el teorema CAP

**Consistency (C)**: Todos los nodos ven los mismos datos al mismo tiempo,
**Availability (A)**: Todas las consultas que llegan al nodo de la base de datos tienen que ser resueltas.
**Partition tolerance (P)**: El cluster puede sobrevivir a roturas de comunicacion que divida a los nodos en particiones que no pueden comunicarse entre si.

**Teorema CAP**: No se pueden garantizar las 3 propiedades a la vez. Solo un maximo de 2.

## 2.1. Dado el siguiente DER realizar por lo menos 3 diferentes esquemas para Document Databases.

```json
{
	{
		"idUsuario": x1,
		"nombre": y1,
		"password": z1,
		"grupos": ['a', 'b', 'c'],
	},
	{
		"idUsuario": x2,
		"nombre": y2,
		"password": z2,
		"grupos": ['a', 'd', 'e'],
	},
},
```

```json
{
    "idGrupo": "a",
    "nombre": "Administracion",
    "usuarios": ["x1", "x2", "x3"] 
}

{
    "idUsuario": "x1",
    "nombre": "y1",
    "password": "z1"
}
```

## 2.2. Dado el siguiente ejemplo en JSON sobre editoriales libros

```json
{ 
	{
		"titulo": "MongoDB: The Definitive Guide", 
		"autor": [ "Kristina Chodorow", "Mike Dirolf" ], 
		"fecha_pub": ISODate("2010-09-24"), 
		"paginas": 216, 
		"idioma": "English", 
		"editorial": { 
			"nombre": "O’Reilly Media",
			"fundada": 1980, 
			"ubicacion": "CA" 
		}, 
	},
	{ 
		"titulo": "50 Tips and Tricks for MongoDB Developer", 
		"autor": "Kristina Chodorow", 
		"fecha_pub": ISODate("2011-05-06"), 
		"paginas": 68, 
		"idioma": "English", 
		"editorial": { 
			"nombre": "O’Reilly Media", 
			"fundada": 1980, 
			"ubicacion": "CA" 
		},
	},
}
```

**(a) Modificar los documentos para que no se repitan los datos de las editoriales** 
```json
{ 
	{
		"titulo": "MongoDB: The Definitive Guide", 
		"autor": [ "Kristina Chodorow", "Mike Dirolf" ], 
		"fecha_pub": ISODate("2010-09-24"), 
		"paginas": 216, 
		"idioma": "English", 
		"editorial_id": 1, 
	},
	{ 
		"titulo": "50 Tips and Tricks for MongoDB Developer", 
		"autor": "Kristina Chodorow", 
		"fecha_pub": ISODate("2011-05-06"), 
		"paginas": 68, 
		"idioma": "English", 
		"editorial_id": 1,
	},
	{
		"editorial_id": 1,
		"nombre": "O’Reilly Media", 
		"fundada": 1980, 
		"ubicacion": "CA"
	},
}
```

**(b) Discutir en que contexto es mejor la representaci´on dada sobre la resuelta en el ´ıtem anterior**

Si la cantidad de datos relacionados con editoriales son pocas o no necesariamente hace falta consisstencia con respecto a estas. Para que gastar recursos en una entidad si casi nunca se fetchean libros por editorial o a poca gente le importa la coherencia de sus datos.

Al estar los datos de la editorial dentro del documento `Libro`, el sistema necesita una sola operación de lectura a disco (un GET), sin necesidad de un `JOIN` (como en SQL) o un `lookup` (como en MongoDB). Esto se traduce en menor latencia y mayor rendimiento.

## 2.3. Un congreso de ciencias de la computaci´on almacena datos de las publicaciones realizadas. Se guardan autores, art´ıculos y adem´as las relaciones entre art´ıculos (es decir art´ıculos que citan otros art´ıculos). El siguiente DER modela la situaci´on. Se pide que realice un modelo para una base de datos Column-Family tal que responda las siguientes consultas.

**Articulos dado un articulo**

```
ARTICULO
Titulo  | K
Fecha   | S
Autores | S 

ARTICULO_CITANTE
Titulo_Citado  | K
Titulo_Citante | C↓
Fecha_Citante  | 
```

La fecha *No tiene static* porque *cambia* para cada fila. Solo ponemos *S* cuando es el mismo valor para todas las filas de la partition key + clustering key ordenada.

Si nos hubieran pedido el autor, este tampoco tendria nada porque cambia para cada articulo.

**Autores que escribieron en una fecha dada**
```
AUTOR
Nombre     | K
Apellido   | K
Afiliacion | S

AUTORES_POR_FECHA
Fecha    | K
Nombre   | C↓
Apellido | C↓
```

## 2.4. Una empresa de video juegos realiza un juego en l´ınea y necesita guardar el estado de las partidas de los jugadores. Dicho estado debe almacenar: posici´on, nivel de vida, objetos encontrados y enemigos abatidos. El jugador deber´a poder jugar desde cualquier estado guardado eligiendo la fecha y hora en el que lo guardo. Se pide realizar un modelo para una base Key-Value que soporte lo descrito.

```
username: string
----------------
INTEGER
userid: integer

userid: integer
timestamp
---------------
HASH
posicion:int
vida:int


```
