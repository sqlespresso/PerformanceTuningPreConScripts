
/**************************************************************************************************
- TESTING SETUP
- Script attribution: Monica Rathbun

***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--FOR TESTING MAKE SURE YOU HAVE SP_WHOISACTIVE installed
--------------------------------------------------------------------------------------------------

sp_whoisactive @get_plans=1

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