SELECT
    prod_codigo,
    prod_detalle,
    SUM(stoc_cantidad) AS stock
FROM
    Producto
    JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY
    prod_codigo,
    prod_detalle
ORDER BY
    prod_detalle;