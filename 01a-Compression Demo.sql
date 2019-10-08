
/**************************************************************************************************
- Compression Estimates
- Script attribution: Example script can be found on msdoc
- Link https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-estimate-data-compression-savings-transact-sql?view=sql-server-2017
- Using sp_estimate_data_compression_savings to estimate table or index\partition 
--compression saving by type

***************************************************************************************************/



----------------------------------------------------------------------------------------------------
---- POPULATE AN EXAMPLE TABLE 
----------------------------------------------------------------------------------------------------
--USE [AdventureworksDW2016CTP3]
--GO
--SELECT * INTO FactResellerSalesXL 
--FROM FactResellerSalesXL_CCI

-- RUN TIME 4 seconds
-- RUN EACH TYPE AND COMPARE (non columnstore)

-- ROW EXAMPLE
USE AdventureworksDW2016CTP3;  
GO  
EXEC sp_estimate_data_compression_savings 
'dbo', --SCHEMA
'FactResellerSalesXL', --TABLE
NULL, --INDEX ID
NULL, --PARTITION
'ROW' ;  --NONE, ROW, PAGE, COLUMNSTORE, or COLUMNSTORE_ARCHIVE
GO  

--PAGE EXAMPLE
USE AdventureworksDW2016CTP3;  
GO  
EXEC sp_estimate_data_compression_savings 
'dbo', --SCHEMA
'FactResellerSalesXL', --TABLE
NULL, --INDEX ID
NULL, --PARTITION
'PAGE' ;  --NONE, ROW, PAGE, 
--COLUMNSTORE, or COLUMNSTORE_ARCHIVE
GO  




