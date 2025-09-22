-- Query para testear cosas de null 
INSERT INTO Customer (
    CustomerId, FirstName, LastName, Email, SupportRepId, Country
)
VALUES (
    60, 'Octo', 'Kerbs', 'kerbsod@gmail.com', 3, 'Argentina'
);

-- a
SELECT FirstName, LastName
FROM dbo.Customer
WHERE Country = 'Brazil'

-- b
SELECT c.CustomerId, c.FirstName + ' ' + c.LastName, i.InvoiceId, i.InvoiceDate
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId

-- c
SELECT t.TrackId, ar.Name 
FROM Track t
JOIN Album a ON t.AlbumId = a.AlbumId 
JOIN Artist ar ON a.ArtistId = ar.ArtistId 

-- d
SELECT pl.Name
FROM Playlist pl 
JOIN PlaylistTrack pt ON pt.PlaylistId = pl.PlaylistId
JOIN Track t ON pt.TrackId = t.TrackId 
JOIN MediaType m ON m.MediaTypeId = t.MediaTypeId 
WHERE m.Name = 'MPEG audio file'
GROUP BY pl.Name
HAVING COUNT(*) > 1

-- e
SELECT pl.Name
FROM Playlist pl 
JOIN PlaylistTrack pt ON pt.PlaylistId = pl.PlaylistId
JOIN Track t ON pt.TrackId = t.TrackId
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE ar.Name = 'Iron Maiden'
GROUP BY pl.Name
HAVING COUNT(*) > 10

-- f
SELECT pl.Name, COUNT(DISTINCT a.AlbumId)
FROM Playlist pl
JOIN PlaylistTrack pt ON pt.PlaylistId = pl.PlaylistId
JOIN Track t ON pt.TrackId = t.TrackId
JOIN Album a ON t.AlbumId = a.AlbumId
GROUP BY pl.Name

-- g
SELECT DISTINCT e.FirstName + ' ' + e.LastName AS Name
FROM Employee e 
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice i ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
WHERE DATEDIFF(YY, e.BirthDate, GETDATE()) > 25
GROUP BY e.FirstName, e.LastName, il.InvoiceId
HAVING COUNT(il.InvoiceLineId) > 10

-- h
SELECT c.CustomerId, c.FirstName + ' ' + c.LastName, i.InvoiceId, i.InvoiceDate
FROM Customer c
LEFT JOIN Invoice i ON i.CustomerId = c.CustomerId

-- i 
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS Name
FROM Employee e 
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName 
HAVING COUNT(i.InvoiceId) > 10

-- j
SELECT 
  e1.FirstName AS EmployeeFirst,
  e1.LastName  AS EmployeeLast,
  e2.FirstName AS ManagerFirst,
  e2.LastName  AS ManagerLast
FROM Employee e1
JOIN Employee e2 ON e1.ReportsTo = e2.EmployeeId

-- k
SELECT 
  e1.FirstName AS EmployeeFirst,
  e1.LastName  AS EmployeeLast,
  e2.FirstName AS ManagerFirst,
  e2.LastName  AS ManagerLast
FROM Employee e1
LEFT JOIN Employee e2 ON e1.ReportsTo = e2.EmployeeId

-- l
SELECT c.CustomerId, AVG(tracks_per_invoice) 
FROM Customer c 
JOIN Invoice i ON i.CustomerId = c.CustomerId
JOIN (
    SELECT il.InvoiceId, SUM(il.Quantity) AS tracks_per_invoice 
    FROM InvoiceLine il
    GROUP BY il.InvoiceId
) ii ON ii.InvoiceId = i.InvoiceId
GROUP BY c.CustomerId

-- m
SELECT e.EmployeeId, COUNT(*) AS sold_rock_tracks
FROM Employee e 
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice i ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
JOIN Track t ON t.TrackId = il.TrackId
JOIN Genre g ON g.GenreId = t.GenreId
WHERE g.Name = 'Rock'
GROUP BY e.EmployeeId