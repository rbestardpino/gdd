SELECT
    CONCAT(
        YEAR(f1.fact_fecha),
        RIGHT(CONCAT('0', MONTH(f1.fact_fecha)), 2)
    ) AS periodo,
    p1.prod_codigo,
    p1.prod_detalle,
    SUM(ISNULL(i1.item_cantidad, 0)) AS cant_ventas,
    (
        SELECT
        SUM(ISNULL(i2.item_cantidad, 0))
    FROM
        Item_Factura i2
        JOIN Factura f2 ON i2.item_numero + i2.item_tipo + i2.item_sucursal = f2.fact_numero + f2.fact_tipo + f2.fact_sucursal
    WHERE
            YEAR(f2.fact_fecha) = YEAR(f1.fact_fecha) -1
        AND MONTH(f2.fact_fecha) = MONTH(f1.fact_fecha)
        AND i2.item_producto = p1.prod_codigo
    ) AS cant_facturas_año_anterior,
    COUNT(DISTINCT fact_numero) AS cant_facturas
FROM
    Factura f1
    JOIN Item_Factura i1 ON i1.item_sucursal + i1.item_numero + i1.item_tipo = f1.fact_sucursal + f1.fact_numero + f1.fact_tipo
    JOIN Producto p1 ON p1.prod_codigo = i1.item_producto
GROUP BY
    YEAR(f1.fact_fecha),
    MONTH(f1.fact_fecha),
    p1.prod_codigo,
    p1.prod_detalle
ORDER BY
    YEAR(f1.fact_fecha),
    MONTH(f1.fact_fecha),
    p1.prod_codigo