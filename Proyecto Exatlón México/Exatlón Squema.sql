CREATE DATABASE IF NOT EXISTS exatlon;
USE exatlon;

-- =========================
-- Tabla: atletas
-- =========================
CREATE TABLE IF NOT EXISTS atletas (
  idAtleta         INT AUTO_INCREMENT PRIMARY KEY,
  nombre           VARCHAR(100)        NOT NULL,
  apellido         VARCHAR(100)        NOT NULL,
  nombreEquipo     ENUM('Rojo','Azul') NOT NULL,
  sexo             ENUM('M','F')       NOT NULL,
  apodo            VARCHAR(100),
  edad             TINYINT,
  alturaMetros     DECIMAL(3,2),
  deporte          VARCHAR(100),
  estado           VARCHAR(100),
  ciudad           VARCHAR(100),
  numeroTemporadas TINYINT
);

-- =========================
-- Tabla: circuitos
-- =========================
CREATE TABLE IF NOT EXISTS circuitos (
  idCircuito     INT AUTO_INCREMENT PRIMARY KEY,
  nombreNarrado  VARCHAR(150),
  nombreCircuito VARCHAR(150)
);

-- =========================
-- Tabla: juegos
-- =========================
CREATE TABLE IF NOT EXISTS juegos (
  idJuego    INT AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(120),
  fecha      DATE,
  idCircuito INT NOT NULL,
  programa   INT,
  FOREIGN KEY (idCircuito) REFERENCES circuitos(idCircuito)
);

-- =========================
-- Tabla: enfrentamientos
-- =========================
CREATE TABLE IF NOT EXISTS enfrentamientos (
  idJuego         INT NOT NULL,
  numero          INT NOT NULL,
  tiradorGanador  INT NOT NULL,
  tiradorPerdedor INT NOT NULL,
  PRIMARY KEY (idJuego, numero),
  FOREIGN KEY (idJuego)         REFERENCES juegos(idJuego),
  FOREIGN KEY (tiradorGanador)  REFERENCES atletas(idAtleta),
  FOREIGN KEY (tiradorPerdedor) REFERENCES atletas(idAtleta)
);
