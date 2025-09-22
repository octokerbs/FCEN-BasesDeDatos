-- a
SELECT DISTINCT a.Title
FROM Album a
JOIN Track t ON t.AlbumId = a.AlbumId
JOIN PlaylistTrack pt ON pt.TrackId = t.TrackId
GROUP BY a.AlbumId, a.Title, t.TrackId
HAVING COUNT(DISTINCT pt.PlaylistId) = (SELECT COUNT(*) FROM Playlist);

-- b
SELECT c.PlaylistId, c.ArtistId, c.AlbumCount
FROM (
    SELECT pt.PlaylistId, a.ArtistId, COUNT(DISTINCT al.AlbumId) AS AlbumCount
    FROM Artist a
    JOIN Album al ON al.ArtistId = a.ArtistId
    JOIN Track t ON t.AlbumId = al.AlbumId
    JOIN PlaylistTrack pt ON pt.TrackId = t.TrackId
    GROUP BY pt.PlaylistId, a.ArtistId
) c
JOIN (
    SELECT sub.PlaylistId, MIN(AlbumCount) AS MinAlbumCount
    FROM (
        SELECT pt.PlaylistId, a.ArtistId, COUNT(DISTINCT al.AlbumId) AS AlbumCount
        FROM Artist a
        JOIN Album al ON al.ArtistId = a.ArtistId
        JOIN Track t ON t.AlbumId = al.AlbumId
        JOIN PlaylistTrack pt ON pt.TrackId = t.TrackId
        GROUP BY pt.PlaylistId, a.ArtistId
    ) sub
    GROUP BY sub.PlaylistId
) m ON c.PlaylistId = m.PlaylistId AND c.AlbumCount = m.MinAlbumCount;

