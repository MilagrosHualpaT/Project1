USE [master]
GO

IF EXISTS
(
	SELECT name
	FROM sysdatabases
	WHERE name='EurekaBank'
)
DROP DATABASE [EurekaBank]
GO

CREATE DATABASE [EurekaBank]
 ON  PRIMARY 
(
	NAME = N'EurekaBank_dat',
	FILENAME = N'C:\db\EurekaBank_dat.mdf',
	SIZE = 30MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 10MB
)
LOG ON 
(
	NAME = N'EurekaBank_log',
	FILENAME = N'C:\db\EurekaBank_log.ldf',
	SIZE = 10MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10%
)
GO


-- =============================================
-- Seleccionar la Base de Datos
-- =============================================

USE EUREKABANK;
go


CREATE TABLE TipoMovimiento (
	chr_tipocodigo       CHAR(3) NOT NULL,
	vch_tipodescripcion  VARCHAR(40) NOT NULL,
	vch_tipoaccion       VARCHAR(10) NOT NULL,
	vch_tipoestado       VARCHAR(15) DEFAULT 'ACTIVO' NOT NULL,
	CONSTRAINT PK_TipoMovimiento PRIMARY KEY (chr_tipocodigo),
	CONSTRAINT chk_tipomovimiento_vch_tipoaccion
		CHECK (vch_tipoaccion IN ('INGRESO', 'SALIDA')),
	CONSTRAINT chk_tipomovimiento_vch_tipoestado
		CHECK (vch_tipoestado IN ('ACTIVO', 'ANULADO', 'CANCELADO'))						
);
go

CREATE TABLE Sucursal (
	chr_sucucodigo       CHAR(3) NOT NULL,
	vch_sucunombre       VARCHAR(50) NOT NULL,
	vch_sucuciudad       VARCHAR(30) NOT NULL,
	vch_sucudireccion    VARCHAR(50) NULL,
		int_sucucontcuenta   INTEGER NOT NULL,
	CONSTRAINT PK_Sucursal PRIMARY KEY (chr_sucucodigo)
);
go

CREATE TABLE Empleado (
	chr_emplcodigo       CHAR(4) NOT NULL,
	vch_emplpaterno      VARCHAR(25) NOT NULL,
	vch_emplmaterno      VARCHAR(25) NOT NULL,
	vch_emplnombre       VARCHAR(30) NOT NULL,
	vch_emplciudad       VARCHAR(30) NOT NULL,
	vch_empldireccion    VARCHAR(50) NULL,
	vch_emplusuario      VARCHAR(15) NOT NULL,
	vch_emplclave        VARCHAR(15) NOT NULL,
	CONSTRAINT PK_Empleado PRIMARY KEY (chr_emplcodigo),
	CONSTRAINT U_Empleado_vch_emplusuario UNIQUE (vch_emplusuario)
);
go

CREATE TABLE Asignado (
	chr_asigcodigo       CHAR(6) NOT NULL,
	chr_sucucodigo       CHAR(3) NOT NULL,
	chr_emplcodigo       CHAR(4) NOT NULL,
	dtt_asigfechaalta    DATETIME NOT NULL,
	dtt_asigfechabaja    DATETIME NULL,
	CONSTRAINT PK_Asignado PRIMARY KEY (chr_asigcodigo), 
	CONSTRAINT fk_asignado_empleado FOREIGN KEY (chr_emplcodigo) REFERENCES Empleado (chr_emplcodigo), 
	CONSTRAINT fk_asignado_sucursal FOREIGN KEY (chr_sucucodigo) REFERENCES Sucursal (chr_sucucodigo)
);
go

CREATE TABLE Cliente (
	chr_cliecodigo       CHAR(5) NOT NULL,
	vch_cliepaterno      VARCHAR(25) NOT NULL,
	vch_cliematerno      VARCHAR(25) NOT NULL,
	vch_clienombre       VARCHAR(30) NOT NULL,
	chr_cliedni          CHAR(8) NOT NULL,
	vch_clieciudad       VARCHAR(30) NOT NULL,
	vch_cliedireccion    VARCHAR(50) NOT NULL,
	vch_clietelefono     VARCHAR(20) NULL,
	vch_clieemail        VARCHAR(50) NULL,
	CONSTRAINT PK_Cliente PRIMARY KEY (chr_cliecodigo)
);
go

CREATE TABLE Moneda (
	chr_monecodigo       CHAR(2) NOT NULL,
	vch_monedescripcion  VARCHAR(20) NOT NULL,
	CONSTRAINT PK_Moneda PRIMARY KEY (chr_monecodigo)
);
go

CREATE TABLE Cuenta (
	chr_cuencodigo       CHAR(8) NOT NULL,
	chr_monecodigo       CHAR(2) NOT NULL,
	chr_sucucodigo       CHAR(3) NOT NULL,
	chr_emplcreacuenta   CHAR(4) NOT NULL,
	chr_cliecodigo       CHAR(5) NOT NULL,
	dec_cuensaldo        MONEY NOT NULL,
	dtt_cuenfechacreacion DATETIME NOT NULL,
	vch_cuenestado       VARCHAR(15) DEFAULT 'ACTIVO' NOT NULL,
	int_cuencontmov      INTEGER NOT NULL,
	chr_cuenclave        CHAR(6) NOT NULL,
	CONSTRAINT chk_cuenta_chr_cuenestado
		CHECK (vch_cuenestado IN ('ACTIVO', 'ANULADO', 'CANCELADO')),
	CONSTRAINT PK_Cuenta PRIMARY KEY (chr_cuencodigo), 
	CONSTRAINT fk_cuenta_cliente FOREIGN KEY (chr_cliecodigo) REFERENCES Cliente (chr_cliecodigo), 
	CONSTRAINT fk_cuente_empleado FOREIGN KEY (chr_emplcreacuenta) REFERENCES Empleado (chr_emplcodigo), 
	CONSTRAINT fk_cuenta_sucursal FOREIGN KEY (chr_sucucodigo) REFERENCES Sucursal (chr_sucucodigo), 
	CONSTRAINT fk_cuenta_moneda FOREIGN KEY (chr_monecodigo) REFERENCES Moneda (chr_monecodigo)
);
go

CREATE TABLE Movimiento (
	chr_cuencodigo       CHAR(8) NOT NULL,
	int_movinumero       INTEGER NOT NULL,
	dtt_movifecha        DATETIME NOT NULL,
	chr_emplcodigo       CHAR(4) NOT NULL,
	chr_tipocodigo       CHAR(3) NOT NULL,
	dec_moviimporte      MONEY NOT NULL,
	chr_cuenreferencia   CHAR(8) NULL,
	CONSTRAINT chk_Movimiento_importe CHECK (dec_moviimporte >= 0.0),		 
	CONSTRAINT PK_Movimiento PRIMARY KEY (chr_cuencodigo, int_movinumero), 
	CONSTRAINT fk_movimiento_tipomovimiento FOREIGN KEY (chr_tipocodigo) REFERENCES TipoMovimiento (chr_tipocodigo),
	CONSTRAINT fk_movimiento_empleado FOREIGN KEY (chr_emplcodigo) REFERENCES Empleado (chr_emplcodigo), 
	CONSTRAINT fk_movimiento_cuenta FOREIGN KEY (chr_cuencodigo) REFERENCES Cuenta (chr_cuencodigo)
);
go

CREATE TABLE Parametro (
	chr_paracodigo       CHAR(3) NOT NULL,
	vch_paradescripcion  VARCHAR(50) NOT NULL,
	vch_paravalor        VARCHAR(70) NOT NULL,
	vch_paraestado       VARCHAR(15) DEFAULT 'ACTIVO' NOT NULL,
	CONSTRAINT chk_parametro_vch_paraestado
		CHECK (vch_paraestado IN ('ACTIVO', 'ANULADO', 'CANCELADO')),
	CONSTRAINT PK_Parametro PRIMARY KEY (chr_paracodigo)
);
go

CREATE TABLE InteresMensual (
	chr_monecodigo       CHAR(2) NOT NULL,
	dec_inteimporte      DECIMAL(12,2) NOT NULL,
	CONSTRAINT PK_InteresMensual PRIMARY KEY (chr_monecodigo), 
	CONSTRAINT fk_interesmensual_moneda FOREIGN KEY (chr_monecodigo) REFERENCES Moneda (chr_monecodigo)
);
go

CREATE TABLE CostoMovimiento (
	chr_monecodigo       CHAR(2) NOT NULL,
	dec_costimporte      MONEY NOT NULL,
	CONSTRAINT PK_CostoMovimiento PRIMARY KEY (chr_monecodigo), 
	CONSTRAINT fk_costomovimiento_moneda FOREIGN KEY (chr_monecodigo) REFERENCES Moneda (chr_monecodigo)
);
go

CREATE TABLE CargoMantenimiento (
	chr_monecodigo       CHAR(2) NOT NULL,
	dec_cargMontoMaximo  MONEY NOT NULL,
	dec_cargImporte      MONEY NOT NULL,
	CONSTRAINT PK_CargoMantenimiento PRIMARY KEY (chr_monecodigo), 
	CONSTRAINT fk_cargomantenimiento_moneda FOREIGN KEY (chr_monecodigo) REFERENCES Moneda (chr_monecodigo)
);
go

CREATE TABLE Contador (
	vch_conttabla        VARCHAR(30) NOT NULL,
	int_contitem         INTEGER NOT NULL,
	int_contlongitud     INTEGER NOT NULL,
	CONSTRAINT PK_Contador PRIMARY KEY (vch_conttabla)
);
go


-- Cargar Datos


-- Tabla: Moneda

insert into moneda values ( '01', 'Soles' );
insert into moneda values ( '02', 'Dolares' );

-- Tabla: CargoMantenimiento

insert into cargomantenimiento values ( '01', 3500.00, 7.00 );
insert into cargomantenimiento values ( '02', 1200.00, 2.50 );

-- Tabla: CostoMovimiento

insert into CostoMovimiento values ( '01', 2.00 );
insert into CostoMovimiento values ( '02', 0.60 );

-- Tabla: InteresMensual

insert into InteresMensual values ( '01', 0.70 );
insert into InteresMensual values ( '02', 0.60 );

-- Tabla: TipoMovimiento

insert into TipoMovimiento values( '001', 'Apertura de Cuenta', 'INGRESO', 'ACTIVO' );
insert into TipoMovimiento values( '002', 'Cancelar Cuenta', 'SALIDA', 'ACTIVO' );
insert into TipoMovimiento values( '003', 'Deposito', 'INGRESO', 'ACTIVO' );
insert into TipoMovimiento values( '004', 'Retiro', 'SALIDA', 'ACTIVO' );
insert into TipoMovimiento values( '005', 'Interes', 'INGRESO', 'ACTIVO' );
insert into TipoMovimiento values( '006', 'Mantenimiento', 'SALIDA', 'ACTIVO' );
insert into TipoMovimiento values( '007', 'ITF', 'SALIDA', 'ACTIVO' );
insert into TipoMovimiento values( '008', 'Transferencia', 'INGRESO', 'ACTIVO' );
insert into TipoMovimiento values( '009', 'Transferencia', 'SALIDA', 'ACTIVO' );
insert into TipoMovimiento values( '010', 'Cargo por Movimiento', 'SALIDA', 'ACTIVO' );

-- Tabla: Sucursal

insert into sucursal values( '001', 'Sipan', 'Chiclayo', 'Av. Balta 1456', 2 );
insert into sucursal values( '002', 'Chan Chan', 'Trujillo', 'Jr. Independencia 456', 3 );
insert into sucursal values( '003', 'Los Olivos', 'Lima', 'Av. Central 1234', 0 );
insert into sucursal values( '004', 'Pardo', 'Lima', 'Av. Pardo 345 - Miraflores', 0 );
insert into sucursal values( '005', 'Misti', 'Arequipa', 'Bolivar 546', 0 );
insert into sucursal values( '006', 'Machupicchu', 'Cusco', 'Calle El Sol 534', 0 );
insert into sucursal values( '007', 'Grau', 'Piura', 'Av. Grau 1528', 0 );


-- Tabla: Empleado

INSERT INTO empleado VALUES( '9999', 'Internet', 'Internet', 'internet', 'Internet', 'internet', 'internet', 'internet' );
INSERT INTO empleado VALUES( '0001', 'Romero', 'Castillo', 'Carlos Alberto', 'Trujillo', 'Call1 1 Nro. 456', 'cromero', 'chicho' );
INSERT INTO empleado VALUES( '0002', 'Castro', 'Vargas', 'Lidia', 'Lima', 'Federico Villarreal 456 - SMP', 'lcastro', 'flaca' );
INSERT INTO empleado VALUES( '0003', 'Reyes', 'Ortiz', 'Claudia', 'Lima', 'Av. Aviación 3456 - San Borja', 'creyes', 'linda' );
INSERT INTO empleado VALUES( '0004', 'Ramos', 'Garibay', 'Angelica', 'Chiclayo', 'Calle Barcelona 345', 'aramos', 'china' );
INSERT INTO empleado VALUES( '0005', 'Ruiz', 'Zabaleta', 'Claudia', 'Cusco', 'Calle Cruz Verde 364', 'cvalencia', 'angel' );
INSERT INTO empleado VALUES( '0006', 'Cruz', 'Tarazona', 'Ricardo', 'Areguipa', 'Calle La Gruta 304', 'rcruz', 'cerebro' );
INSERT INTO empleado VALUES( '0007', 'Diaz', 'Flores', 'Edith', 'Lima', 'Av. Pardo 546', 'ediaz', 'princesa' );
INSERT INTO empleado VALUES( '0008', 'Sarmiento', 'Bellido', 'Claudia Rocio', 'Areguipa', 'Calle Alfonso Ugarte 1567', 'csarmiento', 'chinita' );
INSERT INTO empleado VALUES( '0009', 'Pachas', 'Sifuentes', 'Luis Alberto', 'Trujillo', 'Francisco Pizarro 1263', 'lpachas', 'gato' );
INSERT INTO empleado VALUES( '0010', 'Tello', 'Alarcon', 'Hugo Valentin', 'Cusco', 'Los Angeles 865', 'htello', 'machupichu' );
INSERT INTO empleado VALUES( '0011', 'Carrasco', 'Vargas', 'Pedro Hugo', 'Chiclayo', 'Av. Balta 1265', 'pcarrasco', 'tinajones' );

-- Asignado

insert into Asignado values( '000001', '001', '0004', '20071115', null );
insert into Asignado values( '000002', '002', '0001', '20071120', null );
insert into Asignado values( '000003', '003', '0002', '20071128', null );
insert into Asignado values( '000004', '004', '0003', '20071212', '20080325' );
insert into Asignado values( '000005', '005', '0006', '20071220', null );
insert into Asignado values( '000006', '006', '0005', '20080105', null );
insert into Asignado values( '000007', '004', '0007', '20080107', null );
insert into Asignado values( '000008', '005', '0008', '20080107', null );
insert into Asignado values( '000009', '001', '0011', '20080108', null );
insert into Asignado values( '000010', '002', '0009', '20080108', null );
insert into Asignado values( '000011', '006', '0010', '20080108', null );

-- Tabla: Parametro

insert into Parametro values( '001', 'ITF - Impuesto a la Transacciones Financieras', '0.08', 'ACTIVO' );
insert into Parametro values( '002', 'Número de Operaciones Sin Costo', '15', 'ACTIVO' );

-- Tabla: Cliente

insert into cliente values( '00001', 'CORONEL', 'CASTILLO', 'ERIC GUSTAVO', '06914897', 'LIMA', 'LOS OLIVOS', '9666-4457', 'gcoronel@viabcp.com' );
insert into cliente values( '00002', 'VALENCIA', 'MORALES', 'PEDRO HUGO', '01576173', 'LIMA', 'MAGDALENA', '924-7834', 'pvalencia@terra.com.pe' );
insert into cliente values( '00003', 'MARCELO', 'VILLALOBOS', 'RICARDO', '10762367', 'LIMA', 'LINCE', '993-62966', 'ricardomarcelo@hotmail.com' );
insert into cliente values( '00004', 'ROMERO', 'CASTILLO', 'CARLOS ALBERTO', '06531983', 'LIMA', 'LOS OLIVOS', '865-84762', 'c.romero@hotmail.com' );
insert into cliente values( '00005', 'ARANDA', 'LUNA', 'ALAN ALBERTO', '10875611', 'LIMA', 'SAN ISIDRO', '834-67125', 'a.aranda@hotmail.com' );
insert into cliente values( '00006', 'AYALA', 'PAZ', 'JORGE LUIS', '10679245', 'LIMA', 'SAN BORJA', '963-34769', 'j.ayala@yahoo.com' );
insert into cliente values( '00007', 'CHAVEZ', 'CANALES', 'EDGAR RAFAEL', '10145693', 'LIMA', 'MIRAFLORES', '999-96673', 'e.chavez@gmail.com' );
insert into cliente values( '00008', 'FLORES', 'CHAFLOQUE', 'ROSA LIZET', '10773456', 'LIMA', 'LA MOLINA', '966-87567', 'r.florez@hotmail.com' );
insert into cliente values( '00009', 'FLORES', 'CASTILLO', 'CRISTIAN RAFAEL', '10346723', 'LIMA', 'LOS OLIVOS', '978-43768', 'c.flores@hotmail.com' );
insert into cliente values( '00010', 'GONZALES', 'GARCIA', 'GABRIEL ALEJANDRO', '10192376', 'LIMA', 'SAN MIGUEL', '945-56782', 'g.gonzales@yahoo.es' );
insert into cliente values( '00011', 'LAY', 'VALLEJOS', 'JUAN CARLOS', '10942287', 'LIMA', 'LINCE', '956-12657', 'j.lay@peru.com' );
insert into cliente values( '00012', 'MONTALVO', 'SOTO', 'DEYSI LIDIA', '10612376', 'LIMA', 'SURCO', '965-67235', 'd.montalvo@hotmail.com' );
insert into cliente values( '00013', 'RICALDE', 'RAMIREZ', 'ROSARIO ESMERALDA', '10761324', 'LIMA', 'MIRAFLORES', '991-23546', 'r.ricalde@gmail.com' );
insert into cliente values( '00014', 'RODRIGUEZ', 'FLORES', 'ENRIQUE MANUEL', '10773345', 'LIMA', 'LINCE', '976-82838', 'e.rodriguez@gmail.com' );
insert into cliente values( '00015', 'ROJAS', 'OSCANOA', 'FELIX NINO', '10238943', 'LIMA', 'LIMA', '962-32158', 'f.rojas@yahoo.com' );
insert into cliente values( '00016', 'TEJADA', 'DEL AGUILA', 'TANIA LORENA', '10446791', 'LIMA', 'PUEBLO LIBRE', '966-23854', 't.tejada@hotmail.com' );
insert into cliente values( '00017', 'VALDEVIESO', 'LEYVA', 'LIDIA ROXANA', '10452682', 'LIMA', 'SURCO', '956-78951', 'r.valdivieso@terra.com.pe' );
insert into cliente values( '00018', 'VALENTIN', 'COTRINA', 'JUAN DIEGO', '10398247', 'LIMA', 'LA MOLINA', '921-12456', 'j.valentin@terra.com.pe' );
insert into cliente values( '00019', 'YAURICASA', 'BAUTISTA', 'YESABETH', '10934584', 'LIMA', 'MAGDALENA', '977-75777', 'y.yauricasa@terra.com.pe' );
insert into cliente values( '00020', 'ZEGARRA', 'GARCIA', 'FERNANDO MOISES', '10772365', 'LIMA', 'SAN ISIDRO', '936-45876', 'f.zegarra@hotmail.com' );

-- Tabla: Cuenta

insert into cuenta values('00200001','01','002','0001','00008',7000,'20080105','ACTIVO',15,'123456');
insert into cuenta values('00200002','01','002','0001','00001',6800,'20080109','ACTIVO',3,'123456');
insert into cuenta values('00200003','02','002','0001','00007',6000,'20080111','ACTIVO',6,'123456');
insert into cuenta values('00100001','01','001','0004','00005',6900,'20080106','ACTIVO',7,'123456');
insert into cuenta values('00100002','02','001','0004','00005',4500,'20080108','ACTIVO',4,'123456');
insert into cuenta values('00300001','01','003','0002','00010',0000,'20080107','CANCELADO',3,'123456');

-- Tabla: Movimiento

insert into movimiento values('00100002',01,'20080108','0004','001',1800,null);
insert into movimiento values('00100002',02,'20080125','0004','004',1000,null);
insert into movimiento values('00100002',03,'20080213','0004','003',2200,null);
insert into movimiento values('00100002',04,'20080308','0004','003',1500,null);

insert into movimiento values('00100001',01,'20080106','0004','001',2800,null);
insert into movimiento values('00100001',02,'20080115','0004','003',3200,null);
insert into movimiento values('00100001',03,'20080120','0004','004',0800,null);
insert into movimiento values('00100001',04,'20080214','0004','003',2000,null);
insert into movimiento values('00100001',05,'20080225','0004','004',0500,null);
insert into movimiento values('00100001',06,'20080303','0004','004',0800,null);
insert into movimiento values('00100001',07,'20080315','0004','003',1000,null);

insert into movimiento values('00200003',01,'20080111','0001','001',2500,null);
insert into movimiento values('00200003',02,'20080117','0001','003',1500,null);
insert into movimiento values('00200003',03,'20080120','0001','004',0500,null);
insert into movimiento values('00200003',04,'20080209','0001','004',0500,null);
insert into movimiento values('00200003',05,'20080225','0001','003',3500,null);
insert into movimiento values('00200003',06,'20080311','0001','004',0500,null);

insert into movimiento values('00200002',01,'20080109','0001','001',3800,null);
insert into movimiento values('00200002',02,'20080120','0001','003',4200,null);
insert into movimiento values('00200002',03,'20080306','0001','004',1200,null);

insert into movimiento values('00200001',01,'20080105','0001','001',5000,null);
insert into movimiento values('00200001',02,'20080107','0001','003',4000,null);
insert into movimiento values('00200001',03,'20080109','0001','004',2000,null);
insert into movimiento values('00200001',04,'20080111','0001','003',1000,null);
insert into movimiento values('00200001',05,'20080113','0001','003',2000,null);
insert into movimiento values('00200001',06,'20080115','0001','004',4000,null);
insert into movimiento values('00200001',07,'20080119','0001','003',2000,null);
insert into movimiento values('00200001',08,'20080121','0001','004',3000,null);
insert into movimiento values('00200001',09,'20080123','0001','003',7000,null);
insert into movimiento values('00200001',10,'20080127','0001','004',1000,null);
insert into movimiento values('00200001',11,'20080130','0001','004',3000,null);
insert into movimiento values('00200001',12,'20080204','0001','003',2000,null);
insert into movimiento values('00200001',13,'20080208','0001','004',4000,null);
insert into movimiento values('00200001',14,'20080213','0001','003',2000,null);
insert into movimiento values('00200001',15,'20080219','0001','004',1000,null);

insert into movimiento values('00300001',01,'20080107','0002','001',5600,null);
insert into movimiento values('00300001',02,'20080118','0002','003',1400,null);
insert into movimiento values('00300001',03,'20080125','0002','002',7000,null);

--  Tabla: Contador

insert into Contador Values( 'Moneda', 2, 2 );
insert into Contador Values( 'TipoMovimiento', 10, 3 );
insert into Contador Values( 'Sucursal', 7, 3 );
insert into Contador Values( 'Empleado', 11, 4 );
insert into Contador Values( 'Asignado', 11, 6 );
insert into Contador Values( 'Parametro', 2, 3 );
insert into Contador Values( 'Cliente', 21, 5 );

-- Analizar el rendimiento de cada sucursal con respecto al total de depósitos realizados durante febrero 2008.
SELECT 
    s.vch_sucunombre AS Sucursal,
    SUM(m.dec_moviimporte) AS Total_Depositado
FROM 
    Movimiento m
JOIN TipoMovimiento t ON m.chr_tipocodigo = t.chr_tipocodigo
JOIN Cuenta c ON m.chr_cuencodigo = c.chr_cuencodigo
JOIN Sucursal s ON c.chr_sucucodigo = s.chr_sucucodigo
WHERE 
    t.vch_tipodescripcion = 'Deposito'
    AND MONTH(m.dtt_movifecha) = 2
    AND YEAR(m.dtt_movifecha) = 2008
GROUP BY 
    s.vch_sucunombre;


-- top 3---
SELECT TOP 3 
    e.vch_emplnombre + ' ' + e.vch_emplpaterno AS Empleado,
    COUNT(*) AS Total_Cuentas_Creadas
FROM 
    Cuenta c
JOIN Empleado e ON c.chr_emplcreacuenta = e.chr_emplcodigo
GROUP BY 
    e.vch_emplnombre, e.vch_emplpaterno
ORDER BY 
    Total_Cuentas_Creadas DESC;

--cuentas cerradas--

SELECT 
    c.chr_cuencodigo,
    cl.vch_clienombre + ' ' + cl.vch_cliepaterno AS Cliente,
    c.vch_cuenestado,
    c.dtt_cuenfechacreacion
FROM 
    Cuenta c
JOIN Cliente cl ON c.chr_cliecodigo = cl.chr_cliecodigo
WHERE 
    c.vch_cuenestado = 'CANCELADO'
    AND c.dtt_cuenfechacreacion BETWEEN '2008-01-01' AND '2008-03-31';

--frecuencia de operaciones según tipo de moneda--
SELECT 
    m.chr_monecodigo AS Moneda,
    COUNT(*) AS Total_Operaciones
FROM 
    Cuenta c
JOIN Movimiento mo ON c.chr_cuencodigo = mo.chr_cuencodigo
JOIN Moneda m ON c.chr_monecodigo = m.chr_monecodigo
GROUP BY 
    m.chr_monecodigo;


--carga operativa--
SELECT 
    s.vch_sucunombre AS Sucursal,
    COUNT(*) AS Total_Movimientos
FROM 
    Movimiento m
JOIN Cuenta c ON m.chr_cuencodigo = c.chr_cuencodigo
JOIN Sucursal s ON c.chr_sucucodigo = s.chr_sucucodigo
GROUP BY 
    s.vch_sucunombre
ORDER BY 
    Total_Movimientos DESC;


--ciudad con saldo promedio alto--
SELECT 
    cl.vch_clieciudad AS Ciudad,
    AVG(c.dec_cuensaldo) AS Promedio_Saldo
FROM 
    Cliente cl
JOIN Cuenta c ON cl.chr_cliecodigo = c.chr_cliecodigo
GROUP BY 
    cl.vch_clieciudad
ORDER BY 
    Promedio_Saldo DESC;

--cuentas con alto volumen de egresos frente a ingresos--
SELECT 
    c.chr_cuencodigo AS Cuenta,
    SUM(CASE WHEN t.vch_tipoaccion = 'INGRESO' THEN 1 ELSE 0 END) AS Ingresos,
    SUM(CASE WHEN t.vch_tipoaccion = 'SALIDA' THEN 1 ELSE 0 END) AS Salidas
FROM 
    Movimiento m
JOIN TipoMovimiento t ON m.chr_tipocodigo = t.chr_tipocodigo
JOIN Cuenta c ON m.chr_cuencodigo = c.chr_cuencodigo
GROUP BY 
    c.chr_cuencodigo
ORDER BY 
    Salidas DESC;