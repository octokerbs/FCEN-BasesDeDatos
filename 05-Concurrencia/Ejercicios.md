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
