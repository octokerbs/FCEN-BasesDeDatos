-- Queries Auxiliares
SELECT 
    object_name(cols.object_id) tabla
    ,cols.name columna
    ,ind.name indice
    ,ind.type_desc tipo
    ,ind.is_unique 
    FROM 
    sys.columns cols, sys.indexes ind , sys.index_columns ind_cols
    where 
    cols.object_id = ind.object_id
    and cols.object_id = ind_cols.object_id
    and cols.column_id = ind_cols.column_id
    and ind.index_id = ind_cols.index_id
    and object_name(cols.object_id) LIKE 'Person'
    order by object_name(cols.object_id), ind.name;

SELECT TABLE_NAME, COLUMN_NAME, IS_NULLABLE, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'Person';

-- 1
SELECT P.Name , P.ProductNumber
FROM Production.Product P
WHERE ProductNumber ='EC-R098'
-- El plan comienza con un Non-Clustered Index Seek en AK_Product_ProductNumber para encontrar la(s) fila(s) que cumplen con ProductNumber ='EC-R098'.
-- El índice no agrupado contiene la clave de búsqueda (ProductNumber) y un puntero a la fila de datos. En una tabla agrupada, este puntero siempre es la clave agrupada (ProductID).
-- La columna Name no está en el índice AK_Product_ProductNumber. Por lo tanto, SQL Server debe realizar un Key Lookup (una búsqueda secundaria usando el ProductID recuperado) en el índice PK_Product_ProductID para obtener el valor de la columna Name.

SELECT P.ProductID , P.ProductNumber
FROM Production.Product P
WHERE ProductNumber ='EC-R098'

--- El índice AK_Product_ProductNumber contiene dos cosas: 1. La clave de búsqueda (ProductNumber). 2. El puntero a la fila de datos, que, al ser una tabla agrupada, es la clave agrupada (ProductID).


-- 2
SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 58950

SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID = 68531

-- De todas las filas de SalesOrderDetail queremos las que tienen el mismo SalesOrderID (los items que pertenecen a la misma orden).
-- Las SalesOrderID estan clusterizadas. Hacemos directamente un clustered index seek y traemos la fila.
-- En PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID, SalesOrdereID + SalesOrderDetailID son la primary key de SalesOrderDetail.
-- Agarramos todas las filas que tienen SalesOrderID como indice de la clave compuesta.

-- No se puede hacer un clustered index seek porque el SalesOrderDetailID no es prefijo de indice.
-- El motor prefiere hacer un index scan de la NonClustered ProductID. 
-- La consulta solo pide SalesOrderID y SalesOrderDetailID. Estas dos columnas son las claves del índice clúster, lo que significa que cualquier 
-- índice (clúster o no clúster) que se use ya incluye estas columnas (porque los índices no clúster de SQL Server usan las claves clúster como sus 
-- row locators si la tabla tiene índice clúster). Por lo tanto, no se necesitaría un Key Lookup si se usara un índice no clúster, ya que las columnas 
-- solicitadas ya están en su clave.
-- Asumiria que la Nonclustered index IX_SalesOrderDetail_ProductID tiene una sola entrada de SalesOrderDetailID y es muy chiquita, por lo que es mas 
-- eficiente que  hacer un clustered scan de PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID

-- 3
SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43683 AND SalesOrderDetailID = 240

SELECT SalesOrderID, SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43683 OR SalesOrderDetailID = 240

-- Simplemente se hace un index seek del cluster, primer se indexea el SalesOrderID y luego el SalesOrderDetailID

-- Queremos el SalesOrderID y SalesOrderDetailID de los SalesOrderDetail que cumplen la condicion.
-- Como lo que queremos es casulamente los indices, es mas barato traerse el nonclustered index y hacer el scan. (La hoja solo nos da los indices)
-- que traerse la tabla entera con todas las filas (los indices + el resto de la fila)
-- Si nos pidieran otro dato, ahi creo que seria mas barato el table scan (porque haciendo esto necesitamos un key lookup que es caro)
-- El Optimizador determina que, para obtener solo las dos columnas requeridas, es más barato y rápido escanear un índice no agrupado estrecho que escanear el índice agrupado completo (la tabla ancha), incluso si este último permite un Seek parcial para la primera parte del OR.

-- 4

--  ProductVendor	BusinessEntityID	IX_ProductVendor_BusinessEntityID	        NONCLUSTERED	0
--  ProductVendor	UnitMeasureCode	    IX_ProductVendor_UnitMeasureCode	        NONCLUSTERED	0
--  ProductVendor	BusinessEntityID	PK_ProductVendor_ProductID_BusinessEntityID	CLUSTERED	    1
--  ProductVendor	ProductID	        PK_ProductVendor_ProductID_BusinessEntityID	CLUSTERED	    1

--  Vendor	AccountNumber	    AK_Vendor_AccountNumber	    NONCLUSTERED	1
--  Vendor	BusinessEntityID	PK_Vendor_BusinessEntityID	CLUSTERED	    1

SELECT ProductID, PV.BusinessEntityID, Name
FROM Purchasing.ProductVendor PPV JOIN Purchasing.Vendor PV ON PPV.BusinessEntityID = PV.BusinessEntityID

-- _ProductVendor_ tiene ProductID y BusinessEntityID clusterizados.
-- _Vendor_ solo tiene BusinessEntityID clusterizado.

-- Se hace un index scan de ProductVendor para agarrar a todos sus BusinessEntityID (va a ser usada para el join). 
-- el engine parece que decidio ir por este camino agarrar el ProductID del unclustered index IX_ProductVendor_BusinessEntityID es mas eficioente
-- que recorrer el clustered index (trayendo banda de filas que no nos sirven.) 

-- Clustered index scan porque los indices son lo que nos piden (BusinessEntityID). El motor necesita leer todas las filas de la tabla Vendor porque no hay un filtro WHERE. Además, para obtener la columna Name (que no está en los índices no agrupados), debe escanear el índice agrupado (que es la tabla física).

-- Se hace un merge join porque los BusinessEntityID son unicos y estan ordenados (lo dice la tabla cuando la clickeas)

SELECT ProductID, PV.BusinessEntityID, Name
FROM Purchasing.ProductVendor PPV JOIN Purchasing.Vendor PV ON PPV.BusinessEntityID = PV.BusinessEntityID
WHERE StandardPrice > $10

-- ProductVendor hace un Clustered Index Scan. 
-- No solo se necesita el ProductID si no tambien su precio. 
-- No se puede hacer Clustered index seek porque no tenemos el BusinessEntityID ni el ProductID. 
-- Es mas barato hacer un Clustered Index Scan y traer el ProductID + StandardPrice que un Index Scan de una tabla non clustered 
-- (IX_Product_Vendor_BusinessEntityID) + key lookup.

-- Vendor hace un Clustered Index Scan.
-- No hace clustered index seek porque no tenemos el BusinessEntityID. 
-- Vendor no tiene otras non clustered index.

-- Se hace un hash match porque ambas tablas son relativamente grandes y no estan ordenadas. 

SELECT ProductID, PV.BusinessEntityID, Name
FROM Purchasing.ProductVendor PPV JOIN Purchasing.Vendor PV ON PPV.BusinessEntityID =PV.BusinessEntityID
WHERE StandardPrice > $10 AND Name LIKE N'F%'

-- El Nested loop escanea todos los indices del vendor.
-- Para cada fila del Vendor, hacemos un index seek de IX_ProductVendor_BusinessEntityID con el BusinessEntityID -> VendorRow + (ProductID, BusinessEntityID)
-- Para cada VendorRow + (ProductID, BusinessEntityID) tal que VendorRow.BusinessEntityID = BusinessEntityID: Hacemos un key lookup
-- del Product Vendor para obtnere el precio. 
-- COmo ya teniamos la VendorRow, tenemos mergeado el nombre

-- 5

-- Product	Name	        AK_Product_Name	            NONCLUSTERED	1
-- Product	ProductNumber	AK_Product_ProductNumber	NONCLUSTERED	1
-- Product	rowguid	        AK_Product_rowguid	        NONCLUSTERED	1
-- Product	ProductID	    PK_Product_ProductID	    CLUSTERED	    1

-- ProductSubcategory	Name	                AK_ProductSubcategory_Name	                NONCLUSTERED	1
-- ProductSubcategory	rowguid	                AK_ProductSubcategory_rowguid	            NONCLUSTERED	1
-- ProductSubcategory	ProductSubcategoryID	PK_ProductSubcategory_ProductSubcategoryID	CLUSTERED	    1

SELECT P.Name, PSC.Name SubCatrom   -- Alias para el name de la subcategoria
FROM Production.Product P
JOIN Production.ProductSubcategory PSC
ON p.ProductSubcategoryID = psc.ProductSubcategoryID

-- Se hace un Index Scan sobre AK_ProductSubcategory_Name obteniendo todos los ProductSubcategory.Name y ProductSubcategoryID (por ser unclustered)

-- Se hace un Clustered Index Scan sobre PK_Product_ProductID obteniendo todas las filas de Product.

-- SQLServer decide hacer un Hash Join porque las tablas son muy grandes para un Loop Join.


SELECT P.Name, PSC.Name SubCatrom
FROM Production.Product P
JOIN Production.ProductSubcategory PSC
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
ORDER BY psc.ProductSubcategoryID

-- Clustered Index Scan sobre PK_ProductSubcategoryID obteniendo todos los ProductSubcategoryID.

-- Clustered Index Scan sobre PK_PRODUCT_PRODUCT_ID obteniendo todos los PRODUCT_ID.

-- Se hace un Sort del Clustered index scan

-- Como se compara por ProductSubcategoryID, y el cluster de ProductSubcategory_ProductSubcategoryID esta ordenado por ProductSubcategoryID y se nos pide ordenar la respuesta por 
-- ProductSubcategoryID. El engine decide ordenar la tabla de Productos en base al ProductSubcategoryID para hacer un mergesort.


-- 6

-- Person	rowguid	                AK_Person_rowguid	                    NONCLUSTERED	1
-- Person	FirstName	            IX_Person_LastName_FirstName_MiddleName	NONCLUSTERED	0
-- Person	LastName	            IX_Person_LastName_FirstName_MiddleName	NONCLUSTERED	0
-- Person	MiddleName	            IX_Person_LastName_FirstName_MiddleName	NONCLUSTERED	0
-- Person	BusinessEntityID	    PK_Person_BusinessEntityID	            CLUSTERED	    1
-- Person	AdditionalContactInfo	PXML_Person_AddContact	                XML	            0
-- Person	Demographics	        PXML_Person_Demographics	            XML	            0
-- Person	Demographics	        XMLPATH_Person_Demographics	            XML	            0
-- Person	Demographics	        XMLPROPERTY_Person_Demographics	        XML	            0
-- Person	Demographics	        XMLVALUE_Person_Demographics	        XML	            0

SELECT count(NameStyle) FROM Person.Person

-- Index Scan de AK_PERSON_ROWGUID
-- El motor de SQL Server obtiene una lista de todos los valores rowguid, y para cada uno, obtiene su correspondiente BusinessEntityID. 
-- Se obtienen todos los rowguid + BusinessEntityID.

SELECT count(Title) FROM Person.Person

-- Clustered Index Scan