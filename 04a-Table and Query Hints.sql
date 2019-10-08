

/**************************************************************************************************
- Using Table Hints
- Script1  attribution: Monica Rathbun
- Link: 
- Script 2 attribution: Amit Bansal
- Link: https://www.sqlservergeeks.com/sql-server-using-optimize-for-query-hint/

- Show how adding table hint can help FASTn and OPTIMIZE FOR


- TURN ON ACTUAL QUERY PLAN
- TURN ON STATS IO/TIME

***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--NORMAL RUN
--------------------------------------------------------------------------------------------------
USE AdventureWorksDW2016CTP3
GO
SET STATISTICS TIME, IO ON --NOTE THE ONE LINE
GO
SELECT [OrderDate],[UnitPrice],[OrderQuantity]
FROM [dbo].[FactResellerSalesXL]
ORDER BY OrderDate
GO    
--------------------------------------------------------------------------------------------------
--NOTE NOTHING IN RESULTS WINDOW AND IT'S STILL RUNNING - CANCEL QUERY
--------------------------------------------------------------------------------------------------

SELECT [OrderDate],[UnitPrice],[OrderQuantity]
FROM [dbo].[FactResellerSalesXL]
ORDER BY OrderDate
OPTION ( FAST 75);  
GO    
--------------------------------------------------------------------------------------------------
--NOTE THE RESULTS START POPULTING
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--NEXT SAMPLE OPTIMIZE FOR
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--GREAT FOR PARAMETER SNIFFING & YEAR Changes
--------------------------------------------------------------------------------------------------

USE AdventureWorks2016CTP3
GO
 
DBCC FREEPROCCACHE;
Go
 
SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID=288
----------------------------------------------------------------------------
-- NOTE ROW COUNTS
----------------------------------------------------------------------------
SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID=277
----------------------------------------------------------------------------
-- NOTE ROW COUNTS
----------------------------------------------------------------------------
--The difference between the above two queries is just the constant value. 
--Thus, the optimizer sniffs the values, uses statistics, computes the correct 
--cardinality estimation and produces an optimized plan, which in our case is different.
----------------------------------------------------------------------------
-- PARAMETERIZE TO TAKE ADVANTAGE OF PLAN REUSE
----------------------------------------------------------------------------
DECLARE @SalesPersonID int;
SET @SalesPersonID = 288;
SELECT SalesOrderId, OrderDate
from Sales.SalesOrderHeader
WHERE SalesPersonID= @SalesPersonID
 
 GO
 
DECLARE @SalesPersonID int;
SET @SalesPersonID = 277;
SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID= @SalesPersonID
GO
----------------------------------------------------------------------------
-- OPTIMIZE 
-- Now run the same queries again, but this time using a variable and observe the execution plan.
-- You will observe that both the above queries produce the same hash match plan. 
-- Simply because now the optimizer does not get the variable value until runtime and uses default selectivity
----------------------------------------------------------------------------

DECLARE @SalesPersonID int;
SET @SalesPersonID = 277;
SELECT SalesOrderId, OrderDate
from Sales.SalesOrderHeader
WHERE SalesPersonID= @SalesPersonID
OPTION (OPTIMIZE FOR (@SalesPersonID = 288));
GO
SET STATISTICS TIME, IO OFF
GO
----------------------------------------------------------------------------
--Now, whatever be your sales person id, you will always get a nested loop plan. 
--OPTIMIZE FOR hint now instructs the query optimizer to use 288 for @SalesPersonID 
--when the query is compiled and optimized. This value is used only during query optimization, 
--and not during query execution.
----------------------------------------------------------------------------