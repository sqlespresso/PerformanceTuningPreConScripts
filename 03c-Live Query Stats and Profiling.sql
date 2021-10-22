
/**************************************************************************************************
- LIVE QUERY STATS AND QUERY PROFILING 
- Script attribution: Monica Rathbun
- Link: https://github.com/sqlespresso/PerformanceTuningPreConScripts
- USING LIVE QUERY STATS AND QUERY PROFILING TO TROUBLE SHOOT PLANS


- TURN ON ACTUAL QUERY PLAN
- TURN ON LIVE QUERY STATS
- TURN ON STATISTICS PROFILE ON

***************************************************************************************************/


--------------------------------------------------------------------------------------------------
-- RUN QUERY WITH STATISTICS PROFILE ON (run time 6 seconds)
--------------------------------------------------------------------------------------------------
USE Adventureworks2016CTP3
GO
SET STATISTICS PROFILE ON
GO
SELECT *
FROM Sales.SalesOrderDetail od,Sales.SalesOrderHeader oh
WHERE oh.SalesOrderID = od.SalesOrderID

--------------------------------------------------------------------------------------------------
-- DISPLAY RESULTS & THEN TURN OFF STATS PROFILE
--------------------------------------------------------------------------------------------------
SET STATISTICS PROFILE OFF
GO

--------------------------------------------------------------------------------------------------
-- RERUN QUERY WITH LIVE QUERY STATS ON
--------------------------------------------------------------------------------------------------
USE Adventureworks2016CTP3
GO
SELECT *
FROM Sales.SalesOrderDetail od,Sales.SalesOrderHeader oh
WHERE oh.SalesOrderID = od.SalesOrderID
