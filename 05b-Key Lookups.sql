
/**************************************************************************************************
- Key Look ups
- Script attribution: Monica Rathbun
- Link: https://sqlespresso.com/2019/04/03/whats-a-key-lookup/
- Show how to get rid of them

- TURN ON ACTUAL QUERY PLAN

***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--CLEAN UP
--------------------------------------------------------------------------------------------------
USE [AdventureWorks2014]
GO
 
--------------------------------------------------------------------------------------------------
--DROP INDEX IF ALREADY THERE
--------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name from sys.indexes where name=N'IX_SalesOrderDetail_ProductID')
DROP INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
GO

--------------------------------------------------------------------------------------------------
--RUN SELECT WITH PLAN AND NOTE KEY LOOKUP AND OUTPUT COLUMNS
--------------------------------------------------------------------------------------------------
SELECT [SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID], [UnitPrice],[ModifiedDate] 
FROM [Sales].[SalesOrderDetail]
WHERE [ModifiedDate]> '2014/01/01'
AND [ProductID]=772
--------------------------------------------------------------------------------------------------
--CREATE INDEX
--------------------------------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]([ProductID] ASC) 
INCLUDE ([CarrierTrackingNumber],[UnitPrice], [ModifiedDate], [OrderQty]) 
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, 
ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

--------------------------------------------------------------------------------------------------
--RERUN NOTE THE PLAN
--------------------------------------------------------------------------------------------------

SELECT [SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID], [UnitPrice],[ModifiedDate] 
FROM [Sales].[SalesOrderDetail]
WHERE [ModifiedDate]> '2014/01/01'
AND [ProductID]=772
