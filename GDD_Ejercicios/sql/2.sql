SELECT
    prod_codigo,
    prod_detalle
FROM
    Producto
    JOIN Item_Factura ON prod_codigo = item_producto
    JOIN Factura ON fact_tipo = item_tipo
    AND fact_sucursal = item_sucursal
    AND fact_numero = item_numero
WHERE
    YEAR(fact_fecha) = 2012
GROUP BY
    prod_codigo,
    prod_detalle
ORDER BY
    SUM(item_cantidad);