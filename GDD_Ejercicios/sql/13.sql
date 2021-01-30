SELECT
    p1.prod_detalle,
    p1.prod_precio,
    SUM(p1.prod_precio * comp_cantidad)
FROM
    Producto p1
    JOIN Composicion ON p1.prod_codigo = comp_producto
GROUP BY
    p1.prod_detalle,
    p1.prod_precio,
    p1.prod_codigo
HAVING
    COUNT(comp_componente) >= 2
ORDER BY
    COUNT(comp_componente) DESC;