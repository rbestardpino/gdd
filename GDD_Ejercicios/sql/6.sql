SELECT
    rubr_id,
    rubr_detalle,
    COUNT(prod_codigo) AS cant_articulos,
    SUM(ISNULL(s1.stoc_cantidad, 0)) AS stock_total
FROM
    Rubro
    JOIN Producto ON rubr_id = prod_rubro
    JOIN STOCK s1 ON prod_codigo = s1.stoc_producto
WHERE
    stoc_cantidad > (
        SELECT
            s2.stoc_cantidad
        FROM
            STOCK s2
        WHERE
            s2.stoc_producto = '00000000'
            AND s2.stoc_deposito = '00'
    )
GROUP BY
    rubr_id,
    rubr_detalle;