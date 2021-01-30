CREATE TRIGGER T10
    ON Producto
    INSTEAD OF DELETE AS
BEGIN
    DECLARE @prod_codigo CHAR(8)

    DECLARE pCursor CURSOR FOR SELECT D.prod_codigo FROM deleted D

    OPEN pCursor

    FETCH NEXT FROM pCursor INTO @prod_codigo

    WHILE @@FETCH_STATUS = 0 BEGIN
        IF (SELECT SUM(stoc_cantidad) FROM STOCK WHERE @prod_codigo = stoc_producto) <= 0
            DELETE FROM Producto WHERE prod_codigo = @prod_codigo
        ELSE
            RAISERROR ('EL PRODUCTO TODAVIA TIENE STOCK MAMARRACHO',1,1)

        FETCH NEXT FROM pCursor INTO @prod_codigo
    END;

    CLOSE pCursor
    DEALLOCATE pCursor
END;

DELETE
FROM Producto
WHERE prod_codigo = '00000102';

SELECT *
FROM Producto
WHERE prod_codigo = '00000102';

SELECT *
FROM STOCK
WHERE stoc_producto = '00000102';