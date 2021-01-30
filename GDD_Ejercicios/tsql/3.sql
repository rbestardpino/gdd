CREATE PROC P3 @cant_empleados_sin_jefe INT OUTPUT AS
BEGIN
    DECLARE
        @gerente NUMERIC(6, 0);

    SELECT TOP 1 @gerente = empl_codigo
    FROM Empleado
    WHERE empl_jefe IS NULL
    ORDER BY empl_salario DESC,
             empl_ingreso ASC;

    SET
        @cant_empleados_sin_jefe = (
            SELECT COUNT(*)
            FROM Empleado
            WHERE empl_jefe IS NULL
        );

    UPDATE
        Empleado
    SET empl_codigo = @gerente
    WHERE empl_jefe IS NULL
      AND empl_codigo != @gerente;

END;