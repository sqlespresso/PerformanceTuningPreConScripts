/**************************************************************************************************
- Finding VLFS
- Script attribution: Monica Rathbun & John Morehouse
- Get counts of VLF files from DBCC loginfo for each database

***************************************************************************************************/

DECLARE @query VARCHAR(100);  
DECLARE @dbname sysname;  
DECLARE @vlfs INT;  
-------------------------------------------------------------------------------------------------- 
--table variable used to 'loop' over databases  
--------------------------------------------------------------------------------------------------
DECLARE @databases TABLE ( dbname sysname );  
INSERT  INTO @databases  
--------------------------------------------------------------------------------------------------
--only choose online databases 
--------------------------------------------------------------------------------------------------
        SELECT  name
        FROM    sys.databases
        WHERE   state = 0;  
--------------------------------------------------------------------------------------------------  
--table variable to hold results  
--------------------------------------------------------------------------------------------------
DECLARE @vlfcounts TABLE
    (
      dbname sysname ,
      vlfcount INT
    );  
  
--------------------------------------------------------------------------------------------------
--table variable to capture DBCC loginfo output  
--changes in the output of DBCC loginfo from SQL2012 mean we have to determine the version 
-------------------------------------------------------------------------------------------------- 

 
DECLARE @MajorVersion TINYINT;  
SET @MajorVersion = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX)),
                         CHARINDEX('.',
                                   CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX)))
                         - 1); 
 
IF @MajorVersion < 11 -- pre-SQL2012 
    BEGIN 
        DECLARE @dbccloginfo TABLE
            (
              fileid SMALLINT ,
              file_size BIGINT ,
              start_offset BIGINT ,
              fseqno INT ,
              [status] TINYINT ,
              parity TINYINT ,
              create_lsn NUMERIC(25, 0)
            );  
  
        WHILE EXISTS ( SELECT TOP 1
                                dbname
                       FROM     @databases )
            BEGIN  
  
                SET @dbname = ( SELECT TOP 1
                                        dbname
                                FROM    @databases
                              );  
                SET @query = 'dbcc loginfo (' + '''' + @dbname + ''') ';  
  
                INSERT  INTO @dbccloginfo
                        EXEC ( @query
                            );  
  
                SET @vlfs = @@rowcount;  
  
                INSERT  @vlfcounts
                VALUES  ( @dbname, @vlfs );  
  
                DELETE  FROM @databases
                WHERE   dbname = @dbname;  
  
            END; --while 
    END; 
ELSE
    BEGIN 
        DECLARE @dbccloginfo2012 TABLE
            (
              RecoveryUnitId INT ,
              fileid SMALLINT ,
              file_size BIGINT ,
              start_offset BIGINT ,
              fseqno INT ,
              [status] TINYINT ,
              parity TINYINT ,
              create_lsn NUMERIC(25, 0)
            );  
  
        WHILE EXISTS ( SELECT TOP 1
                                dbname
                       FROM     @databases )
            BEGIN  
  
                SET @dbname = ( SELECT TOP 1
                                        dbname
                                FROM    @databases
                              );  
                SET @query = 'dbcc loginfo (' + '''' + @dbname + ''') ';  
  
                INSERT  INTO @dbccloginfo2012
                        EXEC ( @query
                            );  
  
                SET @vlfs = @@rowcount;  
  
                INSERT  @vlfcounts
                VALUES  ( @dbname, @vlfs );  
  
                DELETE  FROM @databases
                WHERE   dbname = @dbname;  
  
            END; --while 
    END; 
--------------------------------------------------------------------------------------------------
-- Output the full list  
-------------------------------------------------------------------------------------------------- 

SELECT  dbname ,
        vlfcount
FROM    @vlfcounts
ORDER BY dbname;

--------------------------------------------------------------------------------------------------
-- --NEW FOR 2016 SP2 back ported started in 2017
--------------------------------------------------------------------------------------------------

SELECT name AS 'Database Name', 
total_vlf_count AS 'VLF count' 
FROM sys.databases AS s
CROSS APPLY sys.dm_db_log_stats(s.database_id) 
--WHERE total_vlf_count > 100;