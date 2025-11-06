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