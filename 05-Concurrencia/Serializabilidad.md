## Transacciones
Una **transacción** es una secuencia de operaciones. 
$$T_{i} \subseteq \{w_{i}(X); r_{i}(X)\} \cup \{c_{i}, a_{i}\}$$
Las operaciones pueden ser escritura, lectura, commiteo o abort. $T_i$ es la transacción i. $w_i$ es la escritura de la transacción i sobre el item $X$. La lectura es similar y luego $c_i$ y $a_i$ representan el commit o el abort de dicha transaccion. Notar que solo puede existir uno de los dos para cada transaccion.

No puede suceder que el orden de $c_i$ o $a_i$ este antes que una operacion que no pertenezca a este conjunto.
## Schedule
Es una secuencia generalmente intercalada de operaciones pertenecientes a diferentes transacciones. Notar que todas las operaciones de las transacciones deben aparecer en el mismo orden en el schedule.

Los resultados de las transacciones estan abiertos. Este representa un estado vivo/dinamico de las operaciones de las transacciones. Todavia faltan operaciones o terminacion.
## History
Un schedule terminado. Resultado de cada transaccion ya conocido. Contiene todas las operaciones incluida la terminacion.

Sea $T = \{t_{1}, ..., t_{n}\}$ un conjunto de transacciones, donde cada $t_i$ tiene la forma $t_{i}= (op_{i}, <_{i})$  siendo $op_i$ las operaciones de $t_i$ y $<_i$ su orden. Una historia para $T$ es un par $s = (op(s), <_{s)}$ tal que:
1. Las operaciones de la historia pertenecen a las operaciones de las transacciones y los respectivos commits/aborts.
2. Si la transaccion $i$ hizo un commit, entonces el commit pertenece a la historia y no un abort, y viceversa.
3. Los ordenes pertenecen a la historia.
4. Toda operacion de la transaccion $i$ estan antes que el commit o abort de dicha transaccion.
5. Dadas dos operaciones de la historia, si ambos acceden al mismo elemnto y una de ellas es una escritura entonces su orden es diferente. 

### Operaciones conflictivas
Dos operaciones `p` y `q` son conflictivas si y solo si al menos una de ellas es de escritura.
### Equivalencia
Dos historias son conflicto equivalentes si estan definidas sobre el mismo conjunto de transacciones y el orden de las operaciones conflictivas no abortadas es el mismo.
### Historia serializable
Una historia es conflicto serializable si es conflicto equivalente a alguna historia serial.
### Grafo de precedencia
Grafo dirigido para saber si una historia es serializable o no. La historia es serializable si el grafo es aciclico.
1. Cada nodo representa una **transacción** (`T1`, `T2`, `T3`, …).
2. Dibujamos una **arista dirigida** de `Ti → Tj` si:
	1. `Ti` ejecuta una operación sobre un dato `X` antes que `Tj` en la historia.
	2. Ambas operaciones son **conflictivas** (es decir, al menos una es escritura).
	3. El orden en la historia es `Ti` antes que `Tj`.

Cada arista `Ti → Tj` significa que `Ti` **debe preceder** a `Tj` en cualquier ejecución equivalente serial. 

`Todo este analisis es meramente teorico, en el mundo real las bases de datos previenen que se generen historias no serializables`

Supongamos:
- T1 = r1(X); w1(X); r1(Y); w1(Y) 
- T2 = r2(Z); r2(Y); w2(Y); r2(X); w2(X) 
- T3 = r3(Y); r3(Z); w3(Y); w3(Z) 
- H = r2(Z); r2(Y); w2(Y); r3(Y); r3(Z); r1(X); w1(X); w3(Y); w3(Z); r2(X); r1(Y); w1(Y); w2(X) (Historia compuesta por las tres transacciones)
![[Pasted image 20250928212558.png]]

### Order-Preserving Conflict Serializable (OCSR)
Una historia se denomica OCSR si
1. Es `conflicto-serializable`
2. Todas las transacciones ocurren completamente antes que otra transaccion de la misma historia.


