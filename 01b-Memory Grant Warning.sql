

/**************************************************************************************************
- Memory Grant Warning
- Script attribution: Example script can be found on Git hub
- Link https://github.com/microsoft/sql-server-samples/tree/master/samples/demos/Showplan
- Show Excessive Memory Grant Warning

-TURN ON QUERY PLAN
-In SELECT node properties:
-MaxQueryMemory for maximum query memory grant under RG MAX_MEMORY_PERCENT hint
-MaxCompileMemory for maximum query optimizer memory in KB during compile under RG

***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--SETUP TAKES A REALLY LONG TIME!
--------------------------------------------------------------------------------------------------
/*USE [master]
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'memgrants')
CREATE DATABASE [memgrants]
GO

USE [memgrants]
GO
CREATE NONCLUSTERED INDEX IDX_Col1
ON [dbo].[orders_detail] ([col1])
INCLUDE ([col2])
GO

USE [memgrants]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[orders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[orders](
	[col1] [int] NOT NULL,
	[col2] [int] NULL,
	[col3] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[col1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET NOCOUNT ON
GO
DECLARE @x int
SET @x = 0
WHILE (@x < 100000)
BEGIN
	INSERT INTO [dbo].[orders] VALUES (@x, @x, @x)
	SET @x = @x + 1
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[orders_detail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[orders_detail](
	[col1] [int] NULL,
	[col2] [int] NULL,
	[col3] [char](5000) NOT NULL
) ON [PRIMARY]
END
GO

DECLARE @x int
DECLARE @y int
SET @x = 0
SET @y = 1
WHILE (@x < 10000)
BEGIN
	INSERT INTO [dbo].[orders_detail] VALUES (@x, @y, 'x')
	IF ((@y % 100) = 0)
	BEGIN
		SET @y = 1
		SET @x = @x + 1
	END
	SET @y = @y + 1
END
GO

SET NOCOUNT OFF
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[orders_detail]') AND name = N'od_cl_idx')
CREATE UNIQUE CLUSTERED INDEX [od_cl_idx] ON [dbo].[orders_detail]
(
	[col1] ASC,
	[col2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/
--------------------------------------------------------------------------------------------------
--DEMO
--------------------------------------------------------------------------------------------------

USE [MemGrants]
GO
DBCC FREEPROCCACHE
GO
SELECT o.col3, o.col2, d.col2
FROM orders o
JOIN orders_detail d ON o.col2 = d.col1
WHERE o.col3 <= 8000
OPTION (LOOP JOIN, MAXDOP 1, MIN_GRANT_PERCENT = 20)
GO
