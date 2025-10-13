###### 2025-10-12
###### tags #databases

## Workspace de transacciones
Cada transaccion tiene su propio espacio de trabajo o buffer. 

Cuando una transaccion lee un valor `X` de la base de datos:
- Puede leer `X` de su valor actual en la base de datos. (el commiteado).
- Si otra transaccion escribio `X` y commiteo, va a leer el ultimo valor commiteado.

Cuando una transaccion escribe un valor `X`:
- Lo escribe en su espacio privado.
- Solo cuando commitea el valor se vuelve publico.


```
Borrador: Write que todavia no fue commiteado
Revista: Writes commiteados
```

## RC (Historia Recuperable)
Una historia es recuperable si una transacción realiza commit sólo después de que hicieron commit todas las transacciones de las cuales lee.
RC protege de que hagas commit en base a datos dudosos.
```
RC = "puedes leer borradores, pero no podes publicar tu artículo hasta que veas si la fuente era confiable."
```

## ACA (Avoids Cascading Aborts)
Una historia es **ACA** si las transacciones leen solo de transacciones ya commiteadas. No estamos leyendo nada que puede ser abortado.
```
ACA = "No leas el trabajo de otro hasta que esté confirmado (`COMMIT`)".
```

## ST (Stricta)
Una historia es **ST** cuando las transacciones  leen o escriben un item solo si otra transaccion que la escribio previamente haya commiteado o abortado. Si una transaccion $T_j$ escribió el item $X$ entonces tenemos que esperar a que $T_j$ commitee o aborte para poder leer o escribir $X$.
```
ST = "No leas NI escribas sobre el trabajo de otro hasta que esté confirmado"
```

Que una historia sea estricta no implica que sea serial.

`H1: w1(A); w2(B); c1; c2;`
- **¿Es Serial?** No. Las operaciones están entrelazadas (`w1` de T1, luego `w2` de T2, luego `c1` de T1, etc.).
- **¿Es Estricta?** Sí. T2 no lee ni escribe sobre el dato A (modificado por T1) antes de que T1 haga `COMMIT`. Y T1 no toca el dato B. No hay violación de la regla estricta.

## Dirty Read
Una transaccion escribe un valor que leyo antes de que otra transaccion la escriba y comitee.
```
Dirty read = “Leí un borrador que todavía no estaba publicado; si luego lo borran, quedo embarrado.”
```

## Lost Update
Una transaccion $T_i$ lee un valor. otra transaccion $T_j$ lee el mismo valor, $T_i$ escribe la actualizacion del valor, $T_j$ escribe otra actualizacion del mismo valor. $T_j$ sobre-escribio la escritura de $T_i$ porque esta no fue commiteada.
```
Lost update = “Escribí mi parte en el cuaderno, pero otro vino y me la tapó sin mirarla.”
```

