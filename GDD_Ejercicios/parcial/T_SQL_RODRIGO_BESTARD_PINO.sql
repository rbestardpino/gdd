-- Armar un procedimiento almacenado que actualice todos los precios
-- donde se vendió una composición y la sumatoria de los productos con los componentes,
-- no da el precio unitario de la venta realizada. Ademas, debera actualizar todas las
-- tablas correspondientes del modelo para que quede la lógica consistente. La diferencia
-- actualizada, deberá acumularse en una nueva tabla que aun no existe llamada diferencias,
-- donde se debe registrar cliente, anio, diferencias_acumuladas.

CREATE PROC ACTUALIZAR_PRECIOS AS
BEGIN
    DECLARE @diferencias TABLE
                         (
                             cliente                CHAR(6),
                             anio                   INTEGER,
                             diferencias_acumuladas DECIMAL(12, 2)
                         );
    DECLARE @cliente CHAR(6);
    DECLARE @anio INTEGER;
    DECLARE @producto CHAR(8);
    DECLARE @fact_total DECIMAL(12, 2);
    DECLARE @fact_numero CHAR(8);
    DECLARE @diferencia DECIMAL(12, 2);
    DECLARE @precio_compuesto DECIMAL(12, 2);

    DECLARE cDiferencias CURSOR FOR SELECT F.fact_cliente,
                                           YEAR(F.fact_fecha),
                                           I.item_producto,
                                           F.fact_total,
                                           F.fact_numero
                                    FROM Factura F
                                             JOIN Item_Factura I ON F.fact_tipo = I.item_tipo AND
                                                                    F.fact_sucursal = I.item_sucursal AND
                                                                    F.fact_numero = I.item_numero
                                    WHERE item_producto IN (SELECT comp_producto FROM Composicion)

    OPEN cDiferencias
    FETCH NEXT FROM cDiferencias INTO @cliente, @anio, @producto, @fact_total, @fact_numero

    WHILE @@FETCH_STATUS = 0 BEGIN
        SET @precio_compuesto = dbo.PRECIO_COMPUESTO(@producto)
        SET @diferencia = (@precio_compuesto - @fact_total)
        IF @diferencia > 0
            BEGIN
                UPDATE Factura SET fact_total = @precio_compuesto WHERE fact_numero = @fact_numero

                IF EXISTS(SELECT cliente FROM @diferencias WHERE cliente = @cliente AND anio = @anio)
                    UPDATE @diferencias
                    SET diferencias_acumuladas = diferencias_acumuladas + @diferencia
                ELSE
                    INSERT INTO @diferencias VALUES (@cliente, @anio, @diferencia)
            END

        FETCH NEXT FROM cDiferencias INTO @cliente, @anio, @producto, @fact_total, @fact_numero
    END

    CLOSE cDiferencias
    DEALLOCATE cDiferencias
END;

    CREATE FUNCTION PRECIO_COMPUESTO(@prod_codigo CHAR(8)) RETURNS DECIMAL(12, 2)
    BEGIN
        RETURN CASE
                   WHEN @prod_codigo IN (SELECT comp_producto FROM Composicion) THEN ISNULL(
                           (SELECT SUM(dbo.F8(comp_componente) * comp_cantidad)
                            FROM Composicion
                            WHERE comp_producto = @prod_codigo), 0)
                   ELSE (SELECT prod_precio FROM Producto WHERE prod_codigo = @prod_codigo)
            END;
    END;

