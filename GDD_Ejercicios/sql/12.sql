SELECT
    prod_detalle,
    (
        SELECT
            COUNT(DISTINCT fact_cliente)
        FROM
            Factura f
            JOIN Item_Factura i ON i.item_numero + i.item_tipo + i.item_sucursal = f.fact_numero + f.fact_tipo + f.fact_sucursal
        WHERE
            i.item_producto = prod_codigo
    ) AS cantidad_clientes,
    (
        SELECT
            SUM(item_precio) / COUNT(item_precio)
        FROM
            Item_Factura
        WHERE
            item_producto = prod_codigo
    ) AS promedio_precio,
    (
        SELECT
            COUNT(*)
        FROM
            Stock
        WHERE
            stoc_producto = prod_codigo
            AND stoc_cantidad > 0
    ) AS cantidad_depositos_con_stock,
    (
        SELECT
            SUM(stoc_cantidad)
        FROM
            Stock
        WHERE
            stoc_producto = prod_codigo
    ) AS stock_actual
FROM
    Producto
    JOIN Item_Factura ON item_producto = prod_codigo
    JOIN Factura ON fact_tipo = item_tipo
    AND fact_sucursal = item_sucursal
    AND fact_numero = item_numero
WHERE
    YEAR(fact_fecha) = 2012
GROUP BY
    prod_codigo,
    prod_detalle
ORDER BY
    SUM(ISNULL((item_cantidad * item_precio), 0)) DESC