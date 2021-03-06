
CREATE SCHEMA TESTIGOS_DE_HENRY
GO

-- CREACI�N TABLA MODELO --
CREATE PROC TESTIGOS_DE_HENRY.tabla_modelo
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.MODELO (
	MODELO_CODIGO DECIMAL(18,0) NOT NULL,
	MODELO_NOMBRE NVARCHAR(255),
	MODELO_POTENCIA DECIMAL(18,0)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.MODELO ADD CONSTRAINT PK_MODELO PRIMARY KEY (MODELO_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.MODELO
	SELECT MODELO_CODIGO, MODELO_NOMBRE, MODELO_POTENCIA 
	FROM gd_esquema.Maestra 
	GROUP BY MODELO_CODIGO, MODELO_NOMBRE, MODELO_POTENCIA
	ORDER BY MODELO_CODIGO;
GO

-- TABLA SUCURSAL --
CREATE PROC TESTIGOS_DE_HENRY.tabla_sucursal 
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.SUCURSAL (
	SUCURSAL_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	SUCURSAL_MAIL NVARCHAR(255),
	SUCURSAL_TELEFONO DECIMAL(18,0),
	SUCURSAL_DIRECCION NVARCHAR(255),
	SUCURSAL_CIUDAD NVARCHAR(255)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.SUCURSAL ADD CONSTRAINT PK_SUCURSAL PRIMARY KEY (SUCURSAL_ID);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.SUCURSAL 
	SELECT SUCURSAL_MAIL, SUCURSAL_TELEFONO, SUCURSAL_DIRECCION, SUCURSAL_CIUDAD
	FROM gd_esquema.Maestra
	WHERE SUCURSAL_DIRECCION IS NOT NULL
	GROUP BY SUCURSAL_MAIL, SUCURSAL_TELEFONO, SUCURSAL_DIRECCION, SUCURSAL_CIUDAD;
GO

-- TABLA AUTO_PARTE --
CREATE PROC TESTIGOS_DE_HENRY.tabla_auto_parte 
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.AUTO_PARTE (
	AUTO_PARTE_CODIGO DECIMAL(18,0) NOT NULL,
	AUTO_PARTE_DESCRIPCION NVARCHAR(255)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.AUTO_PARTE ADD CONSTRAINT PK_AUTO_PARTE PRIMARY KEY (AUTO_PARTE_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.AUTO_PARTE
	SELECT AUTO_PARTE_CODIGO, AUTO_PARTE_DESCRIPCION
	FROM gd_esquema.Maestra
	WHERE AUTO_PARTE_CODIGO IS NOT NULL
	GROUP BY AUTO_PARTE_CODIGO, AUTO_PARTE_DESCRIPCION
	ORDER BY AUTO_PARTE_CODIGO;
GO

-- TABLA FABRICANTE --
CREATE PROC TESTIGOS_DE_HENRY.tabla_fabricante 
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.FABRICANTE (
	FABRICANTE_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	FABRICANTE_NOMBRE NVARCHAR(255)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.FABRICANTE ADD CONSTRAINT PK_FABRICANTE PRIMARY KEY (FABRICANTE_ID);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.FABRICANTE
	SELECT FABRICANTE_NOMBRE
	FROM gd_esquema.Maestra
	GROUP BY FABRICANTE_NOMBRE
	ORDER BY FABRICANTE_NOMBRE;
GO

-- TABLA CLIENTE --
CREATE PROC TESTIGOS_DE_HENRY.tabla_cliente
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.CLIENTE (
	CLIENTE_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	CLIENTE_NOMBRE NVARCHAR(255),
	CLIENTE_APELLIDO NVARCHAR(255),
	CLIENTE_DIRECCION NVARCHAR(255),
	CLIENTE_DNI DECIMAL(18,0),
	CLIENTE_MAIL NVARCHAR(255),
	CLIENTE_FECHA_NAC DATETIME2(3)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.CLIENTE ADD CONSTRAINT PK_CLIENTE PRIMARY KEY (CLIENTE_ID);

-- SE INSERTAN LOS DATOS DE LOS CLIENTES DE LAS COMPRAS
INSERT INTO TESTIGOS_DE_HENRY.CLIENTE
	SELECT CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_DNI, CLIENTE_MAIL, CLIENTE_FECHA_NAC
	FROM gd_esquema.Maestra
	WHERE CLIENTE_NOMBRE IS NOT NULL
	GROUP BY CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_DNI, CLIENTE_MAIL, CLIENTE_FECHA_NAC
	ORDER BY CLIENTE_DNI;
	
-- SE INSERTAN LOS DATOS DE LOS CLIENTES DE LAS VENTAS
INSERT INTO TESTIGOS_DE_HENRY.CLIENTE
	SELECT FAC_CLIENTE_NOMBRE, FAC_CLIENTE_APELLIDO, FAC_CLIENTE_DIRECCION, FAC_CLIENTE_DNI, FAC_CLIENTE_MAIL, FAC_CLIENTE_FECHA_NAC
	FROM gd_esquema.Maestra
	WHERE FAC_CLIENTE_NOMBRE IS NOT NULL
	GROUP BY FAC_CLIENTE_NOMBRE, FAC_CLIENTE_APELLIDO, FAC_CLIENTE_DIRECCION, FAC_CLIENTE_DNI, FAC_CLIENTE_MAIL, FAC_CLIENTE_FECHA_NAC
	ORDER BY FAC_CLIENTE_DNI;
GO

-- TABLA TIPO_AUTO --
CREATE PROC TESTIGOS_DE_HENRY.tabla_tipo_auto
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.TIPO_AUTO (
	TIPO_AUTO_CODIGO DECIMAL(18,0) NOT NULL,
	TIPO_AUTO_DESC NVARCHAR(255)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.TIPO_AUTO ADD CONSTRAINT PK_TIPO_AUTO PRIMARY KEY (TIPO_AUTO_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.TIPO_AUTO
	SELECT TIPO_AUTO_CODIGO, TIPO_AUTO_DESC
	FROM gd_esquema.Maestra
	WHERE TIPO_AUTO_CODIGO IS NOT NULL
	GROUP BY TIPO_AUTO_CODIGO, TIPO_AUTO_DESC
	ORDER BY TIPO_AUTO_CODIGO;
GO

-- TABLA TIPO_CAJA --
CREATE PROC TESTIGOS_DE_HENRY.tabla_tipo_caja
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.TIPO_CAJA (
	TIPO_CAJA_CODIGO DECIMAL(18,0) NOT NULL,
	TIPO_CAJA_DESC NVARCHAR(255)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.TIPO_CAJA ADD CONSTRAINT PK_TIPO_CAJA PRIMARY KEY (TIPO_CAJA_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.TIPO_CAJA
	SELECT TIPO_CAJA_CODIGO, TIPO_CAJA_DESC 
	FROM gd_esquema.Maestra 
	WHERE TIPO_CAJA_CODIGO IS NOT NULL 
	GROUP BY TIPO_CAJA_CODIGO, TIPO_CAJA_DESC
	ORDER BY TIPO_CAJA_CODIGO;

GO

-- TABLA TIPO_TRANSMISION --
CREATE PROC TESTIGOS_DE_HENRY.tabla_tipo_transmision
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.TIPO_TRANSMISION (
	TIPO_TRANSMISION_CODIGO DECIMAL(18,0) NOT NULL,
	TIPO_TRANSMISION_DESC NVARCHAR(255)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.TIPO_TRANSMISION ADD CONSTRAINT PK_TIPO_TRANSMISION PRIMARY KEY (TIPO_TRANSMISION_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.TIPO_TRANSMISION 
	SELECT TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC
	FROM gd_esquema.Maestra
	WHERE TIPO_CAJA_CODIGO IS NOT NULL 
	GROUP BY TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC
	ORDER BY TIPO_TRANSMISION_CODIGO;

GO

-- TABLA TIPO_MOTOR --
CREATE PROC TESTIGOS_DE_HENRY.tabla_tipo_motor
AS

-- CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.TIPO_MOTOR (
	TIPO_MOTOR_CODIGO DECIMAL(18,0) NOT NULL
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.TIPO_MOTOR ADD CONSTRAINT PK_TIPO_MOTOR PRIMARY KEY (TIPO_MOTOR_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.TIPO_MOTOR
	SELECT TIPO_MOTOR_CODIGO
	FROM gd_esquema.Maestra 
	WHERE TIPO_MOTOR_CODIGO IS NOT NULL 
	GROUP BY TIPO_MOTOR_CODIGO
	ORDER BY TIPO_MOTOR_CODIGO;
GO

-- TABLA AUTOTOMOVIL --
CREATE PROC TESTIGOS_DE_HENRY.tabla_automovil
AS

--CREACI�N DE LA TABLA
CREATE TABLE TESTIGOS_DE_HENRY.AUTOMOVIL (
	AUTOMOVIL_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	AUTOMOVIL_NRO_CHASIS NVARCHAR(50),
	AUTOMOVIL_NRO_MOTOR NVARCHAR(50),
	AUTOMOVIL_PATENTE NVARCHAR(50),
	AUTOMOVIL_FECHA_ALTA DATETIME2(3),
	AUTOMOVIL_CANT_KMS DECIMAL(18,0),
	AUTOMOVIL_MODELO_CODIGO DECIMAL(18,0),
	AUTOMOVIL_TIPO_AUTO_CODIGO DECIMAL(18,0),
	AUTOMOVIL_TIPO_CAJA_CODIGO DECIMAL(18,0),
	AUTOMOVIL_TIPO_TRANSMISION_CODIGO DECIMAL(18,0),
	AUTOMOVIL_TIPO_MOTOR_CODIGO DECIMAL(18,0)
);

-- SE CREA LA PK
ALTER TABLE TESTIGOS_DE_HENRY.AUTOMOVIL ADD CONSTRAINT PK_AUTOMOVIL PRIMARY KEY (AUTOMOVIL_ID);

-- SE CREAN LAS FKs REFERENCIANDO A LOS CAMPOS CORRESPONDIENTES
ALTER TABLE TESTIGOS_DE_HENRY.AUTOMOVIL ADD CONSTRAINT FK_MODELO FOREIGN KEY (AUTOMOVIL_MODELO_CODIGO) REFERENCES TESTIGOS_DE_HENRY.MODELO(MODELO_CODIGO);
ALTER TABLE TESTIGOS_DE_HENRY.AUTOMOVIL ADD CONSTRAINT FK_TIPO_AUTO FOREIGN KEY (AUTOMOVIL_TIPO_AUTO_CODIGO) REFERENCES TESTIGOS_DE_HENRY.TIPO_AUTO(TIPO_AUTO_CODIGO);
ALTER TABLE TESTIGOS_DE_HENRY.AUTOMOVIL ADD CONSTRAINT FK_TIPO_CAJA FOREIGN KEY (AUTOMOVIL_TIPO_CAJA_CODIGO) REFERENCES TESTIGOS_DE_HENRY.TIPO_CAJA(TIPO_CAJA_CODIGO);
ALTER TABLE TESTIGOS_DE_HENRY.AUTOMOVIL ADD CONSTRAINT FK_TIPO_MOTOR FOREIGN KEY (AUTOMOVIL_TIPO_TRANSMISION_CODIGO) REFERENCES TESTIGOS_DE_HENRY.TIPO_MOTOR(TIPO_MOTOR_CODIGO);
ALTER TABLE TESTIGOS_DE_HENRY.AUTOMOVIL ADD CONSTRAINT FK_TIPO_TRANSMISION FOREIGN KEY (AUTOMOVIL_TIPO_MOTOR_CODIGO) REFERENCES TESTIGOS_DE_HENRY.TIPO_TRANSMISION(TIPO_TRANSMISION_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.AUTOMOVIL 
	SELECT AUTO_NRO_CHASIS, AUTO_NRO_MOTOR, AUTO_PATENTE, AUTO_FECHA_ALTA, AUTO_CANT_KMS, MODELO_CODIGO, TIPO_AUTO_CODIGO, TIPO_CAJA_CODIGO, TIPO_TRANSMISION_CODIGO, TIPO_MOTOR_CODIGO 
	FROM gd_esquema.Maestra
	WHERE AUTO_PATENTE IS NOT NULL 
	GROUP BY AUTO_NRO_CHASIS, AUTO_NRO_MOTOR, AUTO_PATENTE, AUTO_FECHA_ALTA, AUTO_CANT_KMS, MODELO_CODIGO, TIPO_AUTO_CODIGO, TIPO_CAJA_CODIGO, TIPO_TRANSMISION_CODIGO, TIPO_MOTOR_CODIGO;
GO

-- TABLA COMPRA --
CREATE PROC TESTIGOS_DE_HENRY.tablas_compra
AS

--CREACI�N DE LA TABLA GENERAL: COMPRA
CREATE TABLE TESTIGOS_DE_HENRY.COMPRA (
	COMPRA_NRO DECIMAL(18,0) NOT NULL,
	COMPRA_FECHA DATETIME2(3),
	COMPRA_SUCURSAL_ID DECIMAL(18,0)
);

-- SE CREA LA PK DE LA TABLA COMPRA
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA ADD CONSTRAINT PK_COMPRA PRIMARY KEY (COMPRA_NRO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.COMPRA
	SELECT m.COMPRA_NRO, m.COMPRA_FECHA, s.SUCURSAL_ID
	FROM gd_esquema.Maestra m JOIN TESTIGOS_DE_HENRY.SUCURSAL s ON m.SUCURSAL_DIRECCION = s.SUCURSAL_DIRECCION
	WHERE m.COMPRA_NRO IS NOT NULL
	GROUP BY m.COMPRA_NRO, m.COMPRA_FECHA, m.SUCURSAL_DIRECCION, s.SUCURSAL_ID; 

-- CREACI�N DE LA TABLA: COMPRA_AUTOMOVIL
CREATE TABLE TESTIGOS_DE_HENRY.COMPRA_AUTOMOVIL (
	COMPRA_AUTOMOVIL_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	COMPRA_AUTOMOVIL_PRECIO DECIMAL(18,2),
	COMPRA_AUTOMOVIL_COMPRA_NRO DECIMAL(18,0),
	COMPRA_AUTOMOVIL_AUTOMOVIL_ID DECIMAL(18,0)
);

-- SE CREA LA PK DE LA TABLA COMPRA_AUTOMOVIL
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTOMOVIL ADD CONSTRAINT PK_COMPRA_AUTOMOVIL PRIMARY KEY (COMPRA_AUTOMOVIL_ID);

-- SE CREAN LAS FKs REFERENCIANDO A LOS CAMPOS CORRESPONDIENTES
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTOMOVIL ADD CONSTRAINT FK_COMPRA_ FOREIGN KEY (COMPRA_AUTOMOVIL_COMPRA_NRO) REFERENCES TESTIGOS_DE_HENRY.COMPRA(COMPRA_NRO);
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTOMOVIL ADD CONSTRAINT FK_AUTOMOVIL FOREIGN KEY (COMPRA_AUTOMOVIL_AUTOMOVIL_ID) REFERENCES TESTIGOS_DE_HENRY.AUTOMOVIL(AUTOMOVIL_ID);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.COMPRA_AUTOMOVIL
	SELECT m.COMPRA_PRECIO, m.COMPRA_NRO, a1.AUTOMOVIL_ID
	FROM gd_esquema.Maestra m
	JOIN TESTIGOS_DE_HENRY.AUTOMOVIL a1 ON a1.AUTOMOVIL_PATENTE + a1.AUTOMOVIL_NRO_CHASIS = m.AUTO_PATENTE + m.AUTO_NRO_CHASIS
	WHERE COMPRA_CANT IS NULL
	GROUP BY m.COMPRA_PRECIO, m.COMPRA_NRO, a1.AUTOMOVIL_ID, m.AUTO_PATENTE, m.AUTO_NRO_CHASIS;

-- CREACI�N DE LA TABLA: COMPRA AUTO_PARTE --
CREATE TABLE TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE (
	COMPRA_AUTO_PARTE_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	COMPRA_AUTO_PARTE_CANTIDAD DECIMAL(18,0),
	COMPRA_AUTO_PARTE_PRECIO DECIMAL(18,2),
	COMPRA_AUTO_PARTE_COMPRA_NRO DECIMAL(18,0),
	COMPRA_AUTO_PARTE_MODELO_CODIGO DECIMAL(18,0),
	COMPRA_AUTO_PARTE_FABRICANTE_ID DECIMAL(18,0),
	COMPRA_AUTO_PARTE_AUTO_PARTE_CODIGO DECIMAL(18,0)
);

-- SE CREA LA PK DE LA TABLA COMPRA_AUTOMOVIL
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE ADD CONSTRAINT PK_COMPRA_AUTO_PARTE PRIMARY KEY (COMPRA_AUTO_PARTE_ID);

-- SE CREAN LAS FKs REFERENCIANDO A LOS CAMPOS CORRESPONDIENTES
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE ADD CONSTRAINT FK_COMPRA FOREIGN KEY (COMPRA_AUTO_PARTE_COMPRA_NRO) REFERENCES TESTIGOS_DE_HENRY.COMPRA(COMPRA_NRO);
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE ADD CONSTRAINT FK_MODELO_ FOREIGN KEY (COMPRA_AUTO_PARTE_MODELO_CODIGO) REFERENCES TESTIGOS_DE_HENRY.MODELO(MODELO_CODIGO);
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE ADD CONSTRAINT FK_FABRICANTE FOREIGN KEY (COMPRA_AUTO_PARTE_FABRICANTE_ID) REFERENCES TESTIGOS_DE_HENRY.FABRICANTE(FABRICANTE_ID);
ALTER TABLE TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE ADD CONSTRAINT FK_AUTO_PARTE FOREIGN KEY (COMPRA_AUTO_PARTE_AUTO_PARTE_CODIGO) REFERENCES TESTIGOS_DE_HENRY.AUTO_PARTE(AUTO_PARTE_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE
	SELECT m.COMPRA_CANT, m.COMPRA_PRECIO, m.COMPRA_NRO, m.MODELO_CODIGO, f1.FABRICANTE_ID, m.AUTO_PARTE_CODIGO
	FROM gd_esquema.Maestra m 
	JOIN TESTIGOS_DE_HENRY.FABRICANTE f1 ON f1.FABRICANTE_NOMBRE = m.FABRICANTE_NOMBRE
	WHERE m.COMPRA_CANT IS NOT NULL 
GO

-- TABLA FACTURA --
CREATE PROC TESTIGOS_DE_HENRY.tablas_factura
AS

-- CREACI�N DE LA TABLA GENERAL: FACTURA
CREATE TABLE TESTIGOS_DE_HENRY.FACTURA (
	FACTURA_NRO DECIMAL(18,0) NOT NULL,
	FACTURA_FECHA DATETIME2(3),
	FACTURA_SUCURSAL_ID DECIMAL(18,0),
	FACTURA_CLIENTE_ID DECIMAL(18,0)
);

-- SE CREA LA PK DE LA TABLA FACURA
ALTER TABLE TESTIGOS_DE_HENRY.FACTURA ADD CONSTRAINT PK_FACTURA PRIMARY KEY (FACTURA_NRO);

-- SE CREAN LAS FKs REFERENCIANDO A LOS CAMPOS CORRESPONDIENTES
ALTER TABLE TESTIGOS_DE_HENRY.FACTURA ADD CONSTRAINT FK_SUCURSAL FOREIGN KEY (FACTURA_SUCURSAL_ID) REFERENCES TESTIGOS_DE_HENRY.SUCURSAL(SUCURSAL_ID);
ALTER TABLE TESTIGOS_DE_HENRY.FACTURA ADD CONSTRAINT FK_CLIENTE FOREIGN KEY (FACTURA_CLIENTE_ID) REFERENCES TESTIGOS_DE_HENRY.CLIENTE(CLIENTE_ID);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.FACTURA
	SELECT m.FACTURA_NRO, m.FACTURA_FECHA, s1.SUCURSAL_ID, c1.CLIENTE_ID
	FROM gd_esquema.Maestra m
	JOIN TESTIGOS_DE_HENRY.SUCURSAL s1 ON s1.SUCURSAL_DIRECCION = m.FAC_SUCURSAL_DIRECCION
	JOIN TESTIGOS_DE_HENRY.CLIENTE c1 ON STR(c1.CLIENTE_DNI) + c1.CLIENTE_NOMBRE + c1.CLIENTE_APELLIDO + c1.CLIENTE_DIRECCION = STR(m.FAC_CLIENTE_DNI) + m.FAC_CLIENTE_NOMBRE + m.FAC_CLIENTE_APELLIDO + m.FAC_CLIENTE_DIRECCION
	WHERE FACTURA_NRO IS NOT NULL
	GROUP BY m.FACTURA_NRO, m.FACTURA_FECHA, s1.SUCURSAL_ID, c1.CLIENTE_ID
	ORDER BY m.FACTURA_NRO;

-- CREACI�N DE LA TABLA: FACTURA_AUTOMOVIL
CREATE TABLE TESTIGOS_DE_HENRY.FACTURA_AUTOMOVIL (
	FACTURA_AUTOMOVIL_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	FACTURA_AUTOMOVIL_PRECIO DECIMAL(18,2),
	FACTURA_AUTOMOVIL_AUTOMOVIL_ID DECIMAL(18,0),
	FACTURA_AUTOMOVIL_FACTURA_ID DECIMAL(18,0)
);

-- SE CREA LA PK DE LA TABLA FACTURA_AUTOMOVIL
ALTER TABLE TESTIGOS_DE_HENRY.FACTURA_AUTOMOVIL ADD CONSTRAINT PK_FACTURA_AUTOMOVIL PRIMARY KEY (FACTURA_AUTOMOVIL_ID);

-- SE CREAN LAS FKs REFERENCIANDO A LOS CAMPOS CORRESPONDIENTES
ALTER TABLE TESTIGOS_DE_HENRY.FACTURA_AUTOMOVIL ADD CONSTRAINT FK_FACTURA FOREIGN KEY (FACTURA_AUTOMOVIL_FACTURA_ID) REFERENCES TESTIGOS_DE_HENRY.FACTURA(FACTURA_NRO);
ALTER TABLE TESTIGOS_DE_HENRY.FACTURA_AUTOMOVIL ADD CONSTRAINT FK_AUTOMOVIL_ FOREIGN KEY (FACTURA_AUTOMOVIL_AUTOMOVIL_ID) REFERENCES TESTIGOS_DE_HENRY.AUTOMOVIL(AUTOMOVIL_ID);


-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.FACTURA_AUTOMOVIL
	SELECT m.PRECIO_FACTURADO, a1.AUTOMOVIL_ID, m.FACTURA_NRO
	FROM gd_esquema.Maestra m
	JOIN TESTIGOS_DE_HENRY.AUTOMOVIL a1 ON a1.AUTOMOVIL_PATENTE + a1.AUTOMOVIL_NRO_CHASIS = m.AUTO_PATENTE + m.AUTO_NRO_CHASIS
	WHERE m.FACTURA_NRO IS NOT NULL AND AUTO_PARTE_CODIGO IS NULL
	GROUP BY m.FACTURA_NRO, m.FACTURA_FECHA, m.PRECIO_FACTURADO, m.AUTO_PATENTE, m.AUTO_NRO_CHASIS, a1.AUTOMOVIL_ID
	ORDER BY m.FACTURA_NRO;

-- CREACI�N DE LA TABLA: ITEM_FACTURA
CREATE TABLE TESTIGOS_DE_HENRY.ITEM_FACTURA (
	ITEM_FACTURA_ID DECIMAL(18,0) NOT NULL IDENTITY(1,1),
	ITEM_FACTURA_CANTIDAD DECIMAL(18,0),
	ITEM_FACTURA_PRECIO DECIMAL(18,2),
	ITEM_FACTURA_AUTO_PARTE_CODIGO DECIMAL(18,0),
	ITEM_FACTURA_FACTURA_ID DECIMAL(18,0)
);

-- SE CREA LA PK DE LA TABLA ITEM_FACTURA
ALTER TABLE TESTIGOS_DE_HENRY.ITEM_FACTURA ADD CONSTRAINT PK_ITEM_FACTURA PRIMARY KEY (ITEM_FACTURA_ID);

-- SE CREAN LAS FKs REFERENCIANDO A LOS CAMPOS CORRESPONDIENTES
ALTER TABLE TESTIGOS_DE_HENRY.ITEM_FACTURA ADD CONSTRAINT FK_FACTURA_ FOREIGN KEY (ITEM_FACTURA_FACTURA_ID) REFERENCES TESTIGOS_DE_HENRY.FACTURA(FACTURA_NRO);
ALTER TABLE TESTIGOS_DE_HENRY.ITEM_FACTURA ADD CONSTRAINT FK_AUTO_PARTE_ FOREIGN KEY (ITEM_FACTURA_AUTO_PARTE_CODIGO) REFERENCES TESTIGOS_DE_HENRY.AUTO_PARTE(AUTO_PARTE_CODIGO);

-- SE INSERTAN LOS DATOS
INSERT INTO TESTIGOS_DE_HENRY.ITEM_FACTURA
	SELECT CANT_FACTURADA, PRECIO_FACTURADO, AUTO_PARTE_CODIGO, FACTURA_NRO
	FROM gd_esquema.Maestra
	WHERE FACTURA_NRO IS NOT NULL AND AUTO_PARTE_CODIGO IS NOT NULL
	ORDER BY FACTURA_NRO
GO

-- MIGRACION --
-- SE CREA ESTE PROC PARA EJECUTAR EL RESTO DE LOS STORED PROCEDURES
CREATE PROC TESTIGOS_DE_HENRY.MIGRACION 
AS
	EXEC TESTIGOS_DE_HENRY.tabla_modelo;
	EXEC TESTIGOS_DE_HENRY.tabla_sucursal;
	EXEC TESTIGOS_DE_HENRY.tabla_auto_parte;
	EXEC TESTIGOS_DE_HENRY.tabla_cliente;
	EXEC TESTIGOS_DE_HENRY.tabla_fabricante;
	EXEC TESTIGOS_DE_HENRY.tabla_tipo_auto;
	EXEC TESTIGOS_DE_HENRY.tabla_tipo_caja;
	EXEC TESTIGOS_DE_HENRY.tabla_tipo_transmision;
	EXEC TESTIGOS_DE_HENRY.tabla_tipo_motor;
	EXEC TESTIGOS_DE_HENRY.tabla_automovil;
	EXEC TESTIGOS_DE_HENRY.tablas_compra;
	EXEC TESTIGOS_DE_HENRY.tablas_factura;
GO

EXEC TESTIGOS_DE_HENRY.MIGRACION
GO
-- CREACI�N DE UNA VISTA PARA VER EL STOCK DE CADA AUTOPARTE
CREATE VIEW TESTIGOS_DE_HENRY.VISTA_STOCK_AUTO_PARTE AS
	SELECT AUTO_PARTE_DESCRIPCION,
	SUM(COMPRA_AUTO_PARTE_CANTIDAD) - ISNULL((SELECT SUM(ITEM_FACTURA_CANTIDAD) FROM TESTIGOS_DE_HENRY.ITEM_FACTURA
										WHERE AUTO_PARTE_CODIGO = ITEM_FACTURA_AUTO_PARTE_CODIGO),0) 
	AS STOCK FROM TESTIGOS_DE_HENRY.COMPRA_AUTO_PARTE 
	JOIN TESTIGOS_DE_HENRY.AUTO_PARTE ON COMPRA_AUTO_PARTE_AUTO_PARTE_CODIGO = AUTO_PARTE_CODIGO
	GROUP BY AUTO_PARTE_DESCRIPCION, AUTO_PARTE_CODIGO;
GO

-- CREACI�N DE UNA VISTA PARA VER EL STOCK DE CADA AUTOMOVIL
CREATE VIEW TESTIGOS_DE_HENRY.VISTA_STOCK_AUTOMOVIL AS
	SELECT MODELO_NOMBRE, COUNT(AUTOMOVIL_ID) AS STOCK FROM TESTIGOS_DE_HENRY.COMPRA_AUTOMOVIL 
	JOIN TESTIGOS_DE_HENRY.AUTOMOVIL ON COMPRA_AUTOMOVIL_AUTOMOVIL_ID = AUTOMOVIL_ID
	JOIN TESTIGOS_DE_HENRY.MODELO ON AUTOMOVIL_MODELO_CODIGO = MODELO_CODIGO
	WHERE (SELECT FACTURA_AUTOMOVIL_AUTOMOVIL_ID FROM TESTIGOS_DE_HENRY.FACTURA_AUTOMOVIL
			WHERE AUTOMOVIL_ID = FACTURA_AUTOMOVIL_AUTOMOVIL_ID) IS NULL
	GROUP BY MODELO_NOMBRE;
GO

-- CREACI�N DE FUNCI�N QUE CALCULA EL PRECIO DE UN AUTOMOVIL
CREATE FUNCTION TESTIGOS_DE_HENRY.CALCULAR_PRECIO_FACTURA(@AUTOMOVIL_ID DECIMAL(18,2))
RETURNS DECIMAL(18,2)
BEGIN 
	RETURN (SELECT COMPRA_AUTOMOVIL_PRECIO FROM TESTIGOS_DE_HENRY.COMPRA_AUTOMOVIL WHERE @AUTOMOVIL_ID = COMPRA_AUTOMOVIL_AUTOMOVIL_ID) * 1.2
END
GO
