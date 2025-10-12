![[Pasted image 20250929011007.png]]

1. Si $T_1$ aborta entonces la lectura de $T_2$ sobre $X$ es invalida. El commit de $T_2$ ES INVALIDO. Hay que abortar.
2. Si $T_1$ aborta entonces $T_2$ tiene que abortar para mantener la consistencia. No puede leer un valor de una transaccion abortada.
3. Al haber ambos abortado, es complicado llevar un registro de cual fue el valor correcto. Imaginemos que tal vez el sistema solo guarda el valor previo al ultimo write. En este caso, con dos writes seguidos, perdemos ese ultimo valor para siempre.

## Problemas de recuperabilidad
- Lost Update: Se lee una variable, otro proceso la actualiza, se sobreescribe con el valor previamente leido. Perdimos la actualizacion que hizo el otro proceso.
- Inconsistent-read: Una transaccion lee un dato. Otra transaccion modifica ese dato. La transaccion actual vuelve a leer ese dato que fue cambiado. La lectura es inconsitente. En una misma transaccion el dato cambio de valores.
- Dirty-read: Transaccion 1 modifica una variable. Transaccion 2 lee la variable. Transaccion 1 aborta. Transaccion 2 escribe con la variable que fue abortada. La lectura esta sucia porque no es valida para escribir.

## Lectura entre transacciones
Dadas dos transacciones $T_i$ y $T_j$ decimos que $T_i$ lee X de $T_j$ si $T_i$ lee $X$ y $T_j$ fue la última transacción que escribió $X$ y no abortó antes de que $T_i$ lo leyera.
1. $w_j(X)$ < $r_i(X)$
2. $r_{i}(X)\leq a_j$  
3. Si hay algún $w_{k}(X)$ tal que $w_{j}(X)$ < $w_{k}(X)$ <$r_{i}(X)$ entonces $a_k < r_{i}(X)$

- RC (Historia Recuperable): Intuitivamente una historia es recuperable si una transacción realiza commit sólo después de que hicieron commit todas las transacciones de las cuales lee.
- ACA (Avoids Cascading Aborts): Lee sólo valores de transacciones que ya hicieron commit
- ST (Stricta): No se puede leer ni escribir un ítem hasta que la transacción que lo escribió previamente haya hecho commit o abort.

$$
ST \subset ACA \subset RC
$$
- RS (Rigurous Scheduler): Para todo par de transacciones $t_i$, $t_j$. Si los reads de $t_j$ estan antes que los writes de $t_i$ entonces los aborts de $t_j$ estan antes que los writes de $t_i$ o los commits de $t_j$ estan antes que los writes de $t_i$.