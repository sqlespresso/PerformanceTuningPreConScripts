

/**************************************************************************************************
- STATISTICS IO and TIME 
- Script attribution: Monica Rathbun
- Link https://github.com/sqlespresso/PerformanceTuningPreConScripts
- Show the importance of knowing the query performance numbers when tuning

***************************************************************************************************/
--------------------------------------------------------------------------------------------------
--CLEAN UP Just in case
--------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name from sys.indexes where name = N'IDX_ProductID_UnitPrice_UnitPriceDiscount')
DROP INDEX IDX_ProductID_UnitPrice_UnitPriceDiscount ON [Sales].[SalesOrderDetail]


--------------------------------------------------------------------------------------------------
--First Query & Look at the numbers
--------------------------------------------------------------------------------------------------

USE AdventureWorks2016CTP3;  
GO
SET STATISTICS IO ON --SET STATISTICS TIME,IO ON  
GO
SET STATISTICS TIME ON;
GO  
SELECT Name, [Description],[UnitPrice],[UnitPriceDiscount]
FROM [Production].[Product] p
INNER JOIN [Production].[ProductDescription] pd
	ON p.ProductID = pd.[ProductDescriptionID]
INNER JOIN [Sales].[SalesOrderDetail] s
	ON p.[ProductID]=s.ProductID
WHERE SellEndDate is not NULL
AND UnitPrice>10.00 
AND UnitPriceDiscount<>0
ORDER BY [Name],[UnitPrice]
GO


--------------------------------------------------------------------------------------------------
-- Add Index
--------------------------------------------------------------------------------------------------

USE [AdventureWorks2016CTP3]
GO
CREATE NONCLUSTERED INDEX IDX_ProductID_UnitPrice_UnitPriceDiscount
ON [Sales].[SalesOrderDetail] ([ProductID],[UnitPrice],[UnitPriceDiscount])
GO


--------------------------------------------------------------------------------------------------
--ReRun Query & Look at the numbers
--------------------------------------------------------------------------------------------------


USE AdventureWorks2016CTP3;  
GO
SET STATISTICS IO ON
GO
SET STATISTICS TIME ON;
GO  
SELECT Name, [Description],[UnitPrice],[UnitPriceDiscount]
FROM [Production].[Product] p
INNER JOIN [Production].[ProductDescription] pd
	ON p.ProductID = pd.[ProductDescriptionID]
INNER JOIN [Sales].[SalesOrderDetail] s
	ON p.[ProductID]=s.ProductID
WHERE SellEndDate is not NULL
AND UnitPrice>10.00 
AND UnitPriceDiscount<>0
ORDER BY [Name],[UnitPrice]
GO
--------------------------------------------------------------------------------------------------
--BEFORE INDEX
--------------------------------------------------------------------------------------------------

/* SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 544 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms

Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderDetail'. Scan count 1, logical reads 455, physical reads 0, read-ahead reads 4, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'ProductDescription'. Scan count 0, logical reads 211, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Product'. Scan count 1, logical reads 15, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

--------------------------------------------------------------------------------------------------
--AFTER INDEX
--------------------------------------------------------------------------------------------------
/*  SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 176 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

Table 'SalesOrderDetail'. Scan count 10, logical reads 38, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'ProductDescription'. Scan count 0, logical reads 211, physical reads 0, read-ahead reads 8, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Product'. Scan count 1, logical reads 15, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/