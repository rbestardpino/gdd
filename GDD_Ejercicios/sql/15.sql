SELECT
    p1.prod_codigo AS PROD1,
    p1.prod_detalle AS DETALL1,
    p2.prod_codigo AS PROD2,
    p2.prod_detalle AS DETALLE2,
    COUNT(*) AS VECES --JOINEO LAS DOS TABLAS CON PRODUCTOS E ITEMSFACTURA TENIENDO EN CUENTA QUE TENGA LA MISMA PK Y CODIGOS DISTINTOS
FROM
    (
        Producto p1
        JOIN Item_Factura i1 ON i1.item_producto = p1.prod_codigo
    )
    JOIN (
        Producto p2
        JOIN Item_Factura i2 ON i2.item_producto = p2.prod_codigo
    ) ON i2.item_numero = i1.item_numero
    AND i2.item_tipo = i1.item_tipo
    AND i2.item_sucursal = i1.item_sucursal
    AND p1.prod_codigo != p2.prod_codigo --PARA QUE NO SE REPITAN
WHERE
    i1.item_producto > i2.item_producto
GROUP BY
    p1.prod_codigo,
    p1.prod_detalle,
    p2.prod_codigo,
    p2.prod_detalle
HAVING
    COUNT(*) > 500
ORDER BY
    VECES