---------------------------------------------------------
--CREACION BASAE DE DATOS--

create database STARK_TREK
use STARK_TREK

---------------------------------------------------------
--CREACION TABLA IMPERIOS--

CREATE TABLE Imperios (
    CodigoGalacticoImperio INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    TemperaturaPromedio DECIMAL(5,2) NOT NULL
);


---------------------------------------------------------
--CREACION TABLA FLOTAS-- 

CREATE TABLE Flotas (
    CodigoGalacticoFlota INT PRIMARY KEY IDENTITY(1,1),
    Destino VARCHAR(50) NOT NULL,
    Misiones VARCHAR(100) NOT NULL,
    ImperioID INT,
    FOREIGN KEY (ImperioID) REFERENCES Imperios(CodigoGalacticoImperio)
);
-----------------------------------
--CREACION TABLA PLANETAS-- 
CREATE TABLE Planetas (
    NombreCientifico VARCHAR(50) PRIMARY KEY,
    PoblacionTotal INT NOT NULL,
    CoordenadasGalacticas VARCHAR(20) NOT NULL,
    NombreVulgar VARCHAR(50) NOT NULL,
    ImperioOcupanteID INT,
    FOREIGN KEY (ImperioOcupanteID) REFERENCES Imperios(CodigoGalacticoImperio)
);
--------------------------
--CREACION TABLA CAPITANES-- 
CREATE TABLE Capitanes (
    CapitanID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    ImperioTrabajaID INT,
    PlanetaNacimiento VARCHAR(50) NOT NULL,
    FOREIGN KEY (ImperioTrabajaID) REFERENCES Imperios(CodigoGalacticoImperio)
		,FOREIGN KEY (PlanetaNacimiento) references planetas(NombreCientifico)
);

---------------------------------------------------------
--CREACION TABLA NAVES-- 

CREATE TABLE Naves (
    NaveID INT PRIMARY KEY IDENTITY(1,1),
    CodigoNave VARCHAR(20) NOT NULL,
    VelocidadMaxima DECIMAL(5,2) NOT NULL,
    EnergiaAcumulada INT NOT NULL,
    CapitanID INT,
    FlotaID INT,
    FOREIGN KEY (CapitanID) REFERENCES Capitanes(CapitanId),
    FOREIGN KEY (FlotaID) REFERENCES Flotas(CodigoGalacticoFlota)
);



---------------------------
--CREACION TABLA MONTANIAS-- 
CREATE TABLE Montañas (
    PlanetaNombreCientifico VARCHAR(50),
    NombreMontaña VARCHAR(50),
    Altura INT NOT NULL,
    PRIMARY KEY (PlanetaNombreCientifico, NombreMontaña),
    FOREIGN KEY (PlanetaNombreCientifico) REFERENCES Planetas(NombreCientifico)
);

-----------------------------------
--CREACION TABLA RAZAS-- 

CREATE TABLE Razas (
    NombreCientifico VARCHAR(50) PRIMARY KEY,
    HabilidadesPrincipales VARCHAR(200) NOT NULL
);

------------------------------
--CREACION TABLA UNION DE RAZAS Y PLANETAS-- 
CREATE TABLE RazasPlanetas (
    RazaNombreCientifico VARCHAR(50),
    PlanetaNombreCientifico VARCHAR(50),
    PorcentajePoblacion DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (RazaNombreCientifico, PlanetaNombreCientifico),
    FOREIGN KEY (RazaNombreCientifico) REFERENCES Razas(NombreCientifico),
    FOREIGN KEY (PlanetaNombreCientifico) REFERENCES Planetas(NombreCientifico)
);

----------------------------------
--CREACION TABLA MANIOBRAS-- 

CREATE TABLE Maniobras (
    NombreManiobra VARCHAR(50) PRIMARY KEY,
    ConsumoEnergia INT NOT NULL
);

------------------------------------------
--CREACION TABLA UNION DE NAVES Y MANIOBRAS-- 
CREATE TABLE NavesManiobras (
    NaveID INT,
    ManiobraNombre VARCHAR(50),
    PRIMARY KEY (NaveID, ManiobraNombre),
    FOREIGN KEY (NaveID) REFERENCES Naves(NaveID),
    FOREIGN KEY (ManiobraNombre) REFERENCES Maniobras(NombreManiobra)
);


--------------------------------------------------------

--CREACION PROCESOS ALMACENADOS-- (CRUD)

--PROCESO CREACION--
CREATE PROCEDURE CrearImperio
@Nombre VARCHAR(255),
@TemperaturaPromedio FLOAT
AS
BEGIN
BEGIN TRY
INSERT INTO Imperios (Nombre, TemperaturaPromedio)
VALUES (@Nombre, @TemperaturaPromedio);
END TRY
BEGIN CATCH
END CATCH
END;


--PROCESO LEER--
CREATE PROCEDURE LeerImperio
@CodigoGalactico VARCHAR(50)
AS
BEGIN
SELECT *
FROM Imperios
WHERE CodigoGalacticoImperio = @CodigoGalactico;
END;

--PROCESO UPDATE--
CREATE PROCEDURE ActualizarImperio
@CodigoGalactico int,
@NuevoNombre VARCHAR(255),
@NuevaTemperaturaPromedio FLOAT
AS
BEGIN
BEGIN TRY
UPDATE Imperios
SET Nombre = @NuevoNombre, TemperaturaPromedio = @NuevaTemperaturaPromedio
WHERE CodigoGalacticoImperio = @CodigoGalactico;
END TRY
BEGIN CATCH
END CATCH
END;

--PROCESO DELETE--
CREATE PROCEDURE EliminarImperio
@CodigoGalactico VARCHAR(50)
AS
BEGIN
BEGIN TRY
DELETE FROM Imperios
WHERE CodigoGalacticoImperio = @CodigoGalactico;
END TRY
BEGIN CATCH
END CATCH
END;


----------------------------------------------
--ALTERACION DE LA TABLA FLOTAS Y CREACION Y VINCULACION DE LA TABLA MISIONES--

ALTER TABLE Flotas
DROP COLUMN Misiones;

CREATE TABLE Misiones (
    MisionID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL
);


ALTER TABLE Flotas
ADD MisionID INT,
FOREIGN KEY (MisionID) REFERENCES Misiones(MisionID);


--------------------------------------------------------------------------
--CREACION DE VISTA PARA VER LAS RAZAS QUE OCUPAN MAS DE 25% DE UN PLANETA Y QUE PANETA ES ESE--

create view OcupacionDeRaza
as
select Razas.NombreCientifico as 'RAZA', RazasPlanetas.PlanetaNombreCientifico as 'NOMBRE CIENTIFICO PLANETA', Planetas.NombreVulgar as 'NOMBRE VULGAR PLANETA'
from Razas
join RazasPlanetas on RazasPlanetas.RazaNombreCientifico = Razas.NombreCientifico
join Planetas on Planetas.NombreCientifico = RazasPlanetas.PlanetaNombreCientifico
where RazasPlanetas.PorcentajePoblacion > 25

select * from OcupacionDeRaza

----------------------------------------------------------------
--CREACION VISTA PARA VER LA LOS NOMBRES DE LOS CAPITANES LOS CUALES SUS PLANETAS DE NACIMIENTO TIENEN UNA POBLACION MAYOR  A 900000000, QUE PLANETA ES y CUANTA TIENEN EN TOTAL--

create view CapitanesPoblacionPlaneta
as
select Capitanes.Nombre as Capitan ,Planetas.NombreVulgar as Planeta, Planetas.PoblacionTotal
from Capitanes
join Planetas on Planetas.NombreCientifico = Capitanes.PlanetaNacimiento
where Planetas.PoblacionTotal > 900000000

select * from CapitanesPoblacionPlaneta


--/////INSERCION DE DATOS/////////--

--INSERCION DE DATOS--
INSERT INTO Imperios (Nombre, TemperaturaPromedio) VALUES
('Federacion Galactica', 25.5),
('Imperio Klingon', -10.2),
('Republica Romulana', 18.7),
('Imperio Cardasiano', 32.0),
('Union de Planetas Bajorianos', 28.3),
('Dominio Gamma', 20.1),
('Confederacion Andoriana', -5.6),
('Imperio Tholian', 15.9),
('Imperio Gorn', 22.8),
('Union de Planetas Sheliak', 27.4),
('Sindicato Orion', 30.2),
('Soberania Ferengi', 35.6),
('Pueblo Edoano', 23.0),
('Imperio Tzenkethi', -8.7),
('Coalicion de Planetas Minosiana', 29.5),
('Republica de Zakdorn', 17.3),
('Imperio Sheliak', 26.8),
('Federacion Sona', 31.9),
('Confederacion Yridiana', 14.5),
('Reino de Sheliax', 19.6);


INSERT INTO Flotas (Destino, Misiones, ImperioID) 
VALUES
('Oceano Indico', 'Escolta,Patrulla,Ataque', 1),
('Mar del Sur', 'Escolta,Patrulla', 2),
('Andromeda', 'Escolta,Ataque', 3),
('Oceano Pacifico', 'Patrulla', 4),
('Mar de Java', 'Escolta', 5),
('Oceano Atlantico', 'Ataque', 6),
('Oceano Artico', 'Escolta,Patrulla', 7),
('Mar Caribe', 'Escolta,Ataque', 8),
('Oceano Antartico', 'Patrulla', 9),
('Oceano Austral', 'Escolta,Patrulla,Ataque', 10),
('Mar Mediterraneo', 'Escolta', 11),
('Mar Negro', 'Patrulla,Ataque', 12),
('Mar Caspio', 'Escolta,Patrulla', 13),
('Oceano Rojo', 'Escolta', 14),
('Mar Aral', 'Patrulla,Ataque', 15),
('Mar de Barents', 'Escolta,Patrulla', 16),
('Oceano Celestial', 'Escolta,Ataque', 17),
('Mar de Cortes', 'Patrulla', 18),
('Mar de Japon', 'Escolta,Patrulla,Ataque', 19),
('Mar de China Meridional', 'Escolta', 20);


INSERT INTO Naves (CodigoNave, VelocidadMaxima, EnergiaAcumulada, CapitanID, FlotaID) VALUES
('NU001', 500, 100, 1, 1),
('KF002', 450, 80, 2, 2),
('RM003', 600, 120, 3, 3),
('IQ004', 520, 90, 4, 4),
('UE005', 480, 110, 5, 5),
('DP006', 550, 95, 6, 6),
('CA007', 510, 85, 7, 7),
('IN008', 590, 105, 8, 8),
('IG009', 540, 100, 9, 9),
('ET010', 500, 80, 10, 10),
('AR011', 600, 120, 11, 11),
('LM012', 480, 90, 12, 12),
('BX013', 530, 110, 13, 13),
('PS014', 570, 95, 14, 14),
('IT015', 520, 85, 15, 15),
('GY016', 560, 105, 16, 16),
('ZR017', 590, 100, 17, 17),
('FD018', 510, 80, 18, 18),
('CU019', 580, 120, 19, 19),
('TR020', 540, 95, 20, 20);


INSERT INTO Capitanes (Nombre, ImperioTrabajaID, PlanetaNacimiento) VALUES
('Juan Perez', 1, 'FM1073'),
('Maria Rodriguez', 2, 'AB2054'),
('Carlos Lopez', 3, 'XY3098'),
('Laura Martinez', 4, 'KL4123'),
('Pedro Gomez', 5, 'OP5264'),
('Ana Herrera', 6, 'DE6375'),
('Diego Fernandez', 7, 'GH7486'),
('Valeria Sanchez', 8, 'IJ8597'),
('Ignacio Torres', 9, 'LM9618'),
('Eva Diaz', 10, 'NO0729'),
('Alejandro Ramirez', 11, 'PQ1830'),
('Carmen Castro', 12, 'RS2941'),
('Sergio Medina', 13, 'TU4052'),
('Isabel Nuñez', 14, 'VW5163'),
('Gabriel Suarez', 15, 'XYZ274'),
('Romina Vera', 16, 'ABC385'),
('Facundo Molina', 17, 'DEF496'),
('Celeste Fernandez', 18, 'GHI607'),
('Tomas Herrera', 19, 'JKL718'),
('Carolina Alvarez', 20, 'MNO829');


INSERT INTO Planetas (NombreCientifico, PoblacionTotal, CoordenadasGalacticas, NombreVulgar, ImperioOcupanteID) VALUES
('FM1073', 1000000000, '12.345,67.890', 'Tierra', 1),
('AB2054', 800000000, '23.456,78.901', 'Marte',2),
('XY3098', 1200000000, '34.567,89.012', 'Venus', 3),
('KL4123', 600000000, '45.678,90.123', 'Jupiter', 4),
('OP5264', 900000000, '56.789,01.234', 'Saturno',5),
('DE6375', 700000000, '67.890,12.345', 'Urano', 6),
('GH7486', 500000000, '78.901,23.456', 'Neptuno',  7),
('IJ8597', 1100000000, '89.012,34.567', 'Plutón',  8),
('LM9618', 950000000, '90.123,45.678', 'Mercurio',  9),
('NO0729', 780000000, '01.234,56.789', 'Europa',  10),
('PQ1830', 620000000, '12.345,67.890', 'Ganimedes', 11),
('RS2941', 840000000, '23.456,78.901', 'Calisto', 12),
('TU4052', 710000000, '34.567,89.012', 'Io',  13),
('VW5163', 890000000, '45.678,90.123', 'Titán',  14),
('XYZ274', 720000000, '56.789,01.234', 'Encélado', 15),
('ABC385', 980000000, '67.890,12.345', 'Oberon',  16),
('DEF496', 830000000, '78.901,23.456', 'Ariel',  17),
('GHI607', 670000000, '89.012,34.567', 'Tritón', 18),
('JKL718', 1200000000, '90.123,45.678', 'Titán',  19),
('MNO829', 880000000, '01.234,56.789', 'Europa',  20);


INSERT INTO Maniobras (NombreManiobra, ConsumoEnergia) VALUES
('Evasion de Fotorayos', 10),
('Despliegue de Campo de Defensa', 15),
('Cambio de Rumbo Veloz', 8),
('Ataque de Torpedo Cuantico', 12),
('Inyeccion de Antimateria', 20),
('Maniobra de Esquiva Dimensional', 25),
('Emboscada Gravitatoria', 18),
('Salto Hiperespacial', 30),
('Camuflaje de Neutrinos', 22),
('Inversion de Polaridad', 14),
('Reconfiguracion de Escudos', 16),
('Tormenta de Iones', 28),
('Impulso Warp', 24),
('Aturdimiento Sonico', 32),
('Abduccion Cuantica', 26),
('Manto de Invisibilidad', 19),
('Bombardeo de Nanobots', 23),
('Anomalia Temporal', 27),
('Rafaga de Plasma', 29),
('Despliegue de Minas Espaciales', 21);


INSERT INTO NavesManiobras (ManiobraNombre, NaveID) VALUES
('Evasion de Fotorayos', 1),
('Despliegue de Campo de Defensa', 3),
('Cambio de Rumbo Veloz', 2),
('Ataque de Torpedo Cuantico', 6),
('Inyeccion de Antimateria', 8),
('Maniobra de Esquiva Dimensional', 5),
('Emboscada Gravitatoria', 9),
('Emboscada Gravitatoria', 10),
('Camuflaje de Neutrinos', 4),
('Inversion de Polaridad', 7),
('Reconfiguracion de Escudos', 13),
('Tormenta de Iones', 11),
('Impulso Warp', 12),
('Aturdimiento Sonico', 16),
('Abduccion Cuantica', 18),
('Manto de Invisibilidad', 17),
('Bombardeo de Nanobots', 15),
('Anomalia Temporal', 14),
('Rafaga de Plasma', 20),
('Rafaga de Plasma', 19);


INSERT INTO Montañas (PlanetaNombreCientifico, NombreMontaña, Altura)
VALUES
('AB2054', 'Aconcagua', 4000),
('ABC385', 'K2', 3500),
('DE6375', 'Everest', 4200),
('DEF496', 'Kangchenjunga', 3000),
('FM1073', 'Makalu', 3800),
('GH7486', 'Lhotse', 4100),
('GHI607', 'Matterhorn', 3200),
('IJ8597', 'Monte Rosa', 3900),
('JKL718', 'Eiger', 4300),
('KL4123', 'Monte McKinley', 3600),
('LM9618', 'Monte Logan', 3700),
('MNO829', 'Monte Saint Elias', 4000),
('NO0729', 'Monte Elbrús', 3400),
('OP5264', 'Monte Kazbek', 4200),
('XY3098', 'Monte Ararat', 3800),
('XYZ274', 'Monte Atruks', 3500),
('PQ1830', 'Gasherbrum I', 4100),
('RS2941', 'Gasherbrum II', 4300),
('TU4052', 'Mont Blanc', 3700),
('VW5163', 'Cervino', 3900);


INSERT INTO Razas (NombreCientifico, HabilidadesPrincipales)
VALUES
('Vulcanos', 'Telepatía, Resistencia a altas temperaturas, Lógica avanzada'),
('Klingons', 'Combate cuerpo a cuerpo, Honor en la batalla, Lealtad al imperio'),
('Bajorianos', 'Espiritualidad, Resistencia a la ocupación, Artesanía'),
('Borg', 'Asimilación, Adaptabilidad, Conexión colectiva'),
('Cardassianos', 'Intriga política, Estrategia militar, Lealtad al Estado'),
('Ferengi', 'Comercio, Negociación, Acumulación de riqueza'),
('Andorianos', 'Agilidad, Visión térmica, Fuerza física'),
('Betazoides', 'Empatía, Lectura mental, Relaciones interpersonales'),
('Trill', 'Simbiosis, Conocimientos acumulados, Vinculación con simbionte'),
('Breen', 'Tecnología avanzada, Criogenización, Misteriosa cultura'),
('Dominion', 'Control mental, Ingeniería genética'),
('Romulanos', 'Astucia, Camuflaje, Unificación romulana'),
('Gorn', 'Fuerza física sobresaliente, Resistencia, Adaptación a climas extremos'),
('Tholianos', 'Tejido de red, Cristales energéticos, Singularidad espacial'),
('Xindi', 'Diversidad de especies, Bioingeniería, Armas biológicas'),
('Q Continuum', 'Omnipotencia, Manipulación del tiempo y espacio, Pruebas cósmicas'),
('Nausicaanos', 'Piratería espacial, Habilidades en combate, Venganza'),
('Caitianos', 'Agilidad felina, Sentidos agudos, Destrezas acrobáticas'),
('Changelings', 'Mimetismo, Cambio de forma, Unidad en el Gran Enlace'),
('Tellaritas', 'Diplomacia, Ingeniería, Voluntad férrea');


INSERT INTO RazasPlanetas (RazaNombreCientifico, PlanetaNombreCientifico, PorcentajePoblacion)
VALUES
('Vulcanos', 'XYZ274', 15),
('Vulcanos', 'XY3098', 10),
('Vulcanos', 'VW5163', 5),
('Vulcanos', 'TU4052', 8),
('Andorianos', 'TU4052', 20),
('Andorianos', 'RS2941', 12),
('Andorianos', 'PQ1830', 15),
('Betazoides', 'OP5264', 25),
('Betazoides', 'NO0729', 22),
('Cardassianos', 'MNO829', 18),
('Cardassianos', 'LM9618', 20),
('Ferengi', 'KL4123', 30),
('Ferengi', 'JKL718', 15),
('Breen', 'IJ8597', 8),
('Breen', 'GHI607', 12),
('Bajorianos', 'GH7486', 28),
('Bajorianos', 'FM1073', 22),
('Trill', 'DEF496', 18),
('Trill', 'DE6375', 10),
('Changelings', 'ABC385', 5),
('Changelings', 'AB2054', 8);


INSERT INTO RazasPlanetas (RazaNombreCientifico, PlanetaNombreCientifico, PorcentajePoblacion)
VALUES
('Klingons', 'DEF496', 30),
('Klingons', 'ABC385', 25),
('Klingons', 'AB2054', 15),
('Romulanos', 'XYZ274', 18),
('Romulanos', 'PQ1830', 25),
('Romulanos', 'NO0729', 10),
('Dominion', 'TU4052', 45),
('Dominion', 'RS2941', 30),
('Nausicaanos', 'OP5264', 28),
('Nausicaanos', 'LM9618', 5),
('Caitianos', 'KL4123', 8),
('Caitianos', 'JKL718', 12),
('Q Continuum', 'IJ8597', 2),
('Q Continuum', 'GHI607', 3),
('Q Continuum', 'GH7486', 1),
('Tholianos', 'FM1073', 15),
('Tholianos', 'DEF496', 5),
('Xindi', 'DE6375', 8),
('Xindi', 'ABC385', 3),
('Gorn', 'AB2054', 2);