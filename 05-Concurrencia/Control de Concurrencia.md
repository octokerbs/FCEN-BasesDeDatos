## Consistencia de transacciones
1. Una transaccion puede **leer** o **escribir** un item `X` si previamente realizo un lock sobre `X` y todavia no lo liberó.
2. Si una transaccion realiza un lock sobre un item, debe liberarlo.
## Legalidad 
Si una transaccion quiere obtener un lock sobre un item lockeado por otra transaccion en un modo que conflictua (hay un write) entonces debe esperar hasta que se haga el unlock.

