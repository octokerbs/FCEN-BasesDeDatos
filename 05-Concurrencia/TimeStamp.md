Cada transaccion $T_i$ tiene un timestamp.

- $st_i$: La transaccion $i$ comienza y se le asigna un *timestamp*.

## Lectura
1. Si una transaccion quiere leer algo que fue escrito por una transaccion mas nueva entonces la transaccion es **rechazada**. 
2. Si no, es **aceptada** y se actualiza el read time stamp (el time stamp de la ultima transaccion que la actualizo) para que sea el de la transaccion.

## Escritura
1. Si una transaccion quiere escribir un valor que ya fue leido por una transaccion mas joven, la transaccion es **rechazada**. 
2. Si una transaccion quiere escribir un valor que ya fue escrito por una transaccion mas joven, la operacion es **ignorada**, pero la transaccion continua. 
3. Si no, la operacion es **aceptada** y se actualiza el writing timestamp con el de la transaccion.

# MVTO

## Lectura
1. La transaccion $T_i$ lee la version de `X` con la WTS(X) mas alta que sea menor o igual al timestamp de $T_i$. Se actualiza la RTS de ese valor con la de la transaccion.

## Escritura
1. Se busca la versión de X con el `WTS` más alto que sea menor o igual a TS(​). Si TS(Ti​) < RTS(X​), significa que una transacción más joven ya ha leído la versión que $T_i$​ quiere modificar. La operación se **rechaza** y Ti​ se **aborta**.
2. De lo contrario, la operación se **acepta** y se crea una nueva versión $X_i$​ de X con WTS($X_i$​) = TS($T_i$​) y RTS($X_i$​) = TS($T_i$​).
