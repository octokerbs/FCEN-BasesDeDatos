# 2 - Introducción a Protocolos de Bloqueo o Locking
## 2.1
```
T1 = r1(A); w1(A); r1(B); w1(B) 
T2 = r2(A); w2(A); r2(B); w2(B)

(a)
T1 = l1(A); r1(A); w1(A); l1(B); r1(B); w1(B); u1(B); u1(A); c1;
T2 = l2(A); r2(A); w2(A); l2(B); r2(B); w2(B); u2(B); u2(A); c2;

(b)
H = l1(A); r1(A); w1(A); u1(A); l2(A); l2(B); r2(B); w2(B); u2(B); r2(A); w2(A); u2(A); l1(B); r1(B); w1(B); u1(B); c1; c2;
```
## 2.2
```
T1 = l1(A); A = A + 2; l1(B); B = A + 5; u1(B); u1(A); l1(C); C = 2 ∗ C; u1(C); a1; 
T2 = l2(A); A = A + 1; l2(E); E = A + 8; l2(D); u2(E); D = D/5; u2(A); u2(D); c2;

H = l1(A); A = A + 2; l1(B); B = A + 5; u1(B); u1(A); l2(A); A = A + 1; l2(E); E = A + 8; l2(D); u2(E); D = D/5; u2(A); u2(D); c2; l1(C); C = 2 ∗ C; u1(C); a1; 
```
En este caso la transaccion 2 lee el valor de A que fue modificado por la transaccion 1 pero no fue commiteado. Finalmente la transaccion 2 commitea pero la transaccion 1 aborta.
## 2.3
(A) ![[drawing2025-10-12 6.34PM]]
Efectivamente es serializable.

(B) 
```
H = l1(A); l1(B); A = A + B; u1(A); u1(B); c1; l2(C); C = C + 2 u2(C); l2(B); B = B - 1; u2(B); c2; l3(B); B = B*2; u3(B); l3(C); C = C * C * C; u3(C); c3; l4(C); l4(D); l4(E); C = D + E; u4(C); u4(D); u4(E); c4
```
## 2.4
```
T1 = r1(A); w1(A); r1(B); w1(B) 
T2 = r2(A); w2(A); r2(B); w2(B)

T1' = rl1(A); r1(A); w1(A); rl1(B); u1(A); r1(B); w1(B); u1(B);
T2' = rl2(A); rl1(B); r2(A); w2(A); r1(B); w1(B); u1(A); u1(B);
```

## 2.5
```
T1 = l1(A); l1(B); u1(A); u1(B) 
T2 = l2(B); l2(A); u2(B); u2(A)
```

(A) las dos son 2PL porque todos los locks se hacen antes que cualquier unlock.
(B) 
```
H = rl1(A); rl2(B); wl1(B); wl2(A); u2(B); u2(A); u1(A); u1(B);
```
- T1 pide read lock para A, se lo dan.
- T2 pide read lock para B, se lo dan.
- T1 pide write lock para B, tiene que esperar a que T2 lo libere.
- T2 pide write lock para A, tiene que esperar a que T1 lo libere.
- Deadlock.

# 3 - Sistemas de Bloqueo con varios modos
## 3.1
(a)
```
T1 = wl1(A); A = A + 1; wl1(B); B = A + B; u1(A); u1(B) 
T2 = rl2(A); wl2(C); C = A + 1; wl2(D); D = 1; u2(A); u2(D); u2(C)

H = rl2(A); wl2(C); C = A + 1; wl2(D); D = 1; u2(A); wl1(A); A = A + 1; wl1(B); B = A + B; u1(A); u1(B); u2(D); u2(C)
```
(b) No porque luego de desbloquear A para la transaccion 2, bloqueamos A y B.

## 3.2
![[drawing2025-10-12 9.23PM]]
Es serializable.
```
H = rl2(A); wl2(B); u2(A); u2(B); c2; rl3(A); wl3(A); u3(A); c3; rl1(B); rl1(A); wl1(C); u1(A); u1(B); u1(C); c1; rl4(B); u4(B); wl4(A); u4(A)
```

## 3.3
```
H1: rl1(A); rl2(A); rl3(A); u1(A); rl5(B); u5(B), wl1(B); wl2(C); u1(B); rl3(B); u3(A); u2(A); wl4(A); u4(A); rl1(D); u1(D); wl4(D); u4(D); wl5(A); u5(A); u2(C); u3(B)
```
(a) y (b)
![[drawing2025-10-12 10.16PM]]
Hay un loop entre $T_1$ y $T_5$. No es serializable.

(c)
```
T1 = rl(A); u(A); wl(B); u(B); rl(D); u(D);
No es 2PL. Para que lo sea debe estar estructurado de la siguiente manera: 
T1' = rl(A); wl(B); rl(D); u(A); u(B); u(D);

T2 = rl(A); wl(C); u(A); u(C);
Es 2PL.

T3 = rl(A); rl(B); u(A); u(B); 
Es 2PL.

T4 = wl(A); u(A); wl(D); u(D);
No es 2PL. Para que lo sea debe estar estructurado de la siguiente manera:
T4' = wl(A); wl(D); u(A); u(D);

T5 = rl(B); u(B); wl(A); u(A);
No es 2PL. Para que lo sea debe estar estructurado de la siguiente manera:
T5' = rl(B); wl(A); u(B); u(A);
```

(d)
2PL estricto
```
T1' = rl(A); wl(B); rl(D); u(A); c1; u(B); u(D);
T2  = rl(A); wl(C); u(A); c2; u(C);
T3  = rl(A); rl(B); u(A); u(B); c3;
T4' = wl(A); wl(D); c4; u(A); u(D);
T5' = rl(B); wl(A); u(B); c5; u(A);
```

2PL riguroso
```
T1' = rl(A); wl(B); rl(D); c1; u(A); u(B); u(D);
T2  = rl(A); wl(C); c2; u(A); u(C);
T3  = rl(A); rl(B); c3; u(A); u(B);
T4' = wl(A); wl(D); c4; u(A); u(D);
T5' = rl(B); wl(A); c5; u(B); u(A);
```

## 3.4
```
T1: rl1(A); wl1(B); u1(A); u1(B) 
T2: rl2(A); u2(A); rl2(B); u2(B) 
T3: wl3(A); u3(A); wl3(B); u3(B) 
T4: rl4(B); u4(B); wl4(A); u4(A)
```
(a)
```
rl1(A); wl1(B); u1(A); u1(B); rl2(A); u2(A); rl2(B); u2(B); wl3(A); u3(A); wl3(B); u3(B); rl4(B); u4(B); wl4(A); u4(A)
```
(b)
```
H1 : wl3(A); rl4(B); u3(A); rl1(A); u4(B); wl3(B); rl2(A); u3(B); wl1(B); u2(A); u1(A); wl4(A); u1(B); rl2(B); u4(A); u2(B)
```
![[drawing2025-10-12 11.54PM]]
No es serializable.

(c) 
```
T1 = rl(A); wl(B); u(A); u(B);
T2 = rl(A); u(A); rl(B); u(B); = rl(A); rl(B); u(B); u(A);
T3 = wl(A); u(A); wl(B); u(B); = wl(A); wl(B); u(B); u(A);
T4 = rl(B); u(B); wl(A); u(A); = rl(B); wl(A); u(A); u(B);
```

## 3.5
```
H1 = wl3(B); rl3(B); rl1(A); rl3(C); u3(B); rl1(B); u1(B); wl2(B); u3(C); rl2(C); u1(A); wl2(A); u2(B); u2(A); rl1(C); rl3(D); u3(D); u1(C); wl2(C); u2(C)
```
(a)
![[drawing2025-10-13 12.38AM]]
Orden topologico: T3 -> T1 -> T2

(b)
```
T1 = rl(A); rl(B); u(B); u(A); rl(C); u(C);
T2 = wl(B); rl(C); wl(A); u(B); u(A); wl(C); u(C);
T3 = wl(B); rl(B); rl(C); u(B); u(C); rl(D); u(D);

H = wl3(B); rl3(B); rl3(C); u3(B); u3(C); rl3(D); u3(D); wl2(B); rl2(C); wl2(A); u2(B); u2(A); rl1(A); rl1(B); u1(B); u1(A); wl2(C); u2(C); rl1(C); u1(C); 
```
![[drawing2025-10-13 12.55AM]]
Es legal, no serial y aciclico.

(c)
```
H1 = wl3(B); rl3(B); rl1(A); rl3(C); u3(B); rl1(B); u1(B); wl2(B) : u3(C); rl2(C); u1(A); wl2(A); u2(B); u2(A); rl1(C); rl3(D); u3(D); u1(C); wl2(C); u2(C)
```
Si, en `wl3(B); rl3(B); rl1(A); rl3(C); u3(B); rl1(B);` la transaccion 3 escribe B y la transaccion 1 se basa en ese valor para loq ue va a hacer. Si la transaccion 3 aborta, la transaccion 1 va a estar commiteando un valor contaminado.

## 3.6
```
H1 = rl3(X); rl2(X); wl3(Y); u3(X); wl2(X); u3(Y); rl4(Y); u2(X); rl1(Y); rl4(X); u1(Y); u4(X); wl1(X); u4(Y); u1(X); c3; c2; c4; c1
```
(a) No, porque tenemos `rl2(X) ... wl2(X)` sin el respectivo unlock en el medio (el unlock the T2).
```
T1 = rl1(Y); u1(Y); wl1(X); u1(X); c1;
T2 = rl2(X); wl2(X); u2(X); c2;
T3 = rl3(X); wl3(Y); u3(X); u3(Y); c3;
T4 = rl4(Y); rl4(X); u4(X); u4(Y); c4;
```
No. T1 no es 2PL.

(b) 
![[drawing2025-10-13 1.47AM]]
Orden topologico: T3 -> T2 -> T4 -> T1

(c) 
No es *ST* porque wl3(Y) < rl4(Y) < c3 implicando que se esta leyendo de un *borrador*.
No es *ACA* por la misma razon, estamos leyendo algo que no fue commiteado.
Es *RC*. Todos los reads se basan en writes que son commiteados antes que ellos.

(d)
```
c4; c1; c2; c3
```
No es *RC* porque wl3(Y) < rl4(Y) < c4 < c3 implicando que estamos basando una lectura en algo que aun no fue commiteado.

(e)
```
H1 = rl3(X); rl2(X); wl3(Y); u3(X); wl2(X); u3(Y); rl4(Y); u2(X); rl1(Y); rl4(X); u1(Y); u4(X); wl1(X); u4(Y); u1(X); c3; c2; c4; c1

H1' = rl3(X); rl2(X); wl3(Y); wl2(X); rl4(Y); rl1(Y); rl4(X); u1(Y); wl1(X); u3(X); c3; u3(Y); c2; u2(X); u4(X); u4(Y); c1; u1(X); c4;
```

## 3.7
```
T1 = rl1(B); u1(B); wl1(A); u1(A)
T2 = rl2(A); wl2(A); u2(A)
T3 = rl3(A); rl3(B); u3(A); u3(B)
```
No tengo ganas hoy.

## 3.8
```
T1 = rl1(A); r1(A); rl1(B); r1(B); wl1(B); w1(B); u1(A); u1(B)
T2 = rl2(A); r2(A); rl2(B); r2(B); u2(A); u2(B)
```
(a)
```
H = rl1(A); r1(A); rl1(B); r1(B); rl2(A); r2(A); rl2(B); r2(B); u2(A); u2(B); wl1(B); w1(B); u1(A); u1(B)
```
(b)
```
H = rl1(A); r1(A); rl1(B); r1(B); rl2(A); r2(A); rl2(B); r2(B); wl1(B); u2(A); u2(B); w1(B); u1(A); u1(B); 
```

## 3.9
```
T1 = rl1(A); r1(A); wl1(A); w1(A); u1(A)
T2 = rl2(A); r2(A); wl2(A); w2(A); u2(A)
```
(a)
```
H = rl1(A); rl2(A); r1(A); r2(A); wl1(A); wl2(A); w1(A); w2(A); u2(A); u1(A);
```
- T1 esta esperando que T2 libere su bloqueo de lectura (rl2) para poder obtener su bloqueo de escritura (wl1).
- T2 esta esperando que T1 libere su bloqueo de lectura (rl1) para poder obtener su bloqueo de escritura (wl2).

(b)
El update lock previene el escenario del deadlock, ya que evita que dos transacciones obtengan simultáneamente un bloqueo "con intención de escribir" sobre el mismo dato.
Las transacciones se modifican para solicitar un `update lock` en lugar del `read lock` inicial.
```
T1 = ul1(A); r1(A); wl1(A); w1(A); u1(A)
T2 = ul2(A); r2(A); wl2(A); w2(A); u2(A)

H = ul1(A); ul2(A); r1(A); wl1(A); w1(A); u1(A); r2(A); wl2(A); w2(A); u2(A);
```
## 3.11

```
T1 = l1(A); r1(A); l1(B); w1(B); u1(A); u1(B)
T2 = l2(C); r2(C); l2(A); w2(A); u2(C); u2(A)
T3 = l3(B); r3(B); l3(C); w3(C); u3(B); u3(C)
T4 = l4(D); r4(D); l4(A); w4(A); u4(D); u4(A)
```
(a)
```
T1` = rl1(A); r1(A); wl1(B); w1(B); u1(A); u1(B)
T2` = rl2(C); r2(C); wl2(A); w2(A); u2(C); u2(A)
T3` = rl3(B); r3(B); wl3(C); w3(C); u3(B); u3(C)
T4` = rl4(D); r4(D); wl4(A); w4(A); u4(D); u4(A)
```

(b)
```
H = rl1(A); rl2(C); rl3(B); rl4(D); r1(A); r2(C); r3(B); r4(D); wl1(B); wl2(A); wl3(C); wl4(A); w1(B); u1(A); u1(B); w2(A); u2(C); u2(A); w3(C); u3(B); u3(C); w4(A); u4(D); u4(A)
```

(c)
![[drawing2025-10-13 5.07AM]]
(d)
no se, tengo sueno

## 3.12


## 3.13
```
s = wl1(A); rl1(B); u1(B); wl3(C); wl2(B); rl3(D); u3(C); rl2(C); wl3(D); u2(B); u3(D); u1(A); u2(C); c3; c1; c2
```
(a) F. Porque  rl1(B) < u1(B) < wl3(C)
(b) F. Porque no se encuentra en el schedule ningun $ul_i(X)$.
(c) V. Se puede ver en rl3(D) < wl3(D); < c3. Se upgradea de lectura a escritura.
(d) Ni ganas de hacer el grafico. Deberiamos hacer el grafo de precedencia y buscar todos los ordenes topograficos.
(e) V. rl2(C) puede leer lo escrito por wl3(C) y c3 < c2. O sea, primero se commitea lo que se escribio y despues se commitea lo leido de lo commiteado. Es recuperable.
(f) F. Todos los commits estan despues de las operaciones de las transacciones. Nunca estamos basando nuestra informacion en cosas commiteadas.

# 4 - Metodos con timestamping y Multiversion

## 4.1
```
H1 = st1; st2; r1(A); r2(B); w2(A); w1(B)
H2 = st1; r1(A); st2; r2(B); r2(A); w1(B)
H3 = st1; st2; st3; r1(A); r2(B); w1(C); r3(B); r3(C); w2(B); w3(B)
```
(a)
(b)
## 4.2
```
H1 = st1; st2; r2(X); st3; st4; r1(Y ); r4(Z); w3(X); w3(Y ); w4(Z); w2(X); w1(Y ); r3(Z)

T1 escribe Y = 1
T2 escribe X = 2
T3 escribe X = 3; Y = 30
T4 escribe Z = 4
```
(a)
(b)
## 4.3
```
T1 = r1(A); r1(B); w1(X); w1(B)
T2 = r2(C); r2(B); r2(A); w2(A); w2(B)
T3 = r3(B); r3(X); w3(A); w3(B)
```
(a)
## 4.4
```
s1 = r1(A); r2(A); w1(A); r3(A); w3(A); w2(A)
s2 = r1(A); r3(C); r2(C); w3(A); r2(B); r3(B); w2(B); w2(A)
```
(a)
## 4.5
```
H1 = st2; r2(Z); r2(Y); w2(Y); st3; r3(Y); r3(Z); st1; r1(X); w1(X); w3(Y); w3(Z); r2(X); r1(Y); w1(Y); w1(X)
H2 = st3; r3(Y); r3(Z); st1; r1(X); w1(X); w3(Y); w3(Z); st2; r2(Z); r1(Y); w1(Y); r2(Y); w2(Y); r2(X); w2(X)
```
(a)
(b)
(c)
## 4.6
```
T1 = r1(A); r1(B); w1(A)
T2 = r2(B); r2(C); w2(A)
T3 = r3(C); r3(B); w3(B)
```
(a)
## 4.7
```
H = st1; st2; r2(X); st3; st4; r1(Y); r4(Z); w3(X); w3(Y); w4(Z); w2(X); w1(Y); r3(Z)

Suponer que t1 escribe Y = 10, t2 escribe X = 8, t3 escribe X = 2 e Y = 4, t4 escribe Z = 6
```

# 5 - Recuperabilidad
## 5.1
```
H = r1(Z); w1(U ); c1; w2(X); w2(Y ); r3(U ); w3(X); w2(Z); c2; r3(Y ); r4(Z); w3(Y ); c3; r4(U ); w4(U ); c4
```
(a)
(b)
(c)
## 5.2
```
< ST ART T1 >; < T1, A, 10 >; < ST ART T2 >; < T2, B, 20 >; < ST ART T12 >
< T1, C, 30 >; < T2, D, 40 >; < COM M IT T2 >; < T12, R, 12 >; < T1, E, 50 >;
< ABORT T 12 >< COM M IT T 1 >
```
(a)
(b)
(c)
(d)
## 5.3
```
< ST ART T1 >; < T1, A, 8 >; < ST ART T2 >; < ST ART T3 >< T2, B, 16 >;
< ST ART T4 >; < T4, E, 24 >; < T2, D, 32 >; < T 4, K, 9 >; < T4, F, 40 >;
< ABORT T 4 >; < COM M IT T3 >; < T2, G, 48 >; < COM M IT T2 >; < T1, C, 56 >;
< COM M IT T1 >
```
(a)
(b)
## 5.4
```
< ST ART T1 >; < T1, A, 100, 110 >; < ST ART T2 >; < T2, B, 200, 210 >;
< ST ART T 3 >; < T1, C, 300, 310 >; < T3, D, 400, 410 >; < T2, E, 40, 41 >;
< T3, F, 500, 510 >; < COM M IT T3 >; < COM M IT T2 >; < ST ART T4 >;
< T1, G, 600, 610 >; < T4, H, 700, 710 >; < COM M IT T1 >; < COM M IT T4 >
```
(a)
(b)
(c)
(d)
## 5.5
```
< ST ART T1 >; < T1, A, 60 >; < COM M IT T1 >; < ST ART T2 >; < T2, A, 10 >;
< ST ART T3 >; < T3, B, 20 >; < T2, C, 30 >; < ST ART T4 >; < T3, D, 40 >;
< T4, F, 70 >; < COM M IT T3 >; < T2, E, 50 >; COM M IT T2 >; < T4, B, 80 >;
< COM M IT T4 >

1) < T1, A, 60 >
2) < T2, A, 10 >
3) < T3, B, 20 >
4) < T3, D, 40 >
5) < T2, E, 50 >
```
(a)
(b)
## 5.6
```
```
## 5.7
```
```
## 5.8
```
```