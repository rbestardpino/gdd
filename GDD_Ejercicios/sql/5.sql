SELECT prod_codigo,
       prod_detalle,
       SUM(i1.item_cantidad) AS egresos_de_stock
FROM producto
     JOIN item_factura i1 ON i1.item_producto = prod_codigo
     JOIN factura f1 ON f1.fact_tipo = i1.item_tipo
                        AND f1.fact_sucursal = i1.item_sucursal
                        AND f1.fact_numero = i1.item_numero
WHERE YEAR ( f1.fact_fecha ) = 2012
GROUP BY prod_codigo,
         prod_detalle
HAVING SUM(i1.item_cantidad) > ( SELECT SUM(i2.item_cantidad)
                                 FROM item_factura i2
                                      JOIN factura f2 ON f2.fact_tipo = i2.item_tipo
                                                         AND f2.fact_sucursal = i2.item_sucursal
                                                         AND f2.fact_numero = i2.item_numero
                                 WHERE YEAR ( f2.fact_fecha ) = 2011
                                       AND i2.item_producto = prod_codigo
                                 GROUP BY i2.item_producto );