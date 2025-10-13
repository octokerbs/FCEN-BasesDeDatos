## Consistencia de transacciones
1. Una transaccion puede **leer** o **escribir** un item `X` si previamente realizo un lock sobre `X` y todavia no lo liberó.
2. Si una transaccion realiza un lock sobre un item, debe liberarlo.
## Legalidad 
Si una transaccion quiere obtener un lock sobre un item lockeado por otra transaccion en un modo que conflictua (hay un write) entonces debe esperar hasta que se haga el unlock.

## 2PL (Two phase locking)
Primero lockeamos todos los elementos que necesitamos. Operamos. Desbloqueamos.
Jamas va a existir un lock despues de algun unlock.
```
T1: LOCK(A), LOCK(B), READ(A), WRITE(B), UNLOCK(A), UNLOCK(B), COMMIT
```
## 2PL Estricto
- Es 2PL
- No libera ninguno de sus locks de escritura hasta después de realizar el commit o el abort
## 2PL Riguroso
- Es 2PL
- No libera ninguno de sus locks de escritura o lectura hasta después de realizar el commit o el abort.
## Grafo de precedencia con bloqueo
1. Hacer un nodo para cada $T_i$.
2. Si $T_{i}$ hace un rl(X) o wl(X) y luego $T_j$ hace un wl(X). $T_{i}\rightarrow T_j$    
3. Si $T_i$ hace un wl(X) y $T_j$ hace un rl(X). $T_{i}\rightarrow T_j$   
Básicamente dice que si dos transacciones realizan un lock sobre el mismo ítem y al menos uno de ellas es un write lock se debe dibujar un eje desde la primera a la segunda.

Si el grafo no tiene ciclos, el orden de la historia serial equivalente se obtiene mediante una **ordenación topológica** del grafo. Esto simplemente significa poner los nodos en un orden lineal que respete la dirección de todas las flechas.
![[drawing2025-10-13 12.38AM]]
Elegimos primero al nodo sin aristas entrantes. T3, lo sacamos. Nos queda T1 y T2, sacamos nuevamente el nodo sin arisstas entrantes (al sacar T3, ahora queda T1 sin aristas entrantes), finalmente nos queda T2 solo,
Por lo tanto, el orden topologico es $T_{3}\rightarrow T_{1}\rightarrow T_{2}$ 

## Wait-Die
```
"Si eres más viejo, esperas; si eres más joven, mueres".
```
- **Si Ti es más antigua que Tj**: Ti **espera** a que Tj libere el recurso.
- **Si Ti es más joven que Tj**: Ti **muere** (es abortada y reiniciada).
## Wound-Wait
```
"Si eres más viejo, hieres; si eres más joven, esperas".
```
- Si una persona mayor (transacción antigua) llega y encuentra a una persona joven (transacción joven) usando el cajero, la persona mayor le pide que se quite (**hiere**) para usarlo ella.
- Si una persona joven (transacción joven) llega y encuentra a una persona mayor (transacción antigua) usándolo, la persona joven **espera**.