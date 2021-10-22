

/**************************************************************************************************
- What's using TEMPDB and taking up space
- Script attribution: Kendra Little
- Link https://littlekendra.com/2009/08/27/whos-using-all-that-space-in-tempdb-and-whats-their-plan/
- Show Tempdb usage, look for the largest allocated values
- PART 2
***************************************************************************************************/
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