
--Active Transactions
sp_whoisactive
@get_plans=1

-------------------------------------------------
--PREP
--TURN ON ACTUAL 
-------------------------------------------------
-------------------------------------------------
-- FIND COMPILED VARIABLES -- XML View
-------------------------------------------------
USE AdventureWorks2019

DECLARE @SalesPersonID int;
SET @SalesPersonID = 277;
SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID= @SalesPersonID

-------------------------------------------------------------
--  LIVE QUERY STATS (Turn ON)
-------------------------------------------------------------

SELECT *
FROM Sales.SalesOrderDetail SOD
INNER JOIN Production.Product P ON SOD.ProductID = P.ProductID
ORDER BY Style


SELECT *
FROM Sales.SalesOrderDetail od,Sales.SalesOrderHeader oh
WHERE oh.SalesOrderID = od.SalesOrderID



-----------------------------------------------------------------------
-- KEY LOOKUP, MISSING INDEX, COVERING, SCAN Sales Order Header
-----------------------------------------------------------------------
USE AdventureWorks2019
DBCC FreeProcCache -- DO NOT RUN IN PRODUCTION!!!!!

SELECT     soh.SalesPersonID,
           soh.OrderDate,
           SUM(sod.OrderQty * sod.UnitPrice) AS TotalLinePrice
FROM       Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
   ON      sod.SalesOrderID = soh.SalesOrderID
WHERE      CONVERT(char(10), soh.OrderDate, 103) LIKE '__/07/2011'
AND        soh.SalesPersonID IS NOT NULL
AND        sod.ProductID = 707
GROUP BY   soh.SalesPersonID,
           soh.OrderDate;


---ORIGINAL
CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--FIX KEY LOOKUP
CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC
)
INCLUDE ([OrderQty],[UnitPrice])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, 
DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SELECT     soh.SalesPersonID,
           soh.OrderDate,
           SUM(sod.OrderQty * sod.UnitPrice) AS TotalLinePrice
FROM       Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
   ON      sod.SalesOrderID = soh.SalesOrderID
WHERE      CONVERT(char(10), soh.OrderDate, 103) LIKE '__/07/2011'
AND        soh.SalesPersonID IS NOT NULL
AND        sod.ProductID = 707
GROUP BY   soh.SalesPersonID,
           soh.OrderDate;


--Let's take a different index strategy route COVER THE JOIN
CREATE NONCLUSTERED INDEX [IDX_SalesOrderDetail_ProductID_SalesOrderID] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC,
	SalesOrderID ASC
)
INCLUDE ([OrderQty],[UnitPrice])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, 
DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--FIX SCAN ON SALES ORDER HEADER
CREATE NONCLUSTERED INDEX [IDX_SalesOrderHeader_SalesPersonID]
ON [Sales].[SalesOrderHeader] ([SalesPersonID])
INCLUDE ([OrderDate])


----CLEAN UP
--DROP INDEX [IDX_SalesOrderDetail_ProductID_SalesOrderID]ON [Sales].[SalesOrderDetail]

--CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
--(
--	[ProductID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 
--SORT_IN_TEMPDB = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

--DROP INDEX IDX_SalesOrderHeader_SalesPersonID ON [Sales].[SalesOrderHeader]

