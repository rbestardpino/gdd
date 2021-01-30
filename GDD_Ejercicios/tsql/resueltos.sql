/* EJERCICIO 1 */

/* Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artúculo. Si la cantidad almacenada es
menor al límite retornar "OCUPACION DEL DEPOSITO XX %" siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
"DEPOSITO COMPLETO".*/

ALTER FUNCTION EJERCICIO_1 (@articulo char(8), @deposito char(2))
RETURNS varchar(200)
AS
BEGIN
	DECLARE @cantidad_en_deposito Int
	DECLARE @stoc_maximo Int
	DECLARE @respuesta varchar(50)
	SELECT @cantidad_en_deposito = ISNULL(stoc_cantidad,0) , @stoc_maximo = ISNULL(stoc_stock_maximo,0)
	    FROM Stock WHERE stoc_producto = @articulo and stoc_deposito = @deposito

	IF (@cantidad_en_deposito <= @stoc_maximo)
	    SET 
            @respuesta = 'OCUPACION DEL DEPOSITO' + CASE 
                                                        WHEN @stoc_maximo = 0 THEN '0%' 
                                                        ELSE CONCAT(STR(LEFT(@cantidad_en_deposito*100/@stoc_maximo,4)),'%') 
                                                    END
	ELSE
	    SET @respuesta = 'DEPOSITO COMPLETO'
	RETURN @respuesta
END
GO
/* EJERCICIO 2 */

/* Realizar una función que dado un artículo y una fecha, retorne el stock que
exist�ía a esa fecha */

ALTER FUNCTION EJERCICIO_2(@articulo char(8), @fecha smalldatetime)
RETURNS Int
AS
BEGIN
	RETURN ISNULL((SELECT SUM(stoc_cantidad) FROM Stock where @articulo = stoc_producto) +
		   (SELECT SUM(item_cantidad)
				FROM Item_Factura
				JOIN Factura ON fact_numero+fact_tipo+fact_sucursal=item_numero+item_tipo+item_sucursal WHERE @articulo = item_producto and fact_fecha > @fecha),0)
END
GO

/* EJERCICIO 3 */

/* Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un ánico empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución. */

ALTER PROCEDURE EJERCICIO_3
	@cant_empleados_sin_jefe INT OUTPUT
AS
    DECLARE @gg NUMERIC(6)
    
    SELECT @cant_empleados_sin_jefe = COUNT (*) from Empleado where empl_jefe is null
    SELECT TOP 1 @gg =  empl_codigo FROM Empleado 
        WHERE empl_jefe is null
        ORDER BY empl_salario desc, empl_ingreso

    UPDATE Empleado SET empl_jefe = @gg
                    WHERE empl_jefe is null and empl_codigo <> @gg
    RETURN
GO

/* EJERCICIO 4 */

/* Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año. */

ALTER PROCEDURE EJERCICIO_4
	@mejor_vendedor NUMERIC(6,0) OUTPUT
AS
    SELECT TOP 1 @mejor_vendedor = fact_vendedor
        FROM Factura
        WHERE YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
        GROUP BY fact_vendedor
        ORDER BY SUM(fact_total) desc

    UPDATE Empleado SET empl_comision = (SELECT SUM(fact_total)
                                            FROM Factura
                                            WHERE 
                                                YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
                                                AND fact_vendedor = empl_codigo)
	RETURN
GO

/* EJERCICIO 5 */

/*Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definici�n:
Create table Fact_table
( anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2)
)
Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)*/

DROP table fact_table
drop procedure EJERCICIO_5
go

CREATE PROCEDURE EJERCICIO_5
AS
	Create table Fact_table
	(anio char(4) not null,
	 mes char(2) not null,
	 familia char(3) FOREIGN KEY REFERENCES dbo.Familia(fami_id) not null,
	 rubro char(4) FOREIGN KEY REFERENCES dbo.Rubro(rubr_id) not null,
	 zona char(3) FOREIGN KEY REFERENCES dbo.Zona(zona_codigo) not null,
	 cliente char(6) FOREIGN KEY REFERENCES dbo.Cliente(clie_codigo) not null,
	 producto char(8) FOREIGN KEY REFERENCES dbo.Producto(prod_codigo) not null,
	 cantidad decimal(12,2) not null,
	 monto decimal(12,2) not null)
Alter table Fact_table
Add constraint PK_Fact_Table primary key(anio,mes,familia,rubro,zona,cliente,producto)

INSERT INTO fact_table 
SELECT 
    YEAR(f.fact_fecha),
    MONTH(f.fact_fecha),
    p.prod_familia,
    p.prod_rubro, 
    d.depa_zona, 
    f.fact_cliente, 
    it.item_producto, 
    SUM(item_cantidad), 
    SUM(item_cantidad*item_precio)
FROM dbo.Factura f
JOIN dbo.Item_Factura it ON it.item_numero = f.fact_numero AND it.item_sucursal = f.fact_sucursal AND it.item_tipo = f.fact_tipo
JOIN dbo.Producto p ON p.prod_codigo = it.item_producto
JOIN dbo.Empleado e ON f.fact_vendedor = e.empl_codigo
JOIN dbo.Departamento d ON d.depa_codigo = e.empl_departamento 
GROUP BY YEAR(f.fact_fecha), MONTH(f.fact_fecha), p.prod_familia, p.prod_rubro, d.depa_zona, f.fact_cliente, it.item_producto
GO

/* EJERCICIO 7*/
ALTER PROC EJERCICIO7 @comienzo datetime, @fin datetime
AS
    DECLARE @codigo NVARCHAR(30), @detalle NVARCHAR(30), @cant_movs INT, 
            @precio_venta DECIMAL(18,2), @renglon INT = 0, @ganancia DECIMAL(18,2)
	
    DECLARE ventas CURSOR FOR 
        SELECT prod_codigo, prod_detalle, COUNT(DISTINCT item_numero), AVG(item_precio), SUM(item_precio*item_cantidad) - SUM(item_cantidad)*prod_precio
            FROM Producto 
            JOIN Item_Factura on prod_codigo = item_producto
            JOIN Factura on item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo
            WHERE fact_fecha BETWEEN @comienzo AND @fin
            GROUP BY prod_codigo, prod_detalle, prod_precio
    
    OPEN ventas

    FETCH NEXT FROM ventas INTO @codigo, @detalle, @cant_movs, @precio_venta, @ganancia

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @renglon = @renglon + 1
        INSERT INTO Ventas VALUES (@codigo, @detalle, @cant_movs, @precio_venta, @renglon, @ganancia)
        FETCH NEXT FROM ventas INTO @codigo, @detalle, @cant_movs, @precio_venta, @ganancia
    END

    CLOSE ventas
    DEALLOCATE ventas
GO

/* EJERCICIO 8*/

--PREIO QUE SE COMPONE A TRAVÉS DE SUS COMPONENTES
ALTER FUNCTION precio_compuesto (@prod_codigo NVARCHAR(30))
RETURNS DECIMAL(18,2)
BEGIN
    DECLARE @Precio DECIMAL(18,2)

    -- LE ASIGNA EL VALOR DE LA SUMA DE CADA COMPONENTE POR EL PRECIO QUE LO COMPONE
    SELECT @Precio = SUM(comp_cantidad*dbo.precio_compuesto(comp_componente))
        FROM Composicion
        WHERE comp_producto=@prod_codigo
    
    -- CONDICIÓN DE CORTE 
    IF @Precio is null
	    SET @Precio = (SELECT prod_precio FROM Producto WHERE prod_codigo=@prod_codigo)
	
    RETURN @Precio
END
GO

ALTER PROC EJERCICIO8
AS

    CREATE TABLE Diferencias_Precios (
        dif_prod_codigo NVARCHAR(30) NOT NULL,
        dif_prod_detalle NVARCHAR(255),
        dif_prod_cantidad INT,
        dif_precio_generado DECIMAL(18,2),
        dif_precio_facturado DECIMAL(18,2)
    )
    
    ALTER TABLE Diferencias_Precios ADD CONSTRAINT PK_Diferencias_Precios PRIMARY KEY (dif_prod_codigo)
    
    INSERT INTO Diferencias_Precios 
        SELECT prod_codigo, prod_detalle, count(*), dbo.precio_compuesto(prod_codigo), prod_precio
            FROM Producto JOIN Composicion ON prod_codigo=comp_producto
            GROUP BY prod_codigo, prod_detalle, prod_precio
GO

/* EJERCICIO 10
Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.
*/

ALTER TRIGGER confirmar_borrar ON Producto INSTEAD OF DELETE
AS
    DECLARE @borrado NVARCHAR(30)
    DECLARE borrados CURSOR FOR SELECT prod_codigo FROM deleted

    OPEN borrados

    FETCH NEXT FROM borrados into @borrado

    WHILE @@FETCH_STATUS = 0 
    BEGIN
        IF (SELECT ISNULL(SUM(ISNULL(stoc_cantidad,0)),0) FROM STOCK where stoc_producto = @borrado GROUP BY stoc_producto) <= 0
            DELETE FROM Producto WHERE prod_codigo=@borrado
        ELSE
            RAISERROR('Error al intentar borrar producto %s, aun hay stock del producto.',1,1,@borrado)

        FETCH NEXT FROM borrados into @borrado
	END

    CLOSE borrados
	DEALLOCATE borrados

GO

--PRUEBA QUE FUNCA
--DELETE FROM Producto WHERE prod_codigo = '00000000' 
--SELECT * FROM Producto WHERE prod_codigo = '00000000'

/* EJERCICIO 11
Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo
*/

ALTER FUNCTION cant_empleados (@jefe char(8))
RETURNS INT
BEGIN
    DECLARE @cantidad INT

    SELECT @cantidad = COUNT(*) From Empleado where @jefe = empl_jefe

    IF @cantidad <> 0 (SELECT @cantidad += dbo.cant_empleados(empl_codigo) FROM Empleado where @jefe = empl_jefe)

    RETURN @cantidad
END 
GO
--SELECT COUNT(*) From Empleado where 1 = empl_jefe
SELECT dbo.cant_empleados(empl_codigo) FROM Empleado
GO

/* EJERCICIO 12 (ver ejercicio 25)
Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.
*/

/* EJERCICIO 13
Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
    Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de sus
    empleados totales (directos + indirectos). Se sabe que en la actualidad dicha regla
    se cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos y
    tecnologías*/ 

ALTER FUNCTION sueldo_empleado (@jefe numeric(16,0))
RETURNS DECIMAL(12,2)
BEGIN
    DECLARE @cantidad INT

    SELECT @cantidad = ISNULL(SUM(empl_salario),0) From Empleado where @jefe = empl_jefe

    IF @cantidad <> 0 (SELECT @cantidad += dbo.sueldo_empleado(empl_codigo) FROM Empleado where @jefe = empl_jefe)

    RETURN @cantidad
END
GO

SELECT SUM(empl_salario) from Empleado where empl_jefe is not null
SELECT dbo.sueldo_empleado(empl_codigo) From Empleado where empl_jefe is NULL
GO

CREATE TRIGGER controlar_sueldos ON Empleado INSTEAD OF INSERT, UPDATE
AS
    DECLARE @empl_codigo numeric(6,0), @empl_nombre char(50), @empl_apellido char(50), 
            @empl_nacimiento smalldatetime, @empl_ingreso smalldatetime, @empl_tareas char(100), 
            @empl_salario decimal(12,2), @empl_comision decimal(12,2), @empl_jefe numeric(6,0), 
            @empl_departamento numeric(6,0)
    
    DECLARE cambiados CURSOR FOR SELECT * FROM inserted

    OPEN cambiados

    FETCH NEXT FROM cambiados INTO @empl_codigo, @empl_nombre, @empl_apellido, @empl_nacimiento, 
                                    @empl_ingreso, @empl_tareas, @empl_salario , @empl_comision , @empl_jefe, @empl_departamento 

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- no controlo si son jefes porque si no lo son la funcion retorna 0
        IF @empl_salario < (0.2)*dbo.sueldo_empleados(@empl_codigo)
            BEGIN
                delete from Empleado where empl_codigo = @empl_codigo
                insert into Empleado VALUES(@empl_codigo, @empl_nombre, @empl_apellido, @empl_nacimiento, @empl_ingreso, @empl_tareas, 
                                    @empl_salario, @empl_comision,  @empl_jefe, @empl_departamento)   
            END
        ELSE PRINT 'Sueldo no permitido'

    FETCH NEXT from cambiados INTO @empl_codigo, @empl_nombre, @empl_apellido, @empl_nacimiento, @empl_ingreso, @empl_tareas, 
                                        @empl_salario, @empl_comision,  @empl_jefe, @empl_departamento
    END
    
    CLOSE cambiados
    DEALLOCATE cambiados
GO

/* EJERCICIO 14
Agregar el/los objetos necesarios para que si un cliente compra un producto
compuesto a un precio menor que la suma de los precios de sus componentes
que imprima la fecha, que cliente, que productos y a qué precio se realizó la
compra. No se deberá permitir que dicho precio sea menor a la mitad de la suma
de los componentes.
*/

CREATE TRIGGER corroborar_compras ON Item_Factura FOR INSERT
AS
    DECLARE @producto char(8), @precio decimal(12,2), @cantidad decimal(12,2)
    
    DECLARE compras CURSOR FOR SELECT item_producto, item_precio, item_cantidad FROM inserted

    OPEN compras

    FETCH NEXT FROM compras INTO @producto, @precio, @cantidad

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @precio*@cantidad < dbo.precio_compuesto(@producto)
        BEGIN
            PRINT ('Para el producto el precio es menor que la suma de sus componentes')
            IF @precio*@cantidad < (1/2)*dbo.precio_compuesto(@producto)
                ROLLBACK
        END

        FETCH NEXT FROM compras INTO @producto, @precio, @cantidad
    END

    CLOSE compras
    DEALLOCATE compras
GO

 /* EJERCICIO 15 (VER EJERCICIO 8, ES EL MISMO)
Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. No se
conocen los nivles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
select.
*/

-- ES EL MISMO QUE EL 8
/*
ALTER FUNCTION precio_producto (@producto char(8))
RETURNS DECIMAL(12,2)
BEGIN
    DECLARE @Precio decimal(12,2)
    IF ((SELECT TOP 1 comp_producto FROM Composicion where comp_producto = @producto) is null)
        SET @precio =  ISNULL((SELECT prod_precio from Producto where @producto = prod_codigo),0)
    ELSE
        SET @precio = (SELECT ISNULL(SUM(comp_cantidad*dbo.precio_producto(comp_componente)),0) FROM Composicion where comp_producto = @producto)

    RETURN @Precio
END
GO
*/
--SELECT *, dbo.precio_producto(comp_producto) FROM Composicion
--SELECT comp_producto, comp_componente, comp_cantidad, prod_precio FROM Composicion JOIN Producto on comp_componente = prod_codigo

/* EJERCICIO 16
Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto.
*/
ALTER TRIGGER ej16 ON Item_Factura FOR INSERT
AS
    DECLARE @prod char(8), @cant numeric(6,0)
    DECLARE @comp_cant numeric(6,0), @comp char(8)
    DECLARE ventas CURSOR FOR SELECT item_producto, item_cantidad From Item_Factura

    OPEN ventas

    FETCH NEXT FROM ventas into @prod, @cant

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.disminuir_stock @prod, @cant 
        IF(SELECT COUNT(*) From Composicion where comp_producto = @prod) > 0
            BEGIN
                DECLARE compuestos CURSOR FOR SELECT comp_cantidad, comp_componente From Composicion where comp_producto = @prod
                
                OPEN compuestos
                FETCH NEXT FROM compuestos into @comp_cant, @comp

                WHILE @@FETCH_STATUS = 0
                BEGIN
                    EXEC dbo.disminuir_stock @comp, @comp_cant
                    FETCH NEXT FROM compuestos into @comp_cant, @comp
                END

                CLOSE compuestos
                DEALLOCATE compuestos
            END
        FETCH NEXT FROM ventas into @prod, @cant
    END

    CLOSE ventas
    DEALLOCATE ventas
GO


ALTER PROC disminuir_stock(@prod char(8), @cant int)
AS
    DECLARE @d char(2) = (SELECT top 1 stoc_deposito FROM STOCK 
                            WHERE @prod = stoc_producto and stoc_cantidad - @cant > 0 
                            ORDER BY stoc_cantidad - @cant)
    
    DECLARE @depositos TABLE (codigo char(2), cantidad int)

    INSERT INTO @depositos SELECT stoc_deposito, stoc_cantidad FROM STOCK 
                            WHERE @prod = stoc_producto and stoc_cantidad - @cant > 0 
                            ORDER BY (stoc_cantidad - @cant)
    
    DECLARE @code char(2), @stock int
    DECLARE analisis_depositos CURSOR FOR SELECT * FROM @depositos
    OPEN analisis_depositos

    FETCH NEXT FROM analisis_depositos INTO @code, @stock

    DECLARE @cantidad_requerida int = @cant

    WHILE @@FETCH_STATUS = 0 AND @cantidad_requerida > 0
    BEGIN
        if (@stock - @cantidad_requerida > 0)
            BEGIN
                UPDATE STOCK SET stoc_cantidad -= @cantidad_requerida where @code = stoc_deposito
                SET @cantidad_requerida = 0
            END
        ELSE
            BEGIN
                if (@stock > 0) UPDATE STOCK SET stoc_cantidad = 0 where @code = stoc_deposito
                SET @cantidad_requerida -= @stock
            END

        FETCH NEXT FROM analisis_depositos INTO @code, @stock
    END

    IF (@cantidad_requerida > 0)
        UPDATE STOCK SET stoc_cantidad -= @cantidad_requerida where @code = stoc_deposito
    
    CLOSE analisis_depositos
    DEALLOCATE analisis_depositos
GO

SELECT stoc_deposito, stoc_cantidad FROM Producto JOIN STOCK ON stoc_producto = prod_codigo WHERE prod_codigo = 00000030

EXEC dbo.disminuir_stock 00000030, 5
go

/* EJERCICIO 17 
Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock
*/

ALTER TRIGGER ej17 ON Stock INSTEAD OF UPDATE
AS
    DECLARE @stoc_nuevo decimal(12,2), @producto char(8), @deposito char(2)
    DECLARE actualizaciones CURSOR FOR SELECT stoc_cantidad,stoc_producto, stoc_deposito FROM inserted

    OPEN actualizaciones

    FETCH NEXT FROM actualizaciones INTO @stoc_nuevo, @producto, @deposito

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@stoc_nuevo <= (SELECT stoc_stock_maximo FROM STOCK where stoc_producto = @producto and stoc_deposito = @deposito)
            AND @stoc_nuevo >= (SELECT stoc_punto_reposicion FROM STOCK where stoc_producto = @producto and stoc_deposito = @deposito))
            
            UPDATE STOCK SET stoc_cantidad = @stoc_nuevo WHERE stoc_producto = @producto and stoc_deposito = @deposito
        ELSE
            PRINT 'No se actualizó ya que superó el mínimo o el máximo establecido'

        FETCH NEXT FROM actualizaciones INTO @stoc_nuevo, @producto, @deposito
    END

    CLOSE actualizaciones
    DEALLOCATE actualizaciones
GO

SELECT * FROM Stock WHERE stoc_producto = '00000030' and stoc_deposito = '00'
UPDATE STOCK SET stoc_cantidad = 2 WHERE stoc_producto = '00000030' and stoc_deposito = '00'
GO
/* EJERCICIO 18
Sabiendo que el limite de credito de un cliente es el monto maximo que se le
puede facturar mensualmente, cree el/los objetos de base de datos necesarios
para que dicha regla de negocio se cumpla automaticamente. No se conoce la
forma de acceso a los datos ni el procedimiento por el cual se emiten las facturas
*/

ALTER TRIGGER ej18 ON Factura FOR INSERT
AS
    IF EXISTS(SELECT clie_codigo 
                FROM inserted 
                JOIN Cliente on clie_codigo = fact_cliente
                GROUP BY clie_codigo, clie_limite_credito
                HAVING clie_limite_credito < SUM(fact_total))
        BEGIN
        PRINT 'SUPERASTE EL LIMITE DE CREDITO'
        ROLLBACK
        END
GO
INSERT INTO Factura VALUES ('A','casa','900000',getdate(),6,10000000,15,'00000')
GO
    --DECLARE @cliente char(6)
    --DECLARE @facturado DECIMAL(12,2)
    --DECLARE insertados CURSOR FOR SELECT fact_cliente, fact_total FROM inserted


    /*
    OPEN insertados

    FETCH NEXT FROM insertados into @cliente, @facturado

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (SELECT clie_limite_credito FROM Cliente WHERE clie_codigo = @cliente) < 
                (SELECT SUM(fact_total) FROM Factura WHERE fact_cliente = @cliente) + @facturado
            ROLLBACK

        FETCH NEXT FROM insertados into @cliente, @facturado
    END

    CLOSE insertados
    DEALLOCATE insertados
    */

/* EJERCICIO 19
Cree el/los objetos de base de datos necesarios para que se cumpla la siguiente
regla de negocio automáticamente “Ningún jefe puede tener menos de 5 años de
antigüedad y tampoco puede tener más del 50% del personal a su cargo
(contando directos e indirectos) a excepción del gerente general”. Se sabe que en
la actualidad la regla se cumple y existe un único gerente general.
*/

CREATE TRIGGER ej19 ON Empleado FOR INSERT
AS
    DECLARE @jefe char(8)
    DECLARE insertados CURSOR FOR SELECT empl_jefe FROM inserted

    OPEN insertados

    FETCH NEXT INTO @jefe

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (YEAR(getdate()) - (SELECT YEAR(empl_ingreso) FROM Empleado where empl_codigo = @jefe) <= 5) 
                    AND (SELECT COUNT(*) FROM Empleado where empl_jefe = @jefe) / (SELECT COUNT(*) FROM Empleado) > 0.5
                    AND @jefe <> (SELECT empl_codigo FROM Empleado where empl_jefe is null)
            ROLLBACK

        FETCH NEXT INTO @jefe
    END

    CLOSE insertados
    DEALLOCATE insertados
GO

/* EJERCICIO 20
Crear el/los objeto/s necesarios para mantener actualizadas las comisiones del
vendedor.
El cálculo de la comisión está dado por el 5% de la venta total efectuada por ese
vendedor en ese mes, más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.
*/

ALTER TRIGGER ej20 ON Factura FOR INSERT, UPDATE
AS
    DECLARE @comision DECIMAL(18,2)
    DECLARE @vendedor char(8)
    DECLARE vendedores CURSOR FOR SELECT DISTINCT fact_vendedor FROM inserted

    OPEN vendedores

    FETCH NEXT INTO @vendedor

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @comision = (1/20)*(SELECT SUM(fact_total) From Factura where fact_vendedor = @vendedor and MONTH(fact_fecha) = MONTH(getdate()))
        IF 50 < (SELECT COUNT(DISTINCT item_producto) From Factura 
                    JOIN Item_Factura on item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo 
                    where fact_vendedor = @vendedor and MONTH(fact_fecha) = MONTH(getdate())) 
            SET @comision*=1.03
        UPDATE Empleado SET @comision = empl_comision WHERE empl_codigo = @vendedor
        FETCH NEXT INTO @vendedor
    END

    CLOSE vendedores
    DEALLOCATE vendedores
GO

ALTER TRIGGER ej20v2 ON Factura FOR INSERT, UPDATE
AS
    UPDATE Empleado SET empl_comision = (1/20)*(SELECT SUM(fact_total) 
                                                From Factura 
                                                where fact_vendedor = empl_codigo and MONTH(fact_fecha) = MONTH(getdate()))
                                        *CASE 
                                            WHEN 50 < (SELECT COUNT(DISTINCT item_producto) From Factura 
                                                            JOIN Item_Factura on item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo 
                                                            where fact_vendedor = empl_codigo and MONTH(fact_fecha) = MONTH(getdate()))
                                                THEN 1.03
                                            ELSE 1
                                        END
                    WHERE empl_codigo in (SELECT fact_vendedor FROM inserted)
GO

/* EJERCICIO 21
Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.
*/

ALTER TRIGGER ej21 ON Item_Factura FOR INSERT
AS
    IF (SELECT COUNT(*) 
        FROM (inserted i1 JOIN Producto p1 on i1.item_producto = p1.prod_codigo) 
        JOIN (inserted i2 JOIN Producto p2 on i2.item_producto = p2.prod_codigo) 
            ON i1.item_numero=i2.item_numero 
                AND p1.prod_familia <> p2.prod_familia
                AND i1.item_producto > i2.item_producto
        GROUP BY i1.item_numero, p1.prod_familia, p2.prod_familia) <> 0
        
        BEGIN
            ROLLBACK
            RAISERROR('Hay facturas con items de distinta familia',1,1)
        END
GO

CREATE TRIGGER ej21v2 ON Item_Factura FOR INSERT
AS
    IF 0 < (SELECT COUNT(*) 
            FROM inserted
            JOIN Producto p1 on item_producto = p1.prod_codigo
            WHERE (SELECT COUNT(prod_familia) 
                    FROM inserted i
                    JOIN Producto on i.item_producto = p1.prod_codigo
                    where i.item_numero+i.item_sucursal+i.item_tipo = item_numero+item_sucursal+item_tipo
                    ) > 1)
        BEGIN
            ROLLBACK
            RAISERROR('Hay facturas con items de distinta familia',1,1)
        END
GO

/* EJERCICIO 22
Se requiere recategorizar los rubros de productos, de forma tal que nigun rubro
tenga más de 20 productos asignados, si un rubro tiene más de 20 productos
asignados se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada.
*/
CREATE PROC dbo.Ejercicio22
AS
BEGIN
	declare @rubro char(4)
	declare @cantProdRubro int

	declare cursor_rubro CURSOR FOR SELECT R.rubr_id,COUNT(*) FROM rubro R
									INNER JOIN Producto P ON P.prod_rubro = R.rubr_id
									GROUP BY R.rubr_id
									HAVING COUNT(*) > 20
	OPEN cursor_rubro
	FETCH NEXT FROM cursor_rubro
	INTO @rubro,@cantProdRubro
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @cantProdRubroIndividual int = @cantProdRubro
		declare @prodCod char(8)
		declare @rubroLibre char(4)
		declare cursor_productos CURSOR FOR SELECT prod_codigo
											FROM Producto
											WHERE prod_rubro = @rubro
		OPEN cursor_productos
		FETCH NEXT FROM cursor_productos
		INTO @prodCod
		WHILE @@FETCH_STATUS = 0 OR @cantProdRubroIndividual < 21
		BEGIN
			IF EXISTS(
						SELECT TOP 1 rubr_id
						FROM Rubro
							INNER JOIN Producto
								ON prod_rubro = rubr_id
						GROUP BY rubr_id
						HAVING COUNT(*) < 20
						ORDER BY COUNT(*) ASC
						)
			BEGIN
				SET @rubroLibre = (
									SELECT TOP 1 rubr_id
									FROM Rubro
										INNER JOIN Producto
											ON prod_rubro = rubr_id
									GROUP BY rubr_id
									HAVING COUNT(*) < 20
									ORDER BY COUNT(*) ASC
									)

				UPDATE Producto SET prod_rubro = @rubroLibre WHERE prod_codigo = @prodCod
			END
			ELSE
			BEGIN
				IF NOT EXISTS(
						SELECT rubr_id
						FROM Rubro
						WHERE rubr_detalle = 'Rubro reasignado'
						)  
				INSERT INTO Rubro (RUBR_ID,rubr_detalle) VALUES ('xx','Rubro reasignado')
				UPDATE Producto set prod_rubro = (
													SELECT rubr_id
													FROM Rubro
													WHERE rubr_detalle = 'Rubro reasignado'
												)
				WHERE prod_codigo = @prodCod
			END
			SET @cantProdRubroIndividual -= 1
		FETCH NEXT FROM cursor_productos
		INTO @prodCod
		END
		CLOSE cursor_productos
		DEALLOCATE cursor_productos
	FETCH NEXT FROM cursor_rubro
	INTO @rubro,@cantProdRubro
	END
	CLOSE cursor_rubro
	DEALLOCATE cursor_productos
END
GO

/*
select R.rubr_detalle,COUNT(*)
from rubro R
	INNER JOIN Producto P
		ON P.prod_rubro = R.rubr_id
GROUP BY R.rubr_detalle

select prod_detalle,fami_detalle,rubr_detalle 
from Producto
	inner join Familia
		on fami_id = prod_familia
	INNER JOIN Rubro
		on rubr_id = prod_rubro


SELECT prod_codigo 
FROM Producto 
WHERE prod_rubro IN (SELECT rubr_id 
					FROM Rubro 
						JOIN Producto 
							ON rubr_id = prod_rubro 
					GROUP BY rubr_id
					HAVING COUNT(prod_rubro) > 20)

					*/
/* EJERCICIO 24
Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resueva, teniendo en
cuenta que un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, si
esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.
*/

--UN EMPLEADO TIENE UN DEPARTAMENTO Y UN DEPARTAMENTO TIENE UNA ZONA
--UN DEPOSITO TIENE UNA ZONA

CREATE PROC ej24
AS
    DECLARE @depo_codigo char(2), @depo_encargado numeric(6,0), @depo_zona char(3)
    DECLARE depositos CURSOR FOR SELECT depo_codigo, depo_encargado, depo_zona from Deposito

    OPEN depositos

    FETCH NEXT FROM depositos INTO @depo_codigo, @depo_encargado, @depo_zona

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @depo_zona <> (SELECT depa_zona
                            FROM Empleado
                            JOIN Departamento on empl_departamento = depa_codigo
                            WHERE empl_codigo = @depo_encargado)
            
            UPDATE Deposito SET depo_encargado = (SELECT TOP 1 empl_codigo
                                                    FROM Empleado
                                                    JOIN Departamento on empl_departamento = depa_codigo
                                                    JOIN Deposito ON depo_encargado = empl_codigo
                                                    WHERE @depo_zona = depa_zona
                                                    GROUP BY empl_codigo
                                                    ORDER BY COUNT(depo_codigo) asc)
                            WHERE depo_codigo = @depo_codigo
        FETCH NEXT FROM depositos INTO @depo_codigo, @depo_encargado, @depo_zona
    END

    CLOSE depositos
    DEALLOCATE depositos
GO

EXEC dbo.ej24
GO

CREATE PROC ej24v2
AS
    UPDATE Deposito SET depo_encargado = (SELECT TOP 1 empl_codigo FROM Empleado 
                                            JOIN Departamento dep on depa_codigo = empl_departamento
                                            JOIN Deposito depo ON depo.depo_encargado = empl_codigo
                                            WHERE depa_zona = depo_zona
                                            GROUP BY empl_codigo
                                            ORDER BY COUNT(depo.depo_codigo) asc)
                    WHERE depo_zona <> (SELECT depa_zona 
                                            FROM Empleado 
                                            JOIN Departamento on empl_departamento = depa_codigo
                                            WHERE empl_codigo = depo_encargado)
GO

EXEC dbo.ej24v2
GO

/* EJERCICIO 25 (ES IGUAL AL 12) */
ALTER FUNCTION composicion_recursiva(@producto char(8), @componente char(8))
RETURNS INT
BEGIN
    IF (@producto = @componente) RETURN 1
    ELSE
        BEGIN
            IF (1 = ANY(SELECT dbo.composicion_recursiva(@producto,comp_componente) 
                        From Composicion 
                        where comp_producto = @componente)) RETURN 1
            ELSE RETURN 0
        END
    RETURN 0
END
GO

ALTER TRIGGER ej25conFOR ON Composicion FOR INSERT, UPDATE
AS
    IF 1 = ANY (SELECT dbo.composicion_recursiva(comp_producto,comp_componente) FROM inserted)
    BEGIN
        PRINT 'Productos ingresados se componen a si mismo'
        ROLLBACK
    END
GO

ALTER TRIGGER ej25conINSTEADOF ON Composicion INSTEAD OF INSERT, UPDATE
AS
    IF ((SELECT COUNT(*) FROM deleted) = 0)
        INSERT INTO Composicion SELECT * FROM inserted WHERE dbo.composicion_recursiva(comp_producto,comp_componente) = 0
    ELSE 
        BEGIN
        DECLARE @prod char(8), @comp char(8), @cant decimal(12,2)
        DECLARE @prod_del char(8), @comp_del char(8), @cant_del decimal(12,2)
        
        DECLARE nuevos CURSOR FOR SELECT comp_producto, comp_componente, comp_cantidad FROM inserted
        DECLARE viejos CURSOR FOR SELECT comp_producto, comp_componente, comp_cantidad FROM deleted

        OPEN nuevos
        OPEN viejos

        FETCH NEXT FROM nuevos INTO @prod, @comp, @cant
        FETCH NEXT FROM viejos INTO @prod_del, @comp_del, @cant_del

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (dbo.composicion_recursiva(@prod, @comp) = 1)
                PRINT 'No puede ingresarse porque se compone a si mismo'
            ELSE
                BEGIN
                    DELETE FROM Composicion WHERE @prod = @prod_del AND @comp = @comp_del
                    INSERT INTO Composicion VALUES(@prod, @comp, @cant)
                END
        END

        CLOSE nuevos
        CLOSE viejos
        DEALLOCATE nuevos
        DEALLOCATE viejos
        END
GO

SELECT * FROM Composicion
INSERT INTO Composicion VALUES (3,'00001109','00001104')
DELETE FROM Composicion where comp_producto = '00001109'
SELECT comp_producto, comp_componente, dbo.composicion_recursiva(comp_producto,comp_componente) From Composicion
GO
/* EJERCICIO 27
Se requiere reasignar los encargados de stock de los diferentes depósitos. Para
ello se solicita que realice el o los objetos de base de datos necesarios para
asignar a cada uno de los depósitos el encargado que le corresponda,
entendiendo que el encargado que le corresponde es cualquier empleado que no
es jefe y que no es vendedor, o sea, que no está asignado a ningun cliente, se
deberán ir asignando tratando de que un empleado solo tenga un deposito
asignado, en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado.
*/

ALTER PROC ej27
AS
    DECLARE @empleados TABLE (codigo numeric(6,0))
    
    DECLARE @empleado numeric(6,0), @deposito char(2)

    INSERT INTO @empleados SELECT empl_codigo 
                                FROM Empleado
                                WHERE empl_codigo not in (SELECT DISTINCT empl_jefe FROM Empleado WHERE empl_jefe is not null)
                                AND empl_codigo not in (SELECT DISTINCT fact_vendedor From Factura)
    DECLARE empleados CURSOR FOR SELECT * FROM @empleados
    DECLARE depositos CURSOR FOR SELECT depo_encargado FROM Deposito

    OPEN empleados
    OPEN depositos

    FETCH NEXT FROM empleados INTO @empleado
    FETCH NEXT FROM depositos INTO @deposito

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        UPDATE Deposito SET depo_encargado = @empleado where depo_codigo = @deposito

        FETCH NEXT FROM empleados INTO @empleado

        IF (@@FETCH_STATUS = 0)
            BEGIN
                CLOSE empleados
                OPEN empleados
                FETCH NEXT FROM empleados INTO @empleado
            END
        
        FETCH NEXT FROM depositos INTO @deposito
            
    END
GO

/* EJERCICIO 28 --PROBADO
Se requiere reasignar los vendedores a los clientes. Para ello se solicita que
realice el o los objetos de base de datos necesarios para asignar a cada uno de los
clientes el vendedor que le corresponda, entendiendo que el vendedor que le
corresponde es aquel que le vendió más facturas a ese cliente, si en particular un
cliente no tiene facturas compradas se le deberá asignar el vendedor con más
venta de la empresa, o sea, el que en monto haya vendido más.
*/

ALTER PROC ej28 
AS
    UPDATE Cliente SET clie_vendedor = CASE WHEN (SELECT COUNT(*) FROM Factura WHERE clie_codigo = fact_cliente) = 0 
                                                    THEN (SELECT TOP 1 fact_vendedor 
                                                            FROM Factura 
                                                            GROUP BY fact_vendedor 
                                                            ORDER BY SUM(fact_total) DESC)
                                            ELSE (SELECT top 1 fact_vendedor FROM Factura 
                                                    WHERE clie_codigo = fact_cliente 
                                                    GROUP BY fact_vendedor, fact_cliente 
                                                    ORDER BY SUM(fact_total) DESC)
                                            END
GO

/* EJERCICIO 29 
Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de diferentes productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/

CREATE TRIGGER [dbo].[ej29] ON [dbo].[Item_Factura] FOR INSERT
AS
    IF (SELECT COUNT(*) FROM (inserted i1 JOIN Composicion c1 on i1.item_producto = c1.comp_componente) 
        JOIN (inserted i2 JOIN Composicion c2 on i2.item_producto = c2.comp_componente) 
        ON i1.item_numero=i2.item_numero AND c1.comp_producto <> c2.comp_producto) <> 0
        
        BEGIN
			--NO PUSE EL ROLLBACK PORQUE
            DELETE FROM Item_Factura where item_numero in (SELECT item_numero FROM inserted)
			DELETE FROM Factura where fact_numero in (SELECT item_numero FROM inserted)
			--DELETE FROM Item_Factura where item_numero in (SELECT item_numero FROM inserted)
            RAISERROR('Hay facturas con items de distinta familia',1,1)
        END
go

SELECT * FROM Composicion
INSERT INTO Factura VALUES ('A','casa','900000',getdate(),6,100,15,'00000')

INSERT INTO Item_Factura
	VALUES ('A','casa','900000','00001491',10,1), ('A','casa','900000','00001516',10,1)

SELECT * FROM Factura where fact_sucursal = 'casa'
SELECT * FROM Item_Factura where item_sucursal = 'casa'

DELETE FROM Item_Factura where item_sucursal = 'casa'
DELETE FROM Factura where fact_sucursal = 'casa'

SELECT i1.item_numero, i2.item_numero, i1.item_producto, i2.item_producto, COUNT(*) 
FROM (Item_Factura i1 JOIN Composicion c1 on i1.item_producto = c1.comp_componente) 
JOIN (Item_Factura i2 JOIN Composicion c2 on i2.item_producto = c2.comp_componente) 
    ON i1.item_numero=i2.item_numero AND c1.comp_producto <> c2.comp_producto AND i1.item_producto > i2.item_producto 
GROUP BY i1.item_numero, i2.item_numero, i1.item_producto, i2.item_producto
GO
/* EJERCICIO 30 --PROBADO
Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.
*/

ALTER TRIGGER ej30 ON Item_Factura FOR INSERT
AS
    DECLARE @numero char(8), @sucursal char(4), @tipo char(1), @cliente char(6)
    DECLARE items CURSOR FOR SELECT item_numero, item_sucursal, item_tipo, fact_cliente 
                                FROM inserted
                                JOIN Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo

    OPEN items

    FETCH NEXT FROM items INTO @numero, @sucursal, @tipo, @cliente 

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (SELECT SUM(item_cantidad) 
                From Item_Factura 
                JOIN Factura on item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
                WHERE fact_numero+fact_sucursal+fact_tipo = @numero+@sucursal+@tipo AND fact_cliente = @cliente) > 100
            
            BEGIN
                ROLLBACK
                DELETE FROM Factura where fact_numero+fact_sucursal+fact_tipo = @numero+@sucursal+@tipo
                RAISERROR('Se ha superado el límite máximo de compra de un producto',1,1)
            END

        FETCH NEXT FROM items INTO @numero, @sucursal, @tipo, @cliente
    END

    CLOSE items
    DEALLOCATE items
GO
--PRUEBAS
INSERT INTO Factura
	(fact_tipo,fact_sucursal,fact_numero,fact_fecha,fact_vendedor,fact_total,fact_total_impuestos,fact_cliente)
	VALUES
	('A','casa','900000',getdate(),6,100,15,'00000')

INSERT INTO Item_Factura
	VALUES ('A','casa','900000','00000102',10,1), ('A','casa','900000','00000103',100000,1), ('A','casa','900000','00000104',10,1)

SELECT * FROM Factura where fact_sucursal = 'casa'
SELECT * FROM Item_Factura where item_sucursal = 'casa'

DELETE FROM Item_Factura where item_sucursal = 'casa'
DELETE FROM Factura where fact_sucursal = 'casa'
GO
/* EJERCICI0 31--PROBADO
Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
tener más de 20 empleados a cargo, directa o indirectamente, si esto ocurre
debera asignarsele un jefe que cumpla esa condición, si no existe un jefe para
asignarle se le deberá colocar como jefe al gerente general que es aquel que no
tiene jefe.
*/

ALTER TRIGGER ej31 ON Empleado INSTEAD OF INSERT, UPDATE
AS
    DECLARE @empl_codigo numeric(6,0), @empl_nombre char(50), @empl_apellido char(50), 
            @empl_nacimiento smalldatetime, @empl_ingreso smalldatetime, @empl_tareas char(100), 
            @empl_salario decimal(12,2), @empl_comision decimal(12,2), @empl_jefe numeric(6,0), 
            @empl_departamento numeric(6,0), @jefe2 numeric(6,0) = null
    
    DECLARE insertados CURSOR FOR SELECT * FROM inserted

    OPEN insertados

    FETCH NEXT from insertados INTO @empl_codigo, @empl_nombre, @empl_apellido, @empl_nacimiento, @empl_ingreso, @empl_tareas, 
                                    @empl_salario, @empl_comision,  @empl_jefe, @empl_departamento    

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF dbo.cant_empleados(@empl_jefe) > 20
            BEGIN
                SELECT TOP 1 @empl_jefe = empl_codigo From Empleado WHERE dbo.cant_empleados(empl_codigo) < 20 AND dbo.cant_empleados(empl_codigo) > 0 AND empl_jefe is not null

                IF (@empl_jefe is null) 
                    SELECT @empl_jefe = empl_codigo From Empleado WHERE empl_jefe is null
            END

        delete from Empleado where empl_codigo = @empl_codigo
        insert into Empleado VALUES(@empl_codigo, @empl_nombre, @empl_apellido, @empl_nacimiento, @empl_ingreso, @empl_tareas, 
                                    @empl_salario, @empl_comision,  @empl_jefe, @empl_departamento)

        FETCH NEXT from insertados INTO @empl_codigo, @empl_nombre, @empl_apellido, @empl_nacimiento, @empl_ingreso, @empl_tareas, 
                                        @empl_salario, @empl_comision,  @empl_jefe, @empl_departamento  
    END

    CLOSE insertados
    DEALLOCATE insertados
GO
--PRUEBA
insert into Empleado VALUES(123,'a','a', getdate(),getdate(),'AARM', 1000,1000,3,1)
SELECT * FROM Empleado
DELETE FROM Empleado where empl_codigo = 123