SELECT
    clie_razon_social,
    SUM(item_cantidad) AS cant_vendida,
    (
        SELECT
            TOP 1 item_producto
        FROM
            Item_Factura
            JOIN Factura ON item_numero + item_tipo + item_sucursal = fact_numero + fact_tipo + fact_sucursal
        WHERE
            fact_cliente = clie_codigo
            AND YEAR(fact_fecha) = 2012
        GROUP BY
            item_producto
        ORDER BY
            SUM(item_precio * item_cantidad) DESC,
            item_producto ASC
    ) AS prod_mas_vendido
FROM
    Cliente
    JOIN Factura ON clie_codigo = fact_cliente
    JOIN Item_Factura ON item_numero + item_tipo + item_sucursal = fact_numero + fact_tipo + fact_sucursal
WHERE
    YEAR(fact_fecha) = 2012
GROUP BY
    clie_codigo,
    clie_razon_social
HAVING
    SUM(item_precio * item_cantidad) < (
        SELECT
            AVG(item_precio * item_cantidad) * 1 / 3
        FROM
            Item_Factura
        WHERE
            item_producto = (
                SELECT
                    TOP 1 item_producto
                FROM
                    Item_Factura
                    JOIN Factura ON item_numero + item_tipo + item_sucursal = fact_numero + fact_tipo + fact_sucursal
                WHERE
                    YEAR(fact_fecha) = 2012
                GROUP BY
                    item_producto
                ORDER BY
                    SUM(item_precio * item_cantidad) DESC
            )
    )