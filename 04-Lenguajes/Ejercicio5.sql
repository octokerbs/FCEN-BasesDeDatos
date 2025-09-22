-- Creacion de tablas

CREATE TABLE ACTOR(
    idActor INTEGER NOT NULL,
    nombreActor char(15) NOT NULL,
    edad INTEGER,
    PRIMARY KEY( idActor )
) 

CREATE TABLE GENERO(
    idGenero INTEGER NOT NULL,
    nombreGenero char(15) NOT NULL,
    PRIMARY KEY( idGenero )
) 

CREATE TABLE SERIE(
    idSerie INTEGER NOT NULL,
    nombreSerie char(15) NOT NULL,
    idGenero INTEGER NOT NULL,
    añoInicio date,
    añoFin date,
    PRIMARY KEY( idSerie ),
    FOREIGN KEY( idGenero ) REFERENCES GENERO(idGenero)
) 

CREATE TABLE CANAL(
    idCanal INTEGER NOT NULL,
    nombreCanal char(15) NOT NULL,
    PRIMARY KEY( idCanal ),
) 

CREATE TABLE PARTICIPA_EN(
    idActor INTEGER NOT NULL,
    idSerie INTEGER NOT NULL,
    PRIMARY KEY( idActor, idSerie ),
    FOREIGN KEY( idActor ) REFERENCES ACTOR( idActor ),
    FOREIGN KEY( idSerie ) REFERENCES SERIE( idSerie )
) 

CREATE TABLE TRANSMITE(
    idCanal INTEGER NOT NULL,
    idSerie INTEGER NOT NULL,
    PRIMARY KEY( idCanal, idSerie ),
    FOREIGN KEY( idCanal ) REFERENCES CANAL( idCanal ),
    FOREIGN KEY( idSerie ) REFERENCES SERIE( idSerie )
) 

