
/**************************************************************************************************
- Sort Spill examples
- Script attribution: Tiger Team Toolbox Show Plan scripts can be found on Git hub
- Link https://github.com/microsoft/sql-server-samples/tree/master/samples/demos/Showplan
- Show Excution plan Sort Spill to TEMPDB examples

- TURN ON QUERY PLAN
- Observe the type of Spill = 1
- Means one pass over the data was enough to complete the sort in the Worktable

***************************************************************************************************/


USE AdventureWorks2016CTP3
GO 

--------------------------------------------------------------------------------------------------
--Execute to Free Proc Cache
--------------------------------------------------------------------------------------------------
DBCC FREEPROCCACHE
GO
--------------------------------------------------------------------------------------------------
--Execute  
--------------------------------------------------------------------------------------------------
SELECT *
FROM Sales.SalesOrderDetail SOD
INNER JOIN Production.Product P ON SOD.ProductID = P.ProductID
ORDER BY Style
OPTION (QUERYTRACEON 9481) --  reverts query compilation and execution to the pre-SQL Server 2014 legacy CE behavior (to force a spill)
GO

