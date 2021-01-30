SELECT
    prod_detalle,
    MAX(s1.stoc_cantidad) AS stock_maximo
FROM
    Producto
    JOIN STOCK s1 ON prod_codigo = s1.stoc_producto
GROUP BY
    prod_detalle,
    prod_codigo
HAVING
    0 < ALL(
        SELECT
            s2.stoc_cantidad
        FROM
            STOCK s2
        WHERE
            s2.stoc_producto = prod_codigo
    )
    AND COUNT(*) = (
        SELECT
            COUNT(*)
        FROM
            DEPOSITO
        GROUP BY
            depo_codigo
    );