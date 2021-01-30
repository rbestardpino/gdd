-- Realizar una consulta SQL que retorne, para cada producto con más de 2 artículos
--     distintos en su composición la siguiente información.
--
-- 1)      Detalle del producto
--
-- 2)      Rubro del producto
--
-- 3)      Cantidad de veces que fue vendido
--
--  El resultado deberá mostrar ordenado por la cantidad de los productos que lo componen.
--
--  NOTA: No se permite el uso de sub-selects en el FROM ni funciones definidas por el usuario
--      para este punto.

SELECT prod_detalle,
       prod_rubro,
       COUNT(item_numero) AS cant_vendida
FROM Producto
--HAY UN PRODUCTO QUE NO TIENE VENTAS ENTONCES EL LEFT JOIN PERMITE QUE APAREZCA CON CANTIDAD = 0
         LEFT JOIN Item_Factura ON item_producto = prod_codigo
--ACLARABA QUE TENIAN QUE SER DISTINTOS, POR ESO PUSE EL DISTINCT, PERO CON UN * FUNCIONABA
WHERE (SELECT COUNT(DISTINCT comp_componente) FROM Composicion WHERE comp_producto = prod_codigo) >= 2
GROUP BY prod_codigo, prod_detalle, prod_rubro
ORDER BY (SELECT COUNT(DISTINCT comp_componente) FROM Composicion WHERE comp_producto = prod_codigo) DESC


/* VERSION CON JOIN COMPOSICION
SELECT
    prod_detalle,
    prod_rubro,
    COUNT(DISTINCT item_numero) as cantidad_veces_vendido
FROM Producto
JOIN Composicion on comp_producto = prod_codigo
LEFT JOIN Item_Factura on item_producto = prod_codigo
--ACLARABA QUE TENIAN QUE SER DISTINTOS, POR ESO PUSE EL DISTINCT, PERO CON UN * FUNCIONABA
GROUP BY prod_codigo, prod_detalle, prod_rubro
HAVING COUNT(DISTINCT comp_componente) >= 2
ORDER BY COUNT(DISTINCT comp_componente) desc
*/