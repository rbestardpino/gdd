CREATE TRIGGER T12
    ON Composicion
    FOR INSERT, UPDATE AS
BEGIN

    IF 1 = ANY (SELECT dbo.F12(I.comp_producto, I.comp_componente) FROM inserted I)
        BEGIN
            ROLLBACK
            RAISERROR ('EL PRODUCTO SE COMPONE A SI MISMO',1,1)
        END
END;

ALTER FUNCTION F12(@prod_codigo CHAR(8), @comp_codigo CHAR(8)) RETURNS BIT
    BEGIN
        RETURN CASE
                   WHEN @prod_codigo = @comp_codigo THEN 1
                   WHEN 1 = ANY (SELECT dbo.F12(@prod_codigo, comp_componente)
                                 FROM Composicion
                                 WHERE comp_producto = @comp_codigo) THEN 1
                   ELSE 0
            END
    END

SELECT *
FROM Composicion;

INSERT INTO Composicion
VALUES (3, '00001109', '00001104');

DELETE
FROM Composicion
WHERE comp_producto = '00001109';

SELECT comp_producto, comp_componente, dbo.F12(comp_producto, comp_componente)
FROM Composicion;
