CREATE PROC P8 AS
BEGIN
    DECLARE @diferencias TABLE
                         (
                             codigo           INT,
                             detalle          VARCHAR(50),
                             cantidad         INT,
                             precio_generado  FLOAT,
                             precio_facturado FLOAT
                         )
    DECLARE @codigo INT
    DECLARE @detalle VARCHAR(50)
    DECLARE @cantidad INT
    DECLARE @precio_generado FLOAT
    DECLARE @precio_facturado FLOAT

    INSERT INTO @diferencias
    SELECT P.prod_codigo, P.prod_detalle, COUNT(DISTINCT C.comp_componente), dbo.F8(P.prod_codigo), I.item_precio
    FROM Producto P
             JOIN Composicion C ON P.prod_codigo = C.comp_componente
             JOIN Item_Factura I ON P.prod_codigo = I.item_producto

    ALTER FUNCTION F8(@prod_codigo CHAR(8)) RETURNS DECIMAL(12, 2)
        BEGIN
            RETURN CASE
                       WHEN @prod_codigo IN (SELECT comp_producto FROM Composicion) THEN ISNULL(
                               (SELECT SUM(dbo.F8(comp_componente) * comp_cantidad)
                                FROM Composicion
                                WHERE comp_producto = @prod_codigo), 0)
                       ELSE (SELECT prod_precio FROM Producto WHERE prod_codigo = @prod_codigo)
                END;
        END;
END;