
/**************************************************************************************************
- Creating and using a Columnstore 
- Script attribution: Monica Rathbun
- Link: https://github.com/sqlespresso/PerformanceTuningPreConScripts
- Show how to create a column store index
- Show the columnstore in system table

- TURN ON ACTUAL QUERY PLAN
- TURN ON STATS IO/TIME

***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--SET UP WHICH I HAVE ALREADY DONE
--------------------------------------------------------------------------------------------------
/*

USE [AdventureworksDW2016CTP3]
GO
--------------------------------------------------------------------------------------------------
-- POPULATE AN EXAMPLE TABLE & ADD MATCHING CONSTRAINTS 
--------------------------------------------------------------------------------------------------
SELECT * INTO FactResellerSalesXL 
FROM FactResellerSalesXL_CCI

USE [AdventureworksDW2016CTP3]
GO

SET ANSI_PADDING ON
GO


ALTER TABLE [dbo].[FactResellerSalesXL] ADD  CONSTRAINT [PK_FactResellerSalesXL_SalesOrderNumber_SalesOrderLineNumber] PRIMARY KEY NONCLUSTERED 
(
	[SalesOrderNumber] ASC,
	[SalesOrderLineNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

*/


--------------------------------------------------------------------------------------------------
-- TURN ON STATS IO & TIME
--RUN TIME 30 seconds
--------------------------------------------------------------------------------------------------
USE AdventureWorksDW2016CTP3;  
GO
SET STATISTICS IO ON
GO
SET STATISTICS TIME ON;
GO  

--------------------------------------------------------------------------------------------------
-- RUN QUERY WITHOUT INDEX & LOOK AT PLAN AND STATS
--------------------------------------------------------------------------------------------------

SELECT ProductKey, sum(SalesAmount) SalesAmount, sum(OrderQuantity) ct
FROM dbo.FactResellerSalesXL
GROUP BY ProductKey


--------------------------------------------------------------------------------------------------
-- ADD CS INDEX -- TAKES 3 mins 
-- bot running in DEMO use CCI table which is same table but has index
--------------------------------------------------------------------------------------------------

--USE [AdventureworksDW2016CTP3]

--GO

--CREATE CLUSTERED COLUMNSTORE INDEX [CS_IDX_FactResellerSalesXL_CCI] ON [dbo].[FactResellerSalesXL_CCI] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)

--GO

--------------------------------------------------------------------------------------------------
--RUN QUERY AGAIN
--------------------------------------------------------------------------------------------------

USE AdventureWorksDW2016CTP3;  
GO
SET STATISTICS IO ON
GO
SET STATISTICS TIME ON;
GO  

SELECT ProductKey, sum(SalesAmount) SalesAmount, sum(OrderQuantity) ct
FROM dbo.FactResellerSalesXL_CCI
GROUP BY ProductKey

--------------------------------------------------------------------------------------------------
--REVIEW THE NUMBERS & PLAN
--------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
--LETS LOOK AT INSIGHTS

--LOOK AT COLUMN STORE SEGMENTS
--------------------------------------------------------------------------------------------------
SELECT * FROM sys.column_store_segments

SELECT i.name, p.object_id, p.index_id, i.type_desc,   
    COUNT(*) AS number_of_segments  
FROM sys.column_store_segments AS s   
INNER JOIN sys.partitions AS p   
    ON s.hobt_id = p.hobt_id   
INNER JOIN sys.indexes AS i   
    ON p.object_id = i.object_id  
WHERE i.type = 5 OR i.type = 6  
GROUP BY i.name, p.object_id, p.index_id, i.type_desc ;  
GO  

--------------------------------------------------------------------------------------------------
--LOOK AT ROW GROUPS
--------------------------------------------------------------------------------------------------

SELECT * FROM sys.column_store_row_groups
ORDER BY row_group_id

