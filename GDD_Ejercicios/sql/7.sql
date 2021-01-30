SELECT
    prod_codigo,
    prod_detalle,
    MAX(item_precio) AS precio_maximo,
    MIN(item_precio) AS precio_minimo,
    (MAX(item_precio) - MIN(item_precio)) / MAX(item_precio) * 100 AS diferencia_porcentual
FROM
    Producto
    JOIN Item_Factura ON prod_codigo = item_producto
    JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY
    prod_codigo,
    prod_detalle
HAVING
    SUM(stoc_cantidad) > 0;