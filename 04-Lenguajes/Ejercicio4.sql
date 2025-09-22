-- a
SELECT p.PlaylistId, p.Name
FROM Playlist p
WHERE NOT EXISTS (
    SELECT 1
    FROM PlaylistTrack pt
    JOIN Track t ON t.TrackId = pt.TrackId
    JOIN Album a ON a.AlbumId = t.AlbumId
    JOIN Artist ar ON ar.ArtistId = a.ArtistId
    WHERE pt.PlaylistId = p.PlaylistId AND ar.Name IN ('Black Sabbath', 'Chico Buarque')
)

-- b
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
JOIN Track t ON t.TrackId = il.TrackId
JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING COUNT(DISTINCT g.GenreId) = 1