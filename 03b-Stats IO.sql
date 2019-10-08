

/**************************************************************************************************
- STATISTICS IO and TIME 
- Script attribution: Monica Rathbun
- Link 
- Show the importance of knowing the query performance numbers when tuning

***************************************************************************************************/
--------------------------------------------------------------------------------------------------
--CLEAN UP Just in case
--------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name from sys.indexes where name = N'IDX_UnitPrice_UnitPriceDiscount')
DROP INDEX IDX_UnitPrice_UnitPriceDiscount ON [Sales].[SalesOrderDetail]


--------------------------------------------------------------------------------------------------
--First Query & Look at the numbers
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
AND UnitPrice>100.00 
AND UnitPriceDiscount<>0
ORDER BY [Name],[UnitPrice]
GO

--------------------------------------------------------------------------------------------------
-- Add Index
--------------------------------------------------------------------------------------------------

USE [AdventureWorks2016CTP3]
GO
CREATE NONCLUSTERED INDEX IDX_UnitPrice_UnitPriceDiscount
ON [Sales].[SalesOrderDetail] ([UnitPrice],[UnitPriceDiscount])
INCLUDE ([ProductID])
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
