Duplicados. Se eliminaron por la columna de ID (id_cliente y id_producto) y no por todas las columnas, porque lo que define la unicidad de una dimensión es su clave primaria. Con un ID repetido, Power BI no puede crear la relación 1:N con la tabla de hechos, y un merge duplicaría las ventas de ese registro.

Clientes con nulos (se reemplazan, no se eliminan).

Cliente 9 (Valentina Paz), email nulo: tiene ventas registradas. Eliminarlo dejaría ventas sin cliente. El email no participa en ningún cálculo, así que se reemplaza por "Sin dato".
Cliente 11 (Roberto Díaz), ciudad nula: el origen no permite deducirla. Se reemplaza por "Sin dato" para que aparezca como categoría explícita en los análisis por ciudad y no como "(En blanco)".

Productos con nulos.

Producto 109 (SSD Externo 1TB), precio nulo: es un campo crítico porque sin precio no se calcula ingreso. No se elimina porque tiene 7 ventas asociadas. Se imputa 130, que es el precio unitario con el que figura en todas sus ventas, así que el valor está respaldado por los datos.
Producto 111 (Laptop Gaming Pro), categoría nula: su subcategoría es "Laptops" y todos los productos de esa subcategoría pertenecen a Computación, por lo que se le asigna esa categoría. Marcarlo como "Sin Categoría" dejaría fuera del análisis por categoría al producto de mayor precio del catálogo.

Conteo final: Dim_Clientes 11, Dim_Productos 12, Fact_Ventas 50, Dim_Categorias 4.
