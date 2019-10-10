
/**************************************************************************************************
- TESTING SETUP
- Script attribution: Monica Rathbun

***************************************************************************************************/
--------------------------------------------------------------------------------------------------
--FOR TESTING MAKE SURE YOU HAVE SP_WHOISACTIVE installed
--------------------------------------------------------------------------------------------------

sp_whoisactive @get_plans=1

--------------------------------------------------------------------------------------------------
--RESTORE ALL DATABASES
--------------------------------------------------------------------------------------------------

RESTORE filelistonly FROM DISK = 'C:\Users\mradmin\Dropbox\Precon\AdventureWorks2014.bak'
RESTORE headeronly FROM DISK = 'C:\Users\mradmin\Dropbox\Precon\AdventureWorks2014.bak'

--AdventureWorks2014
RESTORE DATABASE AdventureWorks2014 FROM DISK = 'C:\Users\mradmin\Dropbox\Precon\AdventureWorks2014.bak'
WITH RECOVERY, REPLACE, STATS=5,
       MOVE 'AdventureWorks2014_Data' TO 'F:\Data\AdventureWorks2014_Data.mdf',
       MOVE 'AdventureWorks2014_Log' TO 'F:\Log\AdventureWorks2014_Log.ldf'
GO

RESTORE filelistonly FROM DISK = 'C:\Users\mradmin\Downloads\Precon\WideWorldImportersDW-Full.bak'
RESTORE headeronly FROM DISK = 'C:\Users\mradmin\Downloads\Precon\WideWorldImportersDW-Full.bak'

-- AdventureWorks
RESTORE DATABASE AdventureWorks2016CTP3 FROM DISK = 'C:\Users\mradmin\Downloads\Precon\AdventureWorks2016CTP3.bak'
WITH RECOVERY, REPLACE, STATS=5,
       MOVE 'AdventureWorks2016CTP3_Data' TO 'F:\Data\AdventureWorks2016CTP3_Data.mdf',
       MOVE 'AdventureWorks2016CTP3_Log' TO 'F:\Log\AdventureWorks2016CTP3_Log.ldf',
       MOVE 'AdventureWorks2016CTP3_mod' to 'F:\Data\AdventureWorks2016CTP3_mod'
GO
USE [master]
GO
ALTER DATABASE [Adventureworks2016CTP3] SET QUERY_STORE = ON
GO
ALTER DATABASE [Adventureworks2016CTP3] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO


-- AdventureWorksDW
RESTORE DATABASE AdventureworksDW2016CTP3 FROM DISK = 'C:\Users\mradmin\Downloads\Precon\AdventureWorksDW2016CTP3.bak'
WITH RECOVERY, REPLACE, STATS=5,
       MOVE 'AdventureWorksDW2014_Data' TO 'F:\Data\AdventureWorksDW2014_Data.mdf',
       MOVE 'AdventureWorksDW2014_Log' TO 'F:\Log\AdventureWorksDW2014_Log.ldf'
GO
USE [master]
GO
ALTER DATABASE [AdventureworksDW2016CTP3] SET QUERY_STORE = ON
GO
ALTER DATABASE [AdventureworksDW2016CTP3] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO

-- WideWorldImporters
RESTORE DATABASE WideWorldImporters FROM DISK = 'C:\Users\mradmin\Downloads\Precon\WideWorldImporters-Full.bak'
WITH RECOVERY, REPLACE, STATS=5,
       MOVE 'WWI_Primary' TO 'F:\Data\WideWorldImporters.mdf',
       MOVE 'WWI_Log' TO 'F:\Log\WideWorldImpoters.ldf',
       MOVE 'WWI_UserData' to 'F:\Data\WideWorldImporters_UserData.ndf',
       MOVE 'WWI_InMemory_Data_1' to 'F:\Data\WideWorldImporters_InMemory_Data_1'
GO
USE [master]
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE = ON
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO


-- WideWorldImportersDW
RESTORE DATABASE WideWorldImportersDW FROM DISK = 'C:\Users\mradmin\Downloads\Precon\WideWorldImportersDW-Full.bak'
WITH RECOVERY, REPLACE, STATS=5,
       MOVE 'WWI_Primary' TO 'F:\Data\WideWorldImportersDW.mdf',
       MOVE 'WWI_Log' TO 'F:\Log\WideWorldImpotersDW.ldf',
       MOVE 'WWI_UserData' to 'F:\Data\WideWorldImportersDW_UserData.ndf',
       MOVE 'WWIDW_InMemory_Data_1' to 'F:\Data\WideWorldImportersDW_InMemory_Data_1'
GO
GO
USE [master]
GO
ALTER DATABASE WideWorldImportersDW SET QUERY_STORE = ON
GO
ALTER DATABASE WideWorldImportersDW SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO

--------------------------------------------------------------------------------------------------
--DOWNLOAD OSTRESS
--Create Login
--Run Ostress command
--------------------------------------------------------------------------------------------------
--https://www.microsoft.com/en-us/download/details.aspx?id=4511.

--attached work load file
---S server name  this works for a SQL Server or an Azure SQL Database.
---E Windows authentication. The other option is -U and -P for SQL authentication.
---d database name.
---i Path to batch file(s), such as C:\ostress\ostress_batch_file.sql.
---n Number of connections to create.
---r Number of iterations through the file each connection will make.
---q Quiet mode  no result display.
---o Output file directory
----------------------------------------------aq-----------------------------------------------
--ADD USER
CREATE LOGIN [ostress] WITH PASSWORD = N'Passw0rd1234'
GO
ALTER SERVER ROLE sysadmin ADD MEMBER [ostress]
GO

--RUN WITH 10 concurrent user and repeat 25
--ostress -SMRSurfacePro -Uostress -PPassw0rd1234 -dAdventureWorks2016CTP3 -ic:\temp\AdventureWorksBOLWorkload.sql -n10 -r25 -oc:\temp -q