
--  Semana 5 Bd - Consultas SQL sobre la base de datos Jardinería
--  Base de datos : jardineria
--  Descripción   : Consultas con funciones de agregación,
--                  subconsultas, JOINs y cláusulas avanzadas.
--  Tablas        : oficina, empleado, cliente, pedido,
--                  detalle_pedido, producto, gama_producto, pago=

USE jardineria;

-- 1. INFORMACIÓN BÁSICA DE LAS OFICINAS
--    Recupera el código, ciudad, país y teléfono de todas
--    las oficinas registradas.
SELECT codigo_oficina,
       ciudad,
       pais,
       telefono
FROM   oficina;


-- 2. EMPLEADOS POR OFICINA
--    Muestra el nombre, apellidos y puesto de los empleados
--    agrupados por código de oficina.

SELECT o.codigo_oficina,
       e.nombre,
       e.apellido1,
       e.apellido2,
       e.puesto
FROM   empleado e
JOIN   oficina  o ON e.codigo_oficina = o.codigo_oficina
ORDER  BY o.codigo_oficina;


-- 3. PROMEDIO DEL LÍMITE DE CRÉDITO DE CLIENTES POR REGIÓN
--    Determina el promedio del límite de crédito agrupado
--    por región.
SELECT   region,
         AVG(limite_credito) AS promedio_limite_credito
FROM     cliente
WHERE    region IS NOT NULL
GROUP BY region
ORDER BY promedio_limite_credito DESC;


-- 4. CLIENTES CON SUS REPRESENTANTES DE VENTAS
--    Recupera el nombre completo del cliente junto con el
--    nombre completo del representante de ventas asignado.
SELECT c.nombre_cliente,
       CONCAT(e.nombre, ' ', e.apellido1, ' ',
              COALESCE(e.apellido2, '')) AS representante_ventas
FROM   cliente  c
JOIN   empleado e ON c.codigo_empleado_rep_ventas = e.codigo_empleado;


-- 5. PRODUCTOS DISPONIBLES Y EN STOCK
--    Lista el código, nombre y cantidad en stock de todos los
--    productos que tienen al menos 1 unidad disponible.
SELECT  codigo_producto,
        nombre,
        cantidad_en_stock
FROM    producto
WHERE   cantidad_en_stock >= 1
ORDER BY cantidad_en_stock DESC;


-- 6. PRODUCTOS CON PRECIO POR DEBAJO DEL PROMEDIO
--    Muestra los productos cuyo precio de venta es menor que
--    el precio promedio de todos los productos.
SELECT codigo_producto,
       nombre,
       precio_venta
FROM   producto
WHERE  precio_venta < (
           SELECT AVG(precio_venta)
           FROM   producto
       )
ORDER  BY precio_venta DESC;


-- 7. PEDIDOS PENDIENTES POR CLIENTE
--    Lista el código y estado de todos los pedidos no
--    entregados junto con el nombre del cliente.
SELECT p.codigo_pedido,
       p.estado,
       c.nombre_cliente
FROM   pedido  p
JOIN   cliente c ON p.codigo_cliente = c.codigo_cliente
WHERE  p.estado <> 'Entregado'
ORDER  BY c.nombre_cliente;


-- 8. TOTAL DE PRODUCTOS POR CATEGORÍA (GAMA)
--    Obtén la cantidad total de productos agrupados por gama.
SELECT   gama,
         COUNT(*) AS total_productos
FROM     producto
GROUP BY gama
ORDER BY total_productos DESC;


-- 9. INGRESOS TOTALES GENERADOS POR CLIENTE
--    Calcula el total de ingresos de cada cliente basado en
--    los pagos realizados.
SELECT   c.nombre_cliente,
         SUM(pa.total) AS ingresos_totales
FROM     pago    pa
JOIN     cliente c ON pa.codigo_cliente = c.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY ingresos_totales DESC;


-- 10. PEDIDOS REALIZADOS EN UN RANGO DE FECHAS
--     Recupera los códigos de pedido y fechas entre dos
--     fechas específicas (ajusta según necesidad).
SELECT codigo_pedido,
       fecha_pedido
FROM   pedido
WHERE  fecha_pedido BETWEEN '2008-01-01' AND '2008-12-31'
ORDER  BY fecha_pedido;


-- 11. DETALLE DE UN PEDIDO ESPECÍFICO
--     Muestra productos, cantidades y precio total por línea
--     de un pedido dado (modifica el código según necesidad).

SELECT dp.codigo_pedido,
       dp.codigo_producto,
       p.nombre                              AS producto,
       dp.cantidad,
       dp.precio_unidad,
       (dp.cantidad * dp.precio_unidad)      AS precio_total_linea
FROM   detalle_pedido dp
JOIN   producto       p  ON dp.codigo_producto = p.codigo_producto
WHERE  dp.codigo_pedido = 1;   -- << Cambiar por el código deseado


-- 12. PRODUCTOS MÁS VENDIDOS
--     Lista los productos con mayor cantidad vendida,
--     ordenados de forma descendente.
SELECT   p.codigo_producto,
         p.nombre,
         SUM(dp.cantidad) AS cantidad_total_vendida
FROM     detalle_pedido dp
JOIN     producto       p  ON dp.codigo_producto = p.codigo_producto
GROUP BY p.codigo_producto, p.nombre
ORDER BY cantidad_total_vendida DESC;


-- 13. PEDIDOS CON VALOR TOTAL SUPERIOR AL PROMEDIO
--     Muestra los pedidos cuyo valor total supera el promedio
--     general de todos los pedidos.
SELECT   codigo_pedido,
         SUM(cantidad * precio_unidad) AS valor_total
FROM     detalle_pedido
GROUP BY codigo_pedido
HAVING   valor_total > (
             SELECT AVG(total_pedido)
             FROM (
                 SELECT SUM(cantidad * precio_unidad) AS total_pedido
                 FROM   detalle_pedido
                 GROUP  BY codigo_pedido
             ) AS sub
         )
ORDER BY valor_total DESC;


-- 14. CLIENTES SIN REPRESENTANTE DE VENTAS ASIGNADO
--     Lista los clientes que no tienen representante asociado.
SELECT codigo_cliente,
       nombre_cliente,
       ciudad,
       pais
FROM   cliente
WHERE  codigo_empleado_rep_ventas IS NULL;


-- 15. NÚMERO TOTAL DE EMPLEADOS POR OFICINA
--     Calcula la cantidad de empleados asignados a cada
--     oficina, incluyendo las que no tienen empleados.
SELECT   o.codigo_oficina,
         o.ciudad,
         COUNT(e.codigo_empleado) AS total_empleados
FROM     oficina  o
LEFT JOIN empleado e ON o.codigo_oficina = e.codigo_oficina
GROUP BY o.codigo_oficina, o.ciudad
ORDER BY total_empleados DESC;


-- 16. PAGOS REALIZADOS CON UNA FORMA DE PAGO ESPECÍFICA
--     Recupera los pagos realizados con "Tarjeta de Crédito"
--     (ajusta la forma de pago según necesidad).

SELECT c.nombre_cliente,
       pa.forma_pago,
       pa.id_transaccion,
       pa.fecha_pago,
       pa.total
FROM   pago    pa
JOIN   cliente c  ON pa.codigo_cliente = c.codigo_cliente
WHERE  pa.forma_pago = 'Tarjeta de Crédito'
ORDER  BY pa.fecha_pago DESC;



-- 17. INGRESOS MENSUALES
--     Calcula el total de ingresos generados por mes basado
--     en las fechas de pago.

SELECT   YEAR(fecha_pago)  AS año,
         MONTH(fecha_pago) AS mes,
         SUM(total)        AS ingresos_mensuales
FROM     pago
GROUP BY YEAR(fecha_pago), MONTH(fecha_pago)
ORDER BY año, mes;


-- 18. CLIENTES CON MÚLTIPLES PEDIDOS
--     Muestra los clientes que tienen más de un pedido
--     registrado.
SELECT   c.nombre_cliente,
         COUNT(p.codigo_pedido) AS total_pedidos
FROM     cliente c
JOIN     pedido  p ON c.codigo_cliente = p.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
HAVING   total_pedidos > 1
ORDER BY total_pedidos DESC;

-- 19. PEDIDOS CON PRODUCTOS AGOTADOS
--     Lista los pedidos que incluyen productos cuya cantidad
--     en stock es cero.
SELECT DISTINCT dp.codigo_pedido,
                p.codigo_producto,
                p.nombre AS producto_agotado
FROM   detalle_pedido dp
JOIN   producto       p  ON dp.codigo_producto = p.codigo_producto
WHERE  p.cantidad_en_stock = 0;


-- 20. PROMEDIO, MÁXIMO Y MÍNIMO DEL LÍMITE DE CRÉDITO POR PAÍS
--     Obtén estadísticas del límite de crédito agrupadas
--     por país.
SELECT   pais,
         AVG(limite_credito) AS promedio_limite,
         MAX(limite_credito) AS maximo_limite,
         MIN(limite_credito) AS minimo_limite
FROM     cliente
WHERE    pais IS NOT NULL
GROUP BY pais
ORDER BY promedio_limite DESC;

-- 21. HISTORIAL DE TRANSACCIONES DE UN CLIENTE
--     Recupera el historial de pagos de un cliente específico
--     (modifica el código según necesidad).

SELECT pa.fecha_pago,
       pa.total,
       pa.forma_pago,
       pa.id_transaccion
FROM   pago    pa
JOIN   cliente c  ON pa.codigo_cliente = c.codigo_cliente
WHERE  c.codigo_cliente = 1   -- << Cambiar por el código deseado
ORDER  BY pa.fecha_pago DESC;


-- 22. EMPLEADOS SIN JEFE DIRECTO ASIGNADO
--     Muestra los empleados que no tienen un código de jefe
--     registrado (generalmente la alta dirección).

SELECT codigo_empleado,
       nombre,
       apellido1,
       puesto
FROM   empleado
WHERE  codigo_jefe IS NULL;


-- 23. PRODUCTOS CUYO PRECIO SUPERA EL PROMEDIO DE SU GAMA
--     Lista los productos cuyo precio de venta es mayor que
--     el promedio de su categoría (gama).

SELECT p.codigo_producto,
       p.nombre,
       p.gama,
       p.precio_venta,
       ROUND(prom.avg_precio, 2) AS promedio_gama
FROM   producto p
JOIN   (
           SELECT gama, AVG(precio_venta) AS avg_precio
           FROM   producto
           GROUP  BY gama
       ) AS prom ON p.gama = prom.gama
WHERE  p.precio_venta > prom.avg_precio
ORDER  BY p.gama, p.precio_venta DESC;


-- 24. PROMEDIO DE DÍAS DE ENTREGA POR ESTADO
--     Calcula el promedio de días entre la fecha de pedido y
--     la fecha de entrega, agrupado por estado del pedido.
SELECT   estado,
         ROUND(AVG(DATEDIFF(fecha_entrega, fecha_pedido)), 1)
             AS promedio_dias_entrega
FROM     pedido
WHERE    fecha_entrega IS NOT NULL
GROUP BY estado
ORDER BY promedio_dias_entrega;


-- 25. PAÍSES CON CLIENTES QUE TIENEN MÁS DE UN PEDIDO
--     Lista los países con la cantidad de clientes que tienen
--     más de un pedido registrado.
SELECT   c.pais,
         COUNT(DISTINCT c.codigo_cliente) AS clientes_con_multiples_pedidos
FROM     cliente c
WHERE    c.codigo_cliente IN (
             SELECT codigo_cliente
             FROM   pedido
             GROUP  BY codigo_cliente
             HAVING COUNT(*) > 1
         )
GROUP BY c.pais
ORDER BY clientes_con_multiples_pedidos DESC;


-- FIN DEL SCRIPT - Semana 5 Bd

