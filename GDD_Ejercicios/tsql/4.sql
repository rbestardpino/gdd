CREATE PROC P4 @MAYOR_VENDEDOR NUMERIC(6) OUTPUT AS
BEGIN
    UPDATE Empleado
    SET empl_comision = (SELECT SUM(fact_total)
                         FROM Factura f
                         WHERE f.fact_vendedor = empl_codigo
                           AND YEAR(f.fact_fecha) =
                               (SELECT TOP 1 YEAR(F2.fact_fecha) FROM Factura f2 ORDER BY f2.fact_fecha DESC)
                         GROUP BY f.fact_vendedor);

    SET @MAYOR_VENDEDOR = (SELECT TOP 1 empl_codigo FROM Empleado ORDER BY empl_comision DESC);
END;