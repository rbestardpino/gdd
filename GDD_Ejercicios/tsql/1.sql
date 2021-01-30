CREATE FUNCTION F1(@prod_codigo CHAR(8), @depo_codigo CHAR(2)) RETURNS VARCHAR(100)
BEGIN
    DECLARE
        @cant_en_depo INT,
        @max_stock INT,
        @estado VARCHAR(100);

    SELECT @cant_en_depo = ISNULL(stoc_cantidad, 0),
           @max_stock = ISNULL(stoc_stock_maximo, 0)
    FROM STOCK
    WHERE stoc_producto = @prod_codigo
      AND stoc_deposito = @depo_codigo;

    IF (@cant_en_depo < @max_stock)
        SET
            @estado = 'OCUPACION DEL DEPOSITO ' + CASE
                                                      WHEN @max_stock = 0 THEN '0%'
                                                      ELSE STR(CEILING(@cant_en_depo * 100 / @max_stock)) + '%'
                END
    ELSE
        SET
            @estado = 'DEPOSITO COMPLETO'
    RETURN @estado;

END;