SELECT
    i1.item_producto,
    (
        SELECT
            TOP 1 fact_cliente
        FROM
            Factura
            JOIN Item_Factura i2 ON i2.item_numero = fact_numero
            AND i2.item_tipo = fact_tipo
            AND i2.item_sucursal = fact_sucursal
        WHERE
            i2.item_producto = i1.item_producto
        GROUP BY
            fact_cliente
        ORDER BY
            SUM(ISNULL(i2.item_cantidad * i2.item_precio, 0)) DESC
    ) AS cliente_mayor_compra
FROM
    Item_Factura i1
WHERE
    item_producto IN (
        SELECT
            top 10 item_producto
        FROM
            Item_Factura
        GROUP BY
            item_producto
        ORDER BY
            SUM(ISNULL(item_cantidad, 0)) DESC
    )
    OR item_producto IN (
        SELECT
            top 10 item_producto
        FROM
            Item_Factura
        GROUP BY
            item_producto
        ORDER BY
            SUM(ISNULL(item_cantidad, 0)) ASC
    )
GROUP BY
    item_producto;