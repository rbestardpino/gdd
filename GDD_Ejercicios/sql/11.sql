SELECT
    fami_detalle,
    COUNT(DISTINCT p1.prod_codigo) AS cant_productos,
    SUM(item_precio * item_cantidad) AS monto
FROM
    Item_Factura i1
    JOIN Producto p1 ON p1.prod_codigo = item_producto
    JOIN Familia ON prod_familia = fami_id
WHERE
    20000 > ANY(
        SELECT
            SUM(i2.item_cantidad * i2.item_precio)
        FROM
            Factura
            JOIN Item_Factura i2 ON i2.item_numero = fact_numero
            AND i2.item_tipo = fact_tipo
            AND i2.item_sucursal = fact_sucursal
            JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
        WHERE
            YEAR(fact_fecha) = 2012
            AND p2.prod_familia = fami_id
    )
GROUP BY
    fami_detalle
ORDER BY
    cant_productos DESC;