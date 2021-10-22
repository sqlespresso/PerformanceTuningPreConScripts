/**************************************************************************************************
- MAX Memory Config
- Script attribution: John Morehouse https://sqlrus.com/2014/03/configuration-validation-max-memory/
- Using Math to get the exact value you need for your max memory 
			Reserve 1GB of RAM for the Operating System
			Reserve 1GB of RAM for each 4GB of RAM installed from 4-16GB
			Reserve 1GB for every 8GB of RAM installed above 16GB of RAM

***************************************************************************************************/


DECLARE @mem NVARCHAR(10)
DECLARE @memOut NVARCHAR(10)
DECLARE @totalOSReserve INT
DECLARE @4_16 INT
DECLARE @8Above16 INT
DECLARE @serverVersion INT
DECLARE @sql NVARCHAR(MAX)
DECLARE @paramdefs NVARCHAR(500)
-- Put this into a parameter so it's configurable
DECLARE @osMem INT

-- Done this way to handle older versions of SQL Server
SET @osMem = 1 -- leave 1GB for the OS
SET @8Above16 = 0 -- leave it 0 by default if you don't have more than 8GB of memory
SET @serverVersion = LEFT(CAST(SERVERPROPERTY('productversion') AS VARCHAR(100)),CHARINDEX('.',CAST(SERVERPROPERTY('productversion') AS VARCHAR(100)),1)-1)
SET @paramdefs = N'@memOut INT OUTPUT'

-- Setup the dynamic SQL
-- We need the physical memory values in GB since that's the scale we are working with.
IF @serverVersion>= 10
	SET @sql = '(SELECT @memOut = (physical_memory_KB/1024/1024) FROM sys.dm_os_sys_info)'
ELSE
	SET @sql = '(select @memOut = (physical_memory_in_bytes/1024/1024/1024) FROM sys.dm_os_sys_info)'

-- Get the amount of physical memory on the box
EXEC sp_executesql @sql, @paramdefs, @memOut = @mem OUTPUT

-- Start the Math
IF @mem >= 16
	BEGIN
		SET @4_16 = 4
		SET @8Above16 = (@mem-16)/8
	END
 ELSE
	BEGIN
		SET @4_16 = @mem/4
	END

-- Total amount of memory reserved for the OS
SET @totalOSReserve = @osMem + @4_16 + @8Above16
SET @mem = (@mem-@totalOSReserve)*1024

-- Use sys.configurations to find the current value
SELECT (@mem/1024)+@totalOSReserve AS 'Total Physical Memory'
	, @totalOSReserve AS 'Total OS Reserve'
	, @mem AS 'Expected SQL Server Memory'
	, value_in_use AS 'Current Configured Value'
FROM sys.configurations
WHERE name = 'max server memory (MB)'
GO