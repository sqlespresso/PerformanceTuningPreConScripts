

/**************************************************************************************************
- What's using TEMPDB and taking up space
- Script attribution: Kendra Little
- Link https://littlekendra.com/2009/08/27/whos-using-all-that-space-in-tempdb-and-whats-their-plan/
- Show Tempdb usage, look for the largest allocated values

***************************************************************************************************/

---------------------------------------------------------------
--Create a Tempdb Workload
--Takes 32 seconds
---------------------------------------------------------------
USE MemGrants
GO
CREATE TABLE t1 (c1 int primary key, c2 int, c3 char(8000))
go
CREATE TABLE t2 (c4 int, c5 char(8000))
go

DECLARE @i int
SELECT @i=0
WHILE (@i<160000)
BEGIN
	INSERT INTO t1 VALUES (@i, @i+1000, 'Hello')
	INSERT INTO t2 VALUES (@i, 'There')
	SET @i=@i+1
END

---------------------------------------------------------------
-- now clean buffer pool so that this query takes some time to complete
-- and we can see Tempdb space usage
---------------------------------------------------------------

DBCC freeproccache 

---------------------------------------------------------------
--Removes all elements from the plan cache Clearing the procedure (plan) 
--cache causes all plans to be evicted, and incoming query executions will compile a new plan, 
--instead of reusing any previously cached plan.
---------------------------------------------------------------
---------------------------------------------------------------
--Removes all clean buffers from the buffer pool
---------------------------------------------------------------
DBCC dropcleanbuffers 

---------------------------------------------------------------
--start the query
---------------------------------------------------------------
SELECT c1,c5
FROM t1 INNER HASH JOIN t2 ON t1.c1=t2.c4
ORDER BY c2

---------------------------------------------------------------
--IN NEW WINDOW LOOK AT TEMPDB
---------------------------------------------------------------


SELECT
    t1.session_id
    , t1.request_id
    , task_alloc_GB = cast((t1.task_alloc_pages * 8./1024./1024.) as numeric(10,1))
    , task_dealloc_GB = cast((t1.task_dealloc_pages * 8./1024./1024.) as numeric(10,1))
    , host= CASE WHEN t1.session_id <= 50 THEN 'SYS' ELSE s1.host_name END
    , s1.login_name
    , s1.status
    , s1.last_request_start_time
    , s1.last_request_end_time
    , s1.row_count
    , s1.transaction_isolation_level
    , query_text=
        coalesce((SELECT SUBSTRING(text, t2.statement_start_offset/2 + 1,
          (CASE WHEN statement_end_offset = -1
              THEN LEN(CONVERT(nvarchar(max),text)) * 2
                   ELSE statement_end_offset
              END - t2.statement_start_offset)/2)
        FROM sys.dm_exec_sql_text(t2.sql_handle)) , 'Not currently executing')
    , query_plan=(SELECT query_plan FROM sys.dm_exec_query_plan(t2.plan_handle))
FROM
    (SELECT session_id, request_id
    , task_alloc_pages=sum(internal_objects_alloc_page_count +   user_objects_alloc_page_count)
    , task_dealloc_pages = sum (internal_objects_dealloc_page_count + user_objects_dealloc_page_count)
    FROM sys.dm_db_task_space_usage
    GROUP BY session_id, request_id) as t1
LEFT JOIN sys.dm_exec_requests as t2 ON
    t1.session_id = t2.session_id
    AND t1.request_id = t2.request_id
LEFT JOIN sys.dm_exec_sessions as s1 ON
    t1.session_id=s1.session_id
WHERE
    t1.session_id > 50 -- ignore system unless you suspect there's a problem there
    AND t1.session_id <> @@SPID -- ignore this request itself
ORDER BY t1.task_alloc_pages DESC;
GO