-- Mostrar considerando todos los depósitos, los 10 depósitos que
-- tiene mayores unidades tienen y los 10 depósitos que menos cantidad de
-- unidades tienen. Considerar que pueden tener depósitos con STOCK 0 en todos sus productos.
--
-- En ambos casos mostrar:Producto que mayor cantidad tiene en el depósito( en unidades),
-- en caso de tener 0, mostrar el string “sin deposito”.
--
-- Nota: No se permiten sub select en el FROM y debe realizarse una
-- sola consulta para mostrar el resultado.

SELECT depo_codigo,
       (CASE
            WHEN (SELECT TOP 1 SUM(stoc_cantidad)
                  FROM STOCK
                  WHERE stoc_deposito = depo_codigo
                  GROUP BY stoc_producto
                  ORDER BY SUM(stoc_cantidad) DESC) = 0 THEN 'SIN DEPOSITO'
            ELSE (SELECT TOP 1 stoc_producto
                  FROM STOCK
                  WHERE stoc_deposito = depo_codigo
                  GROUP BY stoc_producto
                  ORDER BY SUM(stoc_cantidad) DESC) END) Producto
FROM DEPOSITO
WHERE depo_codigo IN (SELECT TOP 10 stoc_deposito
                      FROM DEPOSITO
                               LEFT JOIN STOCK ON stoc_deposito = depo_codigo
                      GROUP BY stoc_deposito
                      ORDER BY SUM(stoc_cantidad) DESC)
   OR depo_codigo IN (SELECT TOP 10 stoc_deposito
                      FROM DEPOSITO
                               LEFT JOIN STOCK ON stoc_deposito = depo_codigo
                      GROUP BY stoc_deposito
                      ORDER BY SUM(stoc_cantidad));