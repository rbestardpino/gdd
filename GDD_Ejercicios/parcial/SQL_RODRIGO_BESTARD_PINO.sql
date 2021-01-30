-- Se pide realizar una consulta SQL que retorne lo siguiente:
--
-- La razón social de los 15 clientes que posean menor límite de crédito,
-- el promedio en $ de las compras realizadas por ese cliente y que se indique
-- un string “Compró productos compuestos” en caso de que alguno de todos los productos
-- comprados tenga composición.
--
-- Considerar solo aquellos clientes que tengan alguna factura mayor a $350000 (fact_total).
--
-- Se deberá ordenar los resultados por el domicilio del cliente.
--
--  NOTA: No se permite el uso de sub-selects en el FROM ni funciones definidas
--  por el usuario para este punto.

SELECT TOP 15 C.clie_razon_social,
              AVG(F.fact_total)                               AS promedio_gastado,
              (CASE
                   WHEN (I.item_producto IN (SELECT C.comp_producto FROM Composicion C))
                       THEN 'Compro productos compuestos'
                   ELSE 'No compro productos compuestos' END) AS compro_compuestos
FROM Cliente C
         JOIN Factura F ON C.clie_codigo = F.fact_cliente
         JOIN Item_Factura I
              ON F.fact_tipo = I.item_tipo AND F.fact_sucursal = I.item_sucursal AND F.fact_numero = I.item_numero
WHERE 350000 < ANY
      (SELECT F2.fact_total FROM Factura F2 WHERE F2.fact_cliente = F.fact_cliente)
GROUP BY C.clie_razon_social, C.clie_limite_credito, C.clie_domicilio, I.item_producto
ORDER BY C.clie_limite_credito ASC, C.clie_domicilio ASC