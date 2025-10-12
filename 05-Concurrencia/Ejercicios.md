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
![[drawing2025-10-12 6.34PM]]

