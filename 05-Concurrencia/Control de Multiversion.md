## Nueva version
**Mantener multiples versiones de los records en la base de datos**
En vez de bloquear la fila, actualizarla y desbloquearla para que otros lean el dato actualizado. Creamos una nueva version de la misma fila y trabajamos sobre ella.
![[Pasted image 20251013151745.png]]
Una vez que el rojo commitea la actualizacion, la proxima vez que los azules vayan a leer nuevamente, van a hacerlo sobre la version nueva.

