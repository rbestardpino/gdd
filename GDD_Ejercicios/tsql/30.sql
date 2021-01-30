CREATE TRIGGER T30
    ON Item_Factura
    FOR INSERT AS
BEGIN
    DECLARE @cliente CHAR(6)
    DECLARE @producto CHAR(8)
    DECLARE @fact_numero CHAR(8)

    DECLARE cItem CURSOR FOR SELECT F.fact_cliente, I.item_producto, F.fact_numero
                             FROM inserted I
                                      JOIN Factura F ON I.item_numero = F.fact_numero AND I.item_tipo = F.fact_tipo AND
                                                        I.item_sucursal = F.fact_sucursal;

    FETCH NEXT FROM cItem INTO @cliente, @producto, @fact_numero

    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (SELECT SUM(I.item_cantidad)
                FROM Item_Factura I
                         JOIN Factura F2 ON F2.fact_tipo = I.item_tipo AND F2.fact_sucursal = I.item_sucursal AND
                                            F2.fact_numero = I.item_numero
                WHERE I.item_producto = @producto
                  AND F2.fact_cliente = @cliente
                  AND YEAR(F2.fact_fecha) = (
                    SELECT MAX(YEAR(F3.fact_fecha))
                    FROM Factura F3
                )
                  AND MONTH(F2.fact_fecha) =
                      (SELECT MONTH(F4.fact_fecha) FROM Factura F4 WHERE YEAR(F4.fact_fecha) = YEAR(F2.fact_fecha))) >
               100
                BEGIN
                    ROLLBACK
                    DELETE
                    FROM Factura
                    WHERE fact_numero = @fact_numero
                    RAISERROR ('YA COMPRASTE MAS DE 100 PRODUCTOS IGUALES EN EL ULTIMO MES',1,1)
                END

            FETCH NEXT FROM cItem INTO @cliente, @producto, @fact_numero
        END

    CLOSE cItem
    DEALLOCATE cItem
END;