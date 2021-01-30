SELECT
    prod_codigo,
    prod_detalle,
    COUNT(ISNULL(comp_cantidad, 0)) AS cantidad
FROM
    Producto
    LEFT JOIN Composicion ON prod_codigo = comp_producto
    JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY
    prod_codigo,
    prod_detalle
HAVING
    AVG(ISNULL(stoc_cantidad, 0)) > 100
ORDER BY
    cantidad;