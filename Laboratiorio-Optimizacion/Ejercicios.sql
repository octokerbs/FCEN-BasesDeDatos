-- Consulta 1
WITH GastosTotalesPorCliente(CustomerId, TotalGastado) AS (
    SELECT c.CustomerId, SUM(i.total)
    FROM dbo.Customer c
    JOIN dbo.Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
)
SELECT c.FirstName, c.LastName, gtpc.TotalGastado
FROM dbo.Customer c 
JOIN GastosTotalesPorCliente gtpc ON gtpc.CustomerId = c.CustomerId
WHERE gtpc.TotalGastado > (
    SELECT AVG(gtpc.TotalGastado)
    FROM GastosTotalesPorCliente gtpc
)
ORDER BY gtpc.TotalGastado DESC
GO

-- Consulta 2
WITH GenresPerCustomer(CustomerId, CantidadGeneros) AS (
    SELECT c.CustomerId, COUNT(DISTINCT t.GenreId)
    FROM dbo.Customer c 
    JOIN dbo.Invoice i ON i.CustomerId = c.CustomerId
    JOIN dbo.InvoiceLine il ON il.InvoiceId = i.InvoiceId
    JOIN dbo.Track t ON t.TrackId = il.TrackId
    GROUP BY c.CustomerId
)
SELECT c.FirstName, c.LastName, CantidadGeneros
FROM dbo.Customer c 
JOIN GenresPerCustomer gpc ON gpc.CustomerId = c.CustomerId
WHERE gpc.CantidadGeneros > 1
ORDER BY CantidadGeneros DESC

-- Consulta 3
SELECT DISTINCT a.Title 
FROM dbo.Track t 
JOIN dbo.Album a ON a.AlbumId = t.AlbumId
WHERE a.Title NOT IN (
    SELECT aa.Title 
    FROM dbo.Track tt
    JOIN dbo.Album aa ON aa.AlbumId = tt.AlbumId
    WHERE tt.Milliseconds <= (
        SELECT AVG(ttt.Milliseconds)
        FROM dbo.Track ttt
    )
)
ORDER BY a.Title ASC


-- Consulta 4
SELECT ar.Name, COUNT(*) AS CantidadAlbumes
FROM dbo.Artist ar 
JOIN dbo.Album al ON al.ArtistId = ar.ArtistId
GROUP BY ar.Name
HAVING COUNT(*) > 10
ORDER BY CantidadAlbumes DESC

-- Consulta 5
-- Mediante SQL obtener los ´albumes que tiene al menos un track en TODAS las PlayLists

SELECT a.Title 
FROM dbo.Album a 
JOIN dbo.Track t ON t.AlbumId = a.AlbumId
WHERE t.TrackId IN (
    SELECT pt.TrackId
    FROM dbo.PlaylistTrack pt
    GROUP BY pt.TrackId
    HAVING COUNT(DISTINCT pt.PlaylistId) = (SELECT COUNT(PlaylistId) FROM dbo.PlaylistTrack)
)

SELECT a.Title, AVG(t.Milliseconds)
FROM dbo.Album a
JOIN dbo.Track t ON t.AlbumId = a.AlbumId
GROUP BY a.Title 