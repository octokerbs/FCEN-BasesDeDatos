Cada transaccion $T_i$ tiene un timestamp.

- $st_i$: La transaccion $i$ comienza y se le asigna un *timestamp*.

## Lectura
1. Si una transaccion quiere leer algo que fue escrito por una transaccion mas nueva entonces la transaccion es **rechazada**. 
2. Si no, es **aceptada** y se actualiza el read time stamp (el time stamp de la ultima transaccion que la actualizo) para que sea el de la transaccion.

## Escritura
1. Si una transaccion quiere escribir un valor que ya fue leido por una transaccion mas joven, la transaccion es **rechazada**. 
2. Si una transaccion quiere escribir un valor que ya fue escrito por una transaccion mas joven, la operacion es **ignorada**, pero la transaccion continua. 
3. Si no, la operacion es **aceptada** y se actualiza el writing timestamp con el de la transaccion.


## Repaso timestamp

## Lectura $r_T(X)$
1. Si $TS(T) \geq WT(X) \wedge TS(T) \geq RT(X) \implies RT(X) = TS(T)$.    Si el timestamp de la transaccion es mayor a la ultima escritura y a la ultima lectura entonces registramos la nueva lectura.
2. Si $TS(T) < WT(X)$ hacemos rollback. Nuestra transaccion quiere leer algo que despues va a ser escrito.
## Escritura $w_T(X)$ 
1. Si $TS(T) \geq RT(X) \wedge TS(T) \geq WT(X) \implies WT(X) = TS(T)$. Si el timestamp de la transaccion es mayor a la ultima escritura y a la ultima lectura entonces registramos la nueva escritura.
2. Si $TS(T) \geq RT(X) \wedge TS(T) < WT(X)$. Ignoramos la escritura. La transaccion de escritura es despues de la ultima lectura pero antes que una proxima escritura sobre el mismo item.
3. Si $TS(T) <RT(X)$. Abortamos. Estamos tratando de escribir algo que otra transaccion ya leyo.

# MVTO
Cada version de un elemento de datos lleva un timestamp TS($T_i$) de la transaccion $T_i$ que fue la que creo la version.

1. Una operacion $r_i(X)$ se transforma en multiversion $r_i(X_j)$ donde $X_j$ es la version de $X$ que tiene el timestamp mas grande menor o igual que TS($T_i$) y que fue escrita por $T_j$.
2. Una operacion $w_i(X)$:
	1. Si una operacion $r_j(X_k)$ tal que TS($T_k$) < $TS(T_i)$ < TS($T_j$) ya existe en el schedule entonces $w_i(x)$ es rechazada y $T_i$ es abortada. Hay una transaccion mas joven con un *read* que la transaccion con el *write* actual.
	2. En otro caso $w_i(x)$ se transforma en $w_i(x_i)$ y es ejecutada.