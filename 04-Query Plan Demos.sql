-------------------------------------------------
--PREP
--TURN ON ACTUAL and LIVE QUERY STATS
-------------------------------------------------
-------------------------------------------------
-- FIND COMPILED VARIABLES
-------------------------------------------------

DECLARE @SalesPersonID int;
SET @SalesPersonID = 277;
SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID= @SalesPersonID

-------------------------------------------------------------
-- SORT WARNING, SPILL TO TEMPDB, LIVE QUERY STATS (Turn ON)
-------------------------------------------------------------

SELECT *
FROM Sales.SalesOrderDetail SOD
INNER JOIN Production.Product P ON SOD.ProductID = P.ProductID
ORDER BY Style


SELECT *
FROM Sales.SalesOrderDetail od,Sales.SalesOrderHeader oh
WHERE oh.SalesOrderID = od.SalesOrderID



-----------------------------------------------------------------------
-- KEY LOOKUP, IMPLICIT CONVERSION, MISSING INDEX, COVERING, SCAN
-----------------------------------------------------------------------


SELECT     soh.SalesPersonID,
           soh.OrderDate,
           SUM(sod.OrderQty * sod.UnitPrice) AS TotalLinePrice
FROM       Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
   ON      sod.SalesOrderID = soh.SalesOrderID
WHERE      CONVERT(char(10), soh.OrderDate, 103) LIKE '__/07/2010'
AND        soh.SalesPersonID IS NOT NULL
AND        sod.ProductID = 707
GROUP BY   soh.SalesPersonID,
           soh.OrderDate;


---ORIGINAL
--CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
--(
--	[ProductID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--GO

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

--COVER THE JOIN
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


--CLEAN UP
--DROP INDEX [IDX_SalesOrderDetail_ProductID_SalesOrderID]ON [Sales].[SalesOrderDetail]

--CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
--(
--	[ProductID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 
--SORT_IN_TEMPDB = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

--DROP INDEX IDX_SalesOrderHeader_SalesPersonID ON [Sales].[SalesOrderHeader]

-------------------------------------------------------------
-- LIVE QUERY STATS
-------------------------------------------------------------

SELECT *
FROM Sales.SalesOrderDetail od,Sales.SalesOrderHeader oh
WHERE oh.SalesOrderID = od.SalesOrderID


/**************************************************************************************************
- Table Variable Deffered Compilataion Demo
***************************************************************************************************/

--------------------------------------------------------------------------------------------------
-- Step 1: Create the stored procedure to use a table variable. 
--------------------------------------------------------------------------------------------------
USE WideWorldImporters
GO
CREATE or ALTER PROCEDURE [Sales].[CustomerProfits]
AS
BEGIN
-- Declare the table variable
DECLARE @ilines TABLE
(	[InvoiceLineID] [int] NOT NULL primary key,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
)
-- Insert all the rows from InvoiceLines into the table variable
INSERT INTO @ilines SELECT * FROM Sales.InvoiceLines

-- Find my total profile by customer
SELECT TOP 1 COUNT(i.CustomerID) as customer_count, SUM(il.LineProfit) as total_profit
FROM Sales.Invoices i
INNER JOIN @ilines il
ON i.InvoiceID = il.InvoiceID
GROUP By i.CustomerID
END
GO

--------------------------------------------------------------------------------------------------
-- Step 2: Set to a lower compat
--------------------------------------------------------------------------------------------------


USE MASTER
GO
ALTER DATABASE WideWorldImporters SET compatibility_level = 130
GO

--------------------------------------------------------------------------------------------------
-- Step 3: Run the stored procedure under dbcompat = 130
--------------------------------------------------------------------------------------------------

USE WideWorldImporters
GO

EXEC [Sales].[CustomerProfits]


GO
--------------------------------------------------------------------------------------------------
-- Step 4: Run the stored procedure under dbcompat = 130
--------------------------------------------------------------------------------------------------
USE master
GO
ALTER DATABASE wideworldimporters SET compatibility_level = 150
GO
USE WideWorldImporters
GO

EXEC [Sales].[CustomerProfits]
--GO 25

GO


