CREATE FUNCTION F11(@empl_codigo NUMERIC(6)) RETURNS INT
BEGIN
    RETURN (SELECT COUNT(DISTINCT empl_codigo) + ISNULL(SUM(dbo.F11(empl_codigo)), 0)
            FROM Empleado
            WHERE empl_jefe = @empl_codigo)
END;

SELECT dbo.F11(empl_codigo) FROM Empleado;