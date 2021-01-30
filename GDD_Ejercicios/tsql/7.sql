CREATE PROC P7 @start_date SMALLDATETIME, @end_date SMALLDATETIME AS
BEGIN
    DECLARE @ventas TABLE
                    (
                        codigo           CHAR(6),
                        detalle          CHAR(50),
                        cant_movimientos NUMERIC(6),
                        precio_venta     DECIMAL(12, 2),
                        renglon          NUMERIC(6),
                        ganancia         DECIMAL(12, 2)
                    );
    DECLARE @codigo CHAR(6);
    DECLARE @detalle CHAR(50);
    DECLARE @cant_movimientos NUMERIC(6);
    DECLARE @precio_venta DECIMAL(12, 2);
    DECLARE @renglon NUMERIC(6) = 0;
    DECLARE @ganancia DECIMAL(12, 2);

    DECLARE cVentas CURSOR FOR SELECT prod_codigo,
                                      prod_detalle,
                                      COUNT(item_numero),
                                      AVG(item_precio),
                                      SUM(item_cantidad * item_precio) - SUM(prod_precio * item_cantidad)
                               FROM Item_Factura I
                                        JOIN Producto P ON I.item_producto = P.prod_codigo
                                        JOIN Factura F
                                             ON I.item_tipo = F.fact_tipo AND I.item_sucursal = F.fact_sucursal AND
                                                I.item_numero = F.fact_numero
                               WHERE F.fact_fecha BETWEEN @start_date AND @end_date
                               GROUP BY prod_codigo, prod_detalle

    OPEN cVentas
    FETCH NEXT FROM cVentas INTO @codigo, @detalle, @cant_movimientos, @precio_venta, @ganancia

    WHILE @@FETCH_STATUS = 0 BEGIN
        INSERT INTO @ventas VALUES (@codigo, @detalle, @cant_movimientos, @precio_venta, @renglon, @ganancia)
        SET @renglon = @renglon + 1
        FETCH NEXT FROM cVentas INTO @codigo, @detalle, @cant_movimientos, @precio_venta, @ganancia
    END;

    CLOSE cVentas
    DEALLOCATE cVentas

END;