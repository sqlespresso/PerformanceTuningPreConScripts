

/**************************************************************************************************
- Index Cost and Benefits
- Script attribution: Monica Rathbun
- Link: https://github.com/sqlespresso/PerformanceTuningPreConScripts
- Show how adding an index increase cost of inserts
- Show the benefits of the index on reads

- TURN ON ACTUAL QUERY PLAN
- TURN ON STATS IO/TIME

***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--CLEAN UP
--------------------------------------------------------------------------------------------------
USE [AdventureworksDW2016CTP3]
GO
 
--------------------------------------------------------------------------------------------------
--DROP INDEX IF ALREADY THERE
--------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sys.indexes WHERE name=N'IDX_OrderDate')
DROP INDEX [IDX_OrderDate] ON [dbo].[FactResellerSalesXL]
GO
--------------------------------------------------------------------------------------------------
--DELETE RECORDS IF YOU TESTED PRIOR PK ON TABLE
--------------------------------------------------------------------------------------------------

DELETE FROM [FactResellerSalesXL]
WHERE SalesOrderNumber in ('S09999999','S09999997')

--------------------------------------------------------------------------------------------------
--START
--------------------------------------------------------------------------------------------------
USE [AdventureworksDW2016CTP3]
GO
SET STATISTICS IO ON
GO
SET STATISTICS TIME ON;
GO  
SELECT [OrderDate],[UnitPrice],[OrderQuantity]
FROM [dbo].[FactResellerSalesXL]
WHERE ORDERDATE='2010-05-05'

--cpu time 3954 elapsed time- 12677
--scan count 3 and logical reads 315398

--------------------------------------------------------------------------------------------------
--INSERT WITH NO INDEX
--------------------------------------------------------------------------------------------------
USE [AdventureworksDW2016CTP3]
GO
SET STATISTICS IO ON
GO
SET STATISTICS TIME ON;
GO  

INSERT INTO [dbo].[FactResellerSalesXL]
           SELECT top 1 [ProductKey]
           ,[OrderDateKey]
           ,[DueDateKey]
           ,[ShipDateKey]
           ,[ResellerKey]
           ,[EmployeeKey]
           ,[PromotionKey]
           ,[CurrencyKey]
           ,[SalesTerritoryKey]
           ,'S09999999'--change this number 
           ,[SalesOrderLineNumber]
           ,[RevisionNumber]
           ,[OrderQuantity]
           ,[UnitPrice]
           ,[ExtendedAmount]
           ,[UnitPriceDiscountPct]
           ,[DiscountAmount]
           ,[ProductStandardCost]
           ,[TotalProductCost]
           ,[SalesAmount]
           ,[TaxAmt]
           ,[Freight]
           ,[CarrierTrackingNumber]
           ,[CustomerPONumber]
           ,[OrderDate]
           ,[DueDate]
           ,[ShipDate] FROM [dbo].[FactResellerSalesXL] 
  
GO
--------------------------------------------------------------------------------------------------
--LOOK AT STATS IO and ACTUAL PLAN

--INSERT takes approx 82ms
--------------------------------------------------------------------------------------------------
  
--------------------------------------------------------------------------------------------------
--ADD INDEX
--------------------------------------------------------------------------------------------------
CREATE INDEX [IDX_OrderDate] ON [dbo].[FactResellerSalesXL](OrderDate) 
--Takes 23 seconds 

--------------------------------------------------------------------------------------------------
--RUN ANOTHER INSERT
--------------------------------------------------------------------------------------------------

INSERT INTO [dbo].[FactResellerSalesXL]
           SELECT top 1 [ProductKey]
           ,[OrderDateKey]
           ,[DueDateKey]
           ,[ShipDateKey]
           ,[ResellerKey]
           ,[EmployeeKey]
           ,[PromotionKey]
           ,[CurrencyKey]
           ,[SalesTerritoryKey]
           ,'S09999996'--change this number 
           ,[SalesOrderLineNumber]
           ,[RevisionNumber]
           ,[OrderQuantity]
           ,[UnitPrice]
           ,[ExtendedAmount]
           ,[UnitPriceDiscountPct]
           ,[DiscountAmount]
           ,[ProductStandardCost]
           ,[TotalProductCost]
           ,[SalesAmount]
           ,[TaxAmt]
           ,[Freight]
           ,[CarrierTrackingNumber]
           ,[CustomerPONumber]
           ,[OrderDate]
           ,[DueDate]
           ,[ShipDate] FROM [dbo].[FactResellerSalesXL] 
 

--------------------------------------------------------------------------------------------------
--LOOK AT STATS IO and ACTUAL PLAN

--INSERT now takes approx 18 ms Cost increase
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- RUN QUERY AGAIN AND SEE INDEX BENEFITS
--------------------------------------------------------------------------------------------------
SELECT [OrderDate],[UnitPrice],[OrderQuantity]
FROM [dbo].[FactResellerSalesXL]
WHERE ORDERDATE='2010-05-05 00:00:00.000'

--------------------------------------------------------------------------------------------------
-- ***SUMMARY**
-- AFTER INDEX
-- CPU Time 63 elasped time 488
-- 1 scan and logical reads 6406

-- WITHOUT INDEX
-- cpu time 3954 elapsed time- 12677
-- scan count 3 and logical reads 315398


--------------------------------------------------------------------------------------------------