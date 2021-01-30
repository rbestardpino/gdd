CREATE FUNCTION F2(@prod_codigo CHAR(8), @date SMALLDATETIME) RETURNS INT
BEGIN
    RETURN ISNULL(
                (
                    SELECT SUM(stoc_cantidad)
                    FROM STOCK
                    WHERE @prod_codigo = stoc_producto
                ) + (
                    SELECT SUM(item_cantidad)
                    FROM Item_Factura
                             JOIN Factura
                                  ON fact_numero + fact_tipo + fact_sucursal = item_numero + item_tipo + item_sucursal
                    WHERE item_producto = @prod_codigo
                      AND fact_fecha > @date
                ),
                0
        )
END;