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
ACA = "no lees borradores, solo cosas ya publicadas; así no te embarras."
```

## ST (Stricta)
Una historia es **ST** cuando las transacciones  leen o escriben un item solo si otra transaccion que la escribio previamente haya commiteado o abortado. Si una transaccion $T_j$ escribió el item $X$ entonces tenemos que esperar a que $T_j$ commitee o aborte para poder leer o escribir $X$.
```
ST = "ni lees ni reescribes borradores ajenos; esperas a que estén en la revista."
```

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

