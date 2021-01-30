SELECT
    empl_jefe,
    empl_codigo,
    empl_nombre,
    COUNT(depo_codigo) AS cant_depos_asignados
FROM
    Empleado
    JOIN DEPOSITO ON empl_codigo = depo_encargado
    OR empl_jefe = depo_encargado
GROUP BY
    empl_jefe,
    empl_codigo,
    empl_nombre;