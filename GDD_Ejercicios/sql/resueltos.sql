/* EJERCICIO 1 

Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
igual a $ 1000 ordenado por código de cliente. */

SELECT clie_codigo, ISNULL(clie_razon_social,'No tiene') as 'Razon Social' FROM Cliente
    WHERE clie_limite_credito > 2000
    ORDER BY clie_codigo

/* EJERCICIO 2
Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
cantidad vendida.
*/

SELECT prod_codigo, prod_detalle FROM Producto
    JOIN Item_Factura on prod_codigo = item_producto
    JOIN Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
    WHERE YEAR(fact_fecha) = 2012
    GROUP BY prod_codigo, prod_detalle
    ORDER BY COUNT(item_cantidad)


/* EJERCICIO 3
Realizar una consulta que muestre código de producto, nombre de producto y el stock
total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
nombre del artículo de menor a mayor.
*/

SELECT prod_codigo, prod_detalle, ISNULL(SUM(stoc_cantidad),0) as stoc_total FROM Producto
    JOIN STOCK ON prod_codigo = stoc_producto
    GROUP BY prod_codigo, prod_detalle
    ORDER BY prod_detalle

/* EJERCICIO 4
Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.
*/

SELECT prod_codigo, prod_detalle, ISNULL(COUNT(comp_componente),0) as cant_componentes FROM Producto
    LEFT JOIN Composicion on prod_codigo = comp_producto
    JOIN STOCK ON prod_codigo = stoc_producto
    GROUP BY prod_codigo, prod_detalle
    HAVING 100 < ISNULL(SUM(stoc_cantidad),0)/COUNT(stoc_cantidad)

/* EJERCICIO 5
Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.
*/

SELECT prod_codigo, prod_detalle, COUNT(*) as cant_egresos
    FROM Producto
    JOIN Item_Factura i on prod_codigo = item_producto
    JOIN Factura f1 on f1.fact_tipo+f1.fact_sucursal+f1.fact_numero=i.item_tipo+i.item_sucursal+i.item_numero
    WHERE YEAR(f1.fact_fecha) = 2012
    GROUP BY prod_codigo, prod_detalle
    HAVING COUNT(*) > (SELECT COUNT(*) FROM Item_Factura i2
                         JOIN Factura f2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero=i2.item_tipo+i2.item_sucursal+i2.item_numero
                         WHERE i2.item_producto = prod_codigo and YEAR(fact_fecha) = 2011)

/* EJERCICIO 6
Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’
*/

SELECT rubr_id, rubr_detalle, COUNT(DISTINCT prod_codigo), SUM(stoc_cantidad)
    FROM Rubro
    JOIN Producto on rubr_id = prod_rubro
    JOIN STOCK on prod_codigo = stoc_producto
    GROUP BY rubr_id, rubr_detalle
    HAVING SUM(stoc_cantidad) > (SELECT stoc_cantidad FROM STOCK 
                                    WHERE stoc_producto = '00000000' AND stoc_deposito = '00')

/* EJERCICIO 7
Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio = 12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock.
*/

SELECT prod_codigo, prod_detalle, MIN(item_precio), MAX(item_precio),
       STR((MAX(item_precio) - MIN(item_precio)) / MAX(item_precio)*100) + '%' AS porcentaje_variacion
    FROM Producto
    JOIN Item_Factura on item_producto = prod_codigo
    GROUP BY prod_codigo, prod_detalle
    HAVING 0 < (SELECT ISNULL(SUM(stoc_cantidad),0) FROM STOCK where prod_codigo = stoc_producto GROUP BY stoc_producto)


/* EJERCICIO 8 
Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene
*/

SELECT s1.stoc_producto, MAX(s1.stoc_cantidad) as max_stock
    FROM STOCK s1
    GROUP BY s1.stoc_producto
    HAVING 0 < ALL(SELECT s.stoc_cantidad FROM STOCK s WHERE s.stoc_producto = s1.stoc_producto)
            AND COUNT(*) = (SELECT COUNT(*) FROM DEPOSITO GROUP BY depo_codigo)

/* EJERCICIO 9
Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.
*/

SELECT empl_jefe, empl_codigo, empl_nombre, COUNT(*) as cant_depos
    FROM Empleado
    JOIN DEPOSITO ON depo_encargado = empl_jefe OR depo_encargado = empl_codigo
    GROUP BY empl_jefe, empl_codigo, empl_nombre

/* EJERCICIO 10
Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo.
*/

SELECT 
    item_producto, 
    (SELECT TOP 1 fact_cliente FROM Factura
        JOIN Item_Factura i ON i.item_numero+i.item_tipo+i.item_sucursal=fact_numero+fact_tipo+fact_sucursal
        WHERE i.item_producto = a.item_producto
        GROUP BY fact_cliente
        ORDER BY ISNULL(SUM(i.item_cantidad*i.item_precio),0) desc) as mayor_compra_cliente
    FROM Item_Factura a
    WHERE item_producto in (SELECT top 10 item_producto FROM Item_Factura GROUP BY item_producto ORDER BY ISNULL(SUM(item_cantidad),0) desc)
            OR 
          item_producto in (SELECT top 10 item_producto FROM Item_Factura GROUP BY item_producto ORDER BY ISNULL(SUM(item_cantidad),0) asc)
    GROUP BY item_producto

/* EJERCICIO 11
Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012.
*/

SELECT fami_detalle, COUNT(DISTINCT prod_codigo), SUM(item_precio*item_cantidad)
    FROM Familia
    JOIN Producto on fami_id = prod_familia
    JOIN Item_Factura on item_producto = prod_codigo
    WHERE 20000 < ANY(SELECT SUM(i.item_cantidad*i.item_precio)
                        FROM Factura
                        JOIN Item_Factura i on i.item_numero+i.item_tipo+i.item_sucursal=fact_numero+fact_tipo+fact_sucursal
                        JOIN Producto p on p.prod_codigo = i.item_producto
                        WHERE YEAR(fact_fecha) = 2012 AND p.prod_familia = fami_id)
    GROUP BY fami_id, fami_detalle


/* EJERCICIO 12
Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.
*/

--SE COMPLICA UN POCO MÁS PORQUE HAY QUE BUSCAR TODOS LOS CLIENTES SIN IMPORTAR QUE SEAN LOS DEL 2012 O NO
SELECT prod_detalle,
       (SELECT COUNT(DISTINCT fact_cliente) FROM Factura f
            JOIN Item_Factura i on i.item_numero+i.item_tipo+i.item_sucursal=f.fact_numero+f.fact_tipo+f.fact_sucursal
            WHERE item_producto = prod_codigo) AS cantidad_clientes,
       (SELECT SUM(item_precio)/COUNT(item_precio) 
            FROM Item_Factura WHERE item_producto = prod_codigo) as promedio_precio,
       (SELECT COUNT(*) From Stock where stoc_producto = prod_codigo and stoc_cantidad > 0)  as cantidad_depositos_con_stock,
       (SELECT SUM(stoc_cantidad) FROM Stock where stoc_producto = prod_codigo) as stock_actual
    FROM Producto
    JOIN Item_Factura on item_producto = prod_codigo
    JOIN Factura on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
    WHERE YEAR(fact_fecha) = 2012
    GROUP BY prod_codigo, prod_detalle
    ORDER BY SUM(ISNULL((item_cantidad*item_precio),0)) desc
                        

/* EJERCICIO 13
Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad 
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.
*/

--JOINEO DOS VECES CON PRODUCTO PARA TENER LOS DATOS DE LOS COMPONENTES
SELECT p.prod_detalle,
       p.prod_precio,
       SUM(p.prod_precio*comp_cantidad)
    FROM Producto p
    JOIN Composicion on comp_producto = p.prod_codigo
    JOIN Producto p1 on comp_componente = p1.prod_codigo
    GROUP BY p.prod_codigo, p.prod_precio, p.prod_detalle
    HAVING COUNT(comp_componente) >= 2
    ORDER BY COUNT(comp_componente) DESC

/* EJERCICIO 14
Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:
Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna
*/
SELECT fact_cliente,
       COUNT (DISTINCT fact_numero) as cant_compras,
       (SELECT AVG(ISNULL(fact_total,0)) FROM Factura f --LO TENGO QUE PONER ASÍ PORQUE SINO ESTÁN REPETIDAS LAS FACTURAS
            WHERE f.fact_cliente = a.fact_cliente AND YEAR(f.fact_fecha) = (SELECT MAX(YEAR(f2.fact_fecha)) FROM Factura f2)),
       COUNT(DISTINCT item_producto) as cant_productos,
       MAX(fact_total) as max_compra
    FROM Factura a
    JOIN Item_Factura on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
    WHERE YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
    GROUP BY fact_cliente
    ORDER BY cant_productos

/* EJERCICIO 16
 Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
en la empresa, se pide una consulta SQL que retorne aquellos clientes cuyas ventas son
inferiores a 1/3 del promedio de ventas del producto que más se vendió en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
mostrar solamente el de menor código) para ese cliente.
Aclaraciones:
La composición es de 2 niveles, es decir, un producto compuesto solo se compone de
productos no compuestos.
Los clientes deben ser ordenados por código de provincia ascendente.
*/

SELECT
    clie_razon_social, 
    SUM(item_cantidad) as cant_vendida,
    SUM(item_precio*item_cantidad) as monto_vendido,
    (SELECT TOP 1 item_producto 
        FROM Item_Factura
        JOIN Factura ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
        WHERE fact_cliente = clie_codigo AND YEAR(fact_fecha) = 2012
        GROUP BY item_producto
        ORDER BY SUM(item_precio*item_cantidad) desc, item_producto asc) as prod_mas_vendido
FROM Cliente
JOIN Factura on clie_codigo = fact_cliente
JOIN Item_Factura on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
WHERE YEAR(fact_fecha) = 2012
GROUP BY clie_codigo, clie_razon_social
HAVING SUM(item_precio*item_cantidad) < (SELECT AVG(item_precio*item_cantidad)*1/3
                                            FROM Item_Factura
                                            WHERE item_producto = (SELECT TOP 1 item_producto FROM Item_Factura
                                                                    JOIN Factura ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
                                                                    WHERE YEAR(fact_fecha) = 2012
                                                                    GROUP BY item_producto
                                                                    ORDER BY SUM(item_precio*item_cantidad) desc))

/* EJERCICIO 17
Escriba una consulta que retorne una estadística de ventas por año y mes para cada
producto.
La consulta debe retornar:
PERIODO: Año y mes de la estadística con el formato YYYYMM
PROD: Código de producto
DETALLE: Detalle del producto
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo
pero del año anterior
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
periodo
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por periodo y código de producto.
*/

-- HAY QUE VER COMO HACER PARA QUE NO MUESTRE PERIODOS EN 0 PORQUE HAY PRODUCTOS QUE NUNCA FUERON VENDIDOS
SELECT
    CONCAT(YEAR(fact_fecha),RIGHT(CONCAT('0',MONTH(fact_fecha)),2)) as PERIODO,
    prod_codigo as PROD,
    prod_detalle as DETALLE,
    ISNULL(SUM(item_cantidad),0) AS CANTIDAD_VENDIDA,
    (SELECT ISNULL(SUM(item_cantidad),0) FROM Item_Factura
        JOIN Factura f ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
        WHERE YEAR(f.fact_fecha) = YEAR(fact_fecha)-1 AND MONTH(fact_fecha) = MONTH(f.fact_fecha) AND item_producto = prod_codigo) as VENTAS_AÑO_ANT, 
    COUNT(DISTINCT fact_numero) AS CANT_FACTURAS
FROM Producto
--DEBERÍA SER UN LEFT PERO EL PROBLEMA DE ARRIBA
JOIN (Item_Factura JOIN Factura ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal) ON item_producto = prod_codigo
GROUP BY YEAR(fact_fecha), MONTH(fact_fecha), prod_codigo, prod_detalle
ORDER BY YEAR(fact_fecha), MONTH(fact_fecha), prod_codigo

/* EJERCICIO 18
Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:
DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30
días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por cantidad de productos diferentes vendidos del rubro.
*/

SELECT
    rubr_detalle as DETALLE_RUBRO,
    SUM(item_cantidad*item_precio) as VENTAS,
    (SELECT TOP 1 item_producto From Item_Factura 
        JOIN Producto ON item_producto = prod_codigo
        WHERE rubr_id = prod_rubro
        GROUP BY item_producto
        ORDER BY SUM(item_cantidad*item_precio) desc) AS PROD1, 
    (SELECT TOP 1 item_producto From Item_Factura 
        JOIN Producto ON item_producto = prod_codigo
        WHERE rubr_id = prod_rubro AND item_producto <> (SELECT TOP 1 item_producto From Item_Factura 
                                                            JOIN Producto ON item_producto = prod_codigo
                                                            WHERE rubr_id = prod_rubro
                                                            GROUP BY item_producto
                                                            ORDER BY SUM(item_cantidad*item_precio) desc)
        GROUP BY item_producto
        ORDER BY SUM(item_cantidad*item_precio) desc) AS PROD2,
    (SELECT TOP 1 fact_cliente FROM Factura 
        JOIN Item_Factura ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
        JOIN Producto ON item_producto = prod_codigo
        WHERE prod_rubro = rubr_id
        GROUP BY fact_cliente
        ORDER BY SUM(item_cantidad*item_precio) desc) AS CLIENTE
FROM Rubro
JOIN Producto ON prod_rubro = rubr_id
JOIN Item_Factura on item_producto = prod_codigo
GROUP BY rubr_id, rubr_detalle

/* EJERCICIO 19
En virtud de una recategorizacion de productos referida a la familia de los mismos se
solicita que desarrolle una consulta sql que retorne para todos los productos:
 Codigo de producto
 Detalle del producto
 Codigo de la familia del producto
 Detalle de la familia actual del producto
 Codigo de la familia sugerido para el producto
 Detalla de la familia sugerido para el producto
La familia sugerida para un producto es la que poseen la mayoria de los productos cuyo
detalle coinciden en los primeros 5 caracteres.
En caso que 2 o mas familias pudieran ser sugeridas se debera seleccionar la de menor
codigo. Solo se deben mostrar los productos para los cuales la familia actual sea
diferente a la sugerida
Los resultados deben ser ordenados por detalle de producto de manera ascendente
*/

SELECT 
    prod_codigo,
    prod_detalle,
    prod_familia,
    fami_detalle
FROM Producto
JOIN Familia on fami_id = prod_familia
ORDER BY fami_detalle asc

/* EJERCICIO 2O
Escriba una consulta sql que retorne un ranking de los mejores 3 empleados del 2012
Se debera retornar legajo, nombre y apellido, anio de ingreso, puntaje 2011, puntaje
2012. El puntaje de cada empleado se calculara de la siguiente manera: para los que
hayan vendido al menos 50 facturas el puntaje se calculara como la cantidad de facturas
que superen los 100 pesos que haya vendido en el año, para los que tengan menos de 50
facturas en el año el calculo del puntaje sera el 50% de cantidad de facturas realizadas
por sus subordinados directos en dicho año.
*/

SELECT TOP 3
    empl_codigo,
    empl_nombre,
    empl_apellido,
    YEAR(a.empl_ingreso) anio_ingreso,
    CASE 
        WHEN (SELECT COUNT(*) FROM Factura WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = 2012) >= 50 
            THEN (SELECT COUNT(*) FROM Factura WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = 2012 AND fact_total > 100 )
        ELSE (SELECT COUNT(*) FROM Factura WHERE fact_vendedor in (SELECT empl_codigo FROM Empleado  where empl_jefe = a.empl_codigo) AND YEAR(fact_fecha) = 2012)/2 
    END AS PUNTAJE2012,
    CASE 
        WHEN (SELECT COUNT(*) FROM Factura WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = 2011) >= 50 
            THEN (SELECT COUNT(*) FROM Factura WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = 2011 AND fact_total > 100 )
        ELSE (SELECT COUNT(*) FROM Factura WHERE fact_vendedor in (SELECT empl_codigo FROM Empleado  where empl_jefe = a.empl_codigo) AND YEAR(fact_fecha) = 2011)/2
    END AS PUNTAJE2011
FROM Empleado a
ORDER BY PUNTAJE2012 desc

/* EJERCICIO 21
21. Escriba una consulta sql que retorne para todos los años, en los cuales se haya hecho al
menos una factura, la cantidad de clientes a los que se les facturo de manera incorrecta 
al menos una factura y que cantidad de facturas se realizaron de manera incorrecta. Se
considera que una factura es incorrecta cuando la diferencia entre el total de la factura
menos el total de impuesto tiene una diferencia mayor a $ 1 respecto a la sumatoria de
los costos de cada uno de los items de dicha factura. Las columnas que se deben mostrar
son:
 Año
 Clientes a los que se les facturo mal en ese año
 Facturas mal realizadas en ese año
*/

SELECT
    YEAR(fact_fecha),
    COUNT(DISTINCT fact_cliente) cant_clientes_mal_facturados,
    COUNT(DISTINCT fact_numero) cant_facturas_mal
FROM Factura
WHERE 1 < fact_total - fact_total_impuestos - (SELECT SUM(item_cantidad*item_precio) FROM Item_Factura where item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal)
GROUP BY YEAR(fact_fecha)
ORDER BY YEAR(fact_fecha) 


/* EJERCICIO 22
Escriba una consulta sql que retorne una estadistica de venta para todos los rubros por
trimestre contabilizando todos los años. Se mostraran como maximo 4 filas por rubro (1
por cada trimestre).
Se deben mostrar 4 columnas:
 Detalle del rubro
 Numero de trimestre del año (1 a 4)
 Cantidad de facturas emitidas en el trimestre en las que se haya vendido al
menos un producto del rubro
 Cantidad de productos diferentes del rubro vendidos en el trimestre
El resultado debe ser ordenado alfabeticamente por el detalle del rubro y dentro de cada
rubro primero el trimestre en el que mas facturas se emitieron.
No se deberan mostrar aquellos rubros y trimestres para los cuales las facturas emitiadas
no superen las 100.
En ningun momento se tendran en cuenta los productos compuestos para esta
estadistica.
*/


/* EJERCICIO 23
Realizar una consulta SQL que para cada año muestre :
 Año
 El producto con composición más vendido para ese año.
 Cantidad de productos que componen directamente al producto más vendido
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año en forma descendente.
*/

SELECT 
    YEAR(fo.fact_fecha),
    (SELECT top 1 comp_producto From Composicion 
        JOIN Item_Factura ON comp_producto = item_producto
        JOIN Factura f ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal 
        WHERE YEAR(fo.fact_fecha) = YEAR(f.fact_fecha)
        GROUP BY comp_producto
        ORDER BY SUM(item_cantidad*item_precio) desc) AS compuesto_mas_vendido,

    (SELECT COUNT(comp_componente) From Composicion where comp_producto = (SELECT TOP 1 comp_producto From Composicion JOIN Item_Factura ON comp_producto = item_producto
                                                                                JOIN Factura f ON item_numero+item_tipo+item_sucursal=f.fact_numero+f.fact_tipo+f.fact_sucursal 
                                                                                WHERE YEAR(f.fact_fecha) = YEAR(fo.fact_fecha) GROUP BY comp_producto
                                                                                ORDER BY SUM(item_cantidad*item_precio) desc)) as cant_componentes,

    (SELECT COUNT(DISTINCT f.fact_numero) From Item_Factura 
        JOIN Factura f ON item_numero+item_tipo+item_sucursal=f.fact_numero+f.fact_tipo+f.fact_sucursal 
        WHERE YEAR(f.fact_fecha) = YEAR(fo.fact_fecha) AND item_producto = (SELECT TOP 1 comp_producto From Composicion JOIN Item_Factura i2 ON comp_producto = i2.item_producto
                                                                            JOIN Factura f2 ON item_numero+item_tipo+item_sucursal=f2.fact_numero+f2.fact_tipo+f2.fact_sucursal 
                                                                            WHERE YEAR(f2.fact_fecha) = YEAR(fo.fact_fecha) GROUP BY comp_producto
                                                                            ORDER BY SUM(i2.item_cantidad*i2.item_precio) desc)) as cant_facturas,

    (SELECT TOP 1 fact_cliente FROM Factura f
        JOIN Item_Factura ON item_numero+item_tipo+item_sucursal=f.fact_numero+f.fact_tipo+f.fact_sucursal
        WHERE YEAR(f.fact_fecha) = YEAR(fo.fact_fecha) AND item_producto = (SELECT TOP 1 comp_producto From Composicion JOIN Item_Factura i2 ON comp_producto = i2.item_producto
                                                                            JOIN Factura f2 ON item_numero+item_tipo+item_sucursal=f2.fact_numero+f2.fact_tipo+f2.fact_sucursal 
                                                                            WHERE YEAR(f2.fact_fecha) = YEAR(fo.fact_fecha) GROUP BY comp_producto
                                                                            ORDER BY SUM(i2.item_cantidad*i2.item_precio) desc)
        GROUP BY f.fact_cliente
        ORDER BY SUM(item_cantidad*item_precio) desc) as mayor_cliente,
    (SELECT SUM(item_cantidad*item_precio) From Composicion 
        JOIN Item_Factura ON comp_producto = item_producto
        JOIN Factura f ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal 
        WHERE YEAR(fo.fact_fecha) = YEAR(f.fact_fecha) AND item_producto = (SELECT TOP 1 comp_producto From Composicion JOIN Item_Factura ON comp_producto = item_producto
                                                                                JOIN Factura f ON item_numero+item_tipo+item_sucursal=f.fact_numero+f.fact_tipo+f.fact_sucursal 
                                                                                WHERE YEAR(f.fact_fecha) = YEAR(fo.fact_fecha) GROUP BY comp_producto
                                                                                ORDER BY SUM(item_cantidad*item_precio) desc)
        GROUP BY comp_producto) / SUM(fo.fact_total+fo.fact_total_impuestos) AS porcentaje
FROM Factura fo
GROUP BY YEAR(fo.fact_fecha)
ORDER BY SUM(fo.fact_total+fo.fact_total_impuestos) desc  

/* EJERCICIO 24
Escriba una consulta que considerando solamente las facturas correspondientes a los
dos vendedores con mayores comisiones, retorne los productos con composición
facturados al menos en cinco facturas,
La consulta debe retornar las siguientes columnas:
 Código de Producto
 Nombre del Producto
 Unidades facturadas
El resultado deberá ser ordenado por las unidades facturadas descendente.
*/

SELECT 
    prod_codigo,
    prod_detalle,
    COUNT(item_cantidad) as unidades_facturadas
FROM Composicion
JOIN Producto on comp_producto = prod_codigo
JOIN Item_Factura ON comp_producto = item_producto
JOIN Factura f ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
WHERE
    fact_vendedor in (SELECT TOP 2 empl_codigo From Empleado ORDER BY empl_comision desc) AND
    5 < (SELECT COUNT(DISTINCT fact_numero) FROM Factura
            JOIN Item_Factura ON comp_producto = item_producto
            WHERE item_producto = prod_codigo)
GROUP BY prod_codigo, prod_detalle
ORDER BY unidades_facturadas desc

/* EJERCICIO 25
Realizar una consulta SQL que para cada año y familia muestre :
a. Año
b. El código de la familia más vendida en ese año.
c. Cantidad de Rubros que componen esa familia.
d. Cantidad de productos que componen directamente al producto más vendido de
esa familia.
e. La cantidad de facturas en las cuales aparecen productos pertenecientes a esa
familia.
f. El código de cliente que más compro productos de esa familia.
g. El porcentaje que representa la venta de esa familia respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año y familia en forma
descendente.
*/



/* EJERCICIO 26
Escriba una consulta sql que retorne un ranking de empleados devolviendo las
siguientes columnas:
 Empleado
 Depósitos que tiene a cargo
 Monto total facturado en el año corriente
 Codigo de Cliente al que mas le vendió
 Producto más vendido
 Porcentaje de la venta de ese empleado sobre el total vendido ese año.
Los datos deberan ser ordenados por venta del empleado de mayor a menor.
*/

SELECT
    empl_codigo,
    COUNT(depo_codigo) as depositos_cargo,
    (SELECT ISNULL(SUM(fact_total),0)
        FROM Factura 
        WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) From Factura)) as facturacion_total,
    ISNULL((SELECT TOP 1 fact_cliente
        FROM Factura 
        WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) From Factura)
        GROUP BY fact_cliente 
        ORDER BY SUM(ISNULL(fact_total,0)) DESC),'No') as cliente,
    ISNULL((SELECT TOP 1 item_producto 
        FROM Factura 
        JOIN Item_Factura on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
        WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) From Factura)
        GROUP BY item_producto 
        ORDER BY SUM(ISNULL(fact_total,0)) DESC),'No') as producto,
    ISNULL(100*(SELECT SUM(fact_total) FROM Factura WHERE fact_vendedor = empl_codigo AND YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) From Factura)) / (SELECT SUM(fact_total) From Factura where YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) From Factura)),0) as porcentaje
FROM Empleado
LEFT JOIN DEPOSITO on depo_encargado = empl_codigo
GROUP BY empl_codigo

/* EJERCICIO 27
Escriba una consulta sql que retorne una estadística basada en la facturacion por año y
envase devolviendo las siguientes columnas:
 Año
 Codigo de envase
 Detalle del envase
 Cantidad de productos que tienen ese envase
 Cantidad de productos facturados de ese envase
 Producto mas vendido de ese envase
 Monto total de venta de ese envase en ese año
 Porcentaje de la venta de ese envase respecto al total vendido de ese año
Los datos deberan ser ordenados por año y dentro del año por el envase con más
facturación de mayor a menor
*/

SELECT 
    YEAR(fact_fecha) as anio,
    enva_codigo,
    enva_detalle,
    COUNT(DISTINCT prod_codigo) as productos,
    COUNT(DISTINCT item_producto) as productos_vendidos,
    (SELECT TOP 1 prod_codigo 
        FROM Producto
        JOIN Item_Factura on prod_codigo = item_producto
        WHERE prod_envase = enva_codigo
        GROUP BY prod_codigo
        ORDER BY SUM(item_producto*item_cantidad)) as producto_mas_vendido,
    SUM(item_cantidad*item_precio) as monto_venta,
    100 * SUM(item_cantidad*item_precio) / (SELECT SUM(item_cantidad*item_precio) 
                                        FROM Item_Factura
                                        JOIN Factura f on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
                                        WHERE YEAR(f.fact_fecha) = YEAR(a.fact_fecha)) as porcentaje
FROM Envases JOIN Producto on prod_envase = enva_codigo
LEFT JOIN (Item_Factura JOIN Factura a on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal) ON prod_codigo = item_producto
GROUP BY enva_codigo, enva_detalle, YEAR(fact_fecha)
ORDER BY YEAR(fact_fecha), SUM(item_cantidad*item_precio) desc


/* EJERCICIO 28
Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.
*/

SELECT 
    YEAR(fact_fecha) as anio,
    empl_codigo,
    empl_nombre,
    empl_apellido,
    COUNT(DISTINCT fact_numero) as cant_facturas,
    COUNT(DISTINCT fact_cliente) as cant_clientes,
    (SELECT COUNT(DISTINCT comp_producto) FROM Composicion 
        JOIN Item_Factura on comp_producto = item_producto
        JOIN Factura f on item_numero+item_tipo+item_sucursal=f.fact_numero+f.fact_tipo+f.fact_sucursal
        where f.fact_vendedor = empl_codigo and YEAR(f.fact_fecha) = YEAR(a.fact_fecha)) as cant_con_composicion,
    (SELECT COUNT(DISTINCT item_producto) FROM Item_Factura i
        JOIN Factura f on i.item_numero+i.item_tipo+i.item_sucursal=f.fact_numero+f.fact_tipo+f.fact_sucursal
        WHERE f.fact_vendedor = empl_codigo AND YEAR(f.fact_fecha) = YEAR(a.fact_fecha) AND i.item_producto not in (SELECT comp_producto From Composicion)) as cant_sin_composicion,
    SUM(item_cantidad*item_precio) as monto_total
FROM Empleado
JOIN Factura a on fact_vendedor = empl_codigo
JOIN Item_Factura on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
GROUP BY YEAR(fact_fecha), empl_codigo, empl_nombre, empl_apellido
ORDER BY YEAR(fact_fecha), COUNT(DISTINCT item_producto) desc

/* EJERCICIO 29
Se solicita que realice una estadística de venta por producto para el año 2011, solo para
los productos que pertenezcan a las familias que tengan más de 20 productos asignados
a ellas, la cual deberá devolver las siguientes columnas:
a. Código de producto
b. Descripción del producto
c. Cantidad vendida
d. Cantidad de facturas en la que esta ese producto
e. Monto total facturado de ese producto
Solo se deberá mostrar un producto por fila en función a los considerandos establecidos
antes. El resultado deberá ser ordenado por el la cantidad vendida de mayor a menor.
*/

SELECT
    prod_codigo,
    prod_detalle,
    SUM(item_cantidad) as cant_vendida,
    COUNT(DISTINCT fact_numero) as cant_facturas,
    SUM(item_cantidad*item_precio) as monto
FROM Producto
JOIN Item_Factura on item_producto = prod_codigo
JOIN Factura on item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
WHERE YEAR(fact_fecha) = 2011 AND prod_familia IN (SELECT fami_id FROM Familia 
                                                    JOIN Producto p ON p.prod_familia = fami_id
                                                    GROUP BY fami_id
                                                    HAVING COUNT(*) > 20)
GROUP BY prod_codigo, prod_detalle
ORDER BY cant_vendida desc

/* EJERCICIO 30
Se desea obtener una estadistica de ventas del año 2012, para los empleados que sean
jefes, o sea, que tengan empleados a su cargo, para ello se requiere que realice la
consulta que retorne las siguientes columnas:
 Nombre del Jefe
 Cantidad de empleados a cargo
 Monto total vendido de los empleados a cargo
 Cantidad de facturas realizadas por los empleados a cargo
 Nombre del empleado con mejor ventas de ese jefe
Debido a la perfomance requerida, solo se permite el uso de una subconsulta si fuese
necesario.
Los datos deberan ser ordenados por de mayor a menor por el Total vendido y solo se
deben mostrarse los jefes cuyos subordinados hayan realizado más de 10 facturas.
*/

SELECT
    jefe.empl_nombre,
    jefe.empl_apellido,
    COUNT(DISTINCT empl.empl_codigo) as cant_empleados,
    SUM(ISNULL(fact_total,0)) as monto_vendido_empls,
    COUNT(DISTINCT fact_numero) as cant_facturas_empls,
    (SELECT TOP 1 a.empl_nombre
        FROM Empleado a 
        LEFT JOIN Factura fa on a.empl_codigo = fa.fact_vendedor 
        WHERE a.empl_jefe = jefe.empl_codigo AND YEAR(fa.fact_fecha) = 2012
        GROUP BY a.empl_codigo, a.empl_nombre
        ORDER by SUM(ISNULL(fa.fact_total,0)) desc) as mejor_empleado
FROM Empleado jefe
JOIN (Empleado empl JOIN Factura on empl.empl_codigo = fact_vendedor) on jefe.empl_codigo = empl.empl_jefe
WHERE YEAR(fact_fecha) = 2012 AND 10 < ALL(SELECT COUNT(DISTINCT fact_numero) FROM Empleado a 
                                            JOIN Factura ON empl_codigo = fact_vendedor 
                                            WHERE a.empl_jefe = jefe.empl_codigo
                                            GROUP BY a.empl_codigo)
GROUP BY jefe.empl_nombre, jefe.empl_apellido, jefe.empl_codigo

/* EJERCICIO 32
Se desea conocer las familias que sus productos se facturaron juntos en las mismas
facturas para ello se solicita que escriba una consulta sql que retorne los pares de
familias que tienen productos que se facturaron juntos. Para ellos deberá devolver las
siguientes columnas:
 Código de familia
 Detalle de familia
 Código de familia
 Detalle de familia
 Cantidad de facturas
 Total vendido
Los datos deberan ser ordenados por Total vendido y solo se deben mostrar las familias
que se vendieron juntas más de 10 veces.
*/

SELECT f1.fami_id, f1.fami_detalle, f2.fami_id, f2.fami_detalle, COUNT(DISTINCT i1.item_numero) as cant_facturas, SUM(i1.item_cantidad*i1.item_precio) AS total_vendido
FROM (Item_Factura i1 JOIN Producto p1 on i1.item_producto = p1.prod_codigo JOIN Familia f1 on p1.prod_familia = f1.fami_id)
JOIN (Item_Factura i2 JOIN Producto p2 on i2.item_producto = p2.prod_codigo JOIN Familia f2 on p2.prod_familia = f2.fami_id) 
    ON i1.item_numero = i2.item_numero AND i1.item_sucursal = i2.item_sucursal AND i1.item_tipo = i2.item_tipo
WHERE i1.item_producto > i2.item_producto
GROUP BY f1.fami_id, f1.fami_detalle, f2.fami_id, f2.fami_detalle
HAVING COUNT(DISTINCT i1.item_numero) > 10
ORDER BY total_vendido desc


/* EJERCICIO 33
Se requiere obtener una estadística de venta de productos que sean componentes. Para
ello se solicita que realiza la siguiente consulta que retorne la venta de los
componentes del producto más vendido del año 2012. Se deberá mostrar:
a. Código de producto
b. Nombre del producto
c. Cantidad de unidades vendidas
d. Cantidad de facturas en la cual se facturo
e. Precio promedio facturado de ese producto.
f. Total facturado para ese producto
El resultado deberá ser ordenado por el total vendido por producto para el año 2012.
*/

SELECT
    prod_codigo,
    prod_detalle,
    SUM(ISNULL(item_cantidad,0)) as unidades_vendidas,
    COUNT(DISTINCT item_numero) as cantidad_facturas,
    AVG(ISNULL(item_precio,0)) as precio_promedio,
    SUM(ISNULL((item_cantidad*item_precio),0)) as total_facturado
FROM Producto
LEFT JOIN Item_Factura on item_producto = prod_codigo
WHERE prod_codigo in (SELECT comp_componente From Composicion 
                        WHERE comp_producto = (SELECT TOP 1 comp_producto FROM Composicion
                                                JOIN Item_Factura on comp_producto = item_producto
                                                GROUP BY comp_producto
                                                ORDER BY SUM(item_cantidad*item_precio) desc))
GROUP BY prod_codigo, prod_detalle

/* EJERCICIO 34
Escriba una consulta sql que retorne para todos los rubros la cantidad de facturas mal
facturadas por cada mes del año 2011 Se considera que una factura es incorrecta cuando
en la misma factura se factutan productos de dos rubros diferentes. Si no hay facturas
mal hechas se debe retornar 0. Las columnas que se deben mostrar son:
1- Codigo de Rubro
2- Mes
3- Cantidad de facturas mal realizadas.
*/