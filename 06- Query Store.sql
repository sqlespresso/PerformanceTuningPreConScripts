
/**************************************************************************************************
- Query Store
- Script attribution: Monica Rathbun
- Link: https://github.com/sqlespresso/PerformanceTuningPreConScripts
- Mind Query Store


***************************************************************************************************/


--------------------------------------------------------------------------------------------------
---- Get Object ID For Proc to use for main QS query  
------------------------------------------------------------------------------------------------
SELECT * FROM sys.objects
WHERE [name]  LIKE '%p_sel_product_by_price_and_quantity%'and type in ('p','tr')
--WHERE object_id='461244698'

select * from sys.query_store_plan
where query_id=1607676775

------------------------------------------------------------------------------------------------
---- Query Store --- note avoid running by statement as it's heavy but you can if need to just limit scope
------------------------------------------------------------------------------------------------
SELECT  top 1000 OBJECT_NAME(qsq.object_id) 'proc name',  query_sql_text,	[qsp].[plan_id],	qsq.query_id,
        [qsq].[object_id],		
        [rsi].[start_time],		
        [rsi].[end_time],		
		[rs].[count_executions],
	    [rs].[avg_duration] /1000 AS [avg_duration_ms],
		[rs].[avg_logical_io_reads],
		[rs].[avg_cpu_time]/1000 AS [avg_cpu_time_ms],
ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
      FROM [sys].[query_store_query] [qsq]		
JOIN [sys].[query_store_query_text] [qst]		
                ON [qsq].[query_text_id] = [qst].[query_text_id]		
JOIN [sys].[query_store_plan] [qsp]		
                ON [qsq].[query_id] = [qsp].[query_id]		
JOIN [sys].[query_store_runtime_stats] [rs]		
                ON [qsp].[plan_id] = [rs].[plan_id]		
JOIN [sys].[query_store_runtime_stats_interval] [rsi]		
                ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]		
WHERE--[qsq].[query_id] IN ( 25808418)
--query_sql_text like'%usp_Enroll%'
--qsq.object_id IN (1607676775)
--qsp.query_plan_hash IN ( 'E0FB4A4186253F3CF88A44F1DC0ECC159E56B1BD')
--[qsp].[plan_id]=36912092
--AND 
--[rsi].[end_time] >= '2023-10-02 00:59:59.0000000 +00:00' --rsi --1800= 2pm		
--AND [rsi].[end_time] <= '2023-10-02 23:59:59.0000000 +00:00' --rsi		
--and
[rs].[execution_type]in (3,4)		---[rs].[execution_type] in (3,4)		--FAILURES and CANCELS	
ORDER BY  --query_sql_text,
[rsi].[start_time],[rsi].[end_time] desc 
--[rs].[avg_duration] DESC


------------------------------------------------------------------------------------------------
---- Query Store get ID by Proc
------------------------------------------------------------------------------------------------
SELECT  d.object_id, d.database_id, OBJECT_NAME(object_id, database_id) 'proc name',   
    d.cached_time, d.last_execution_time, d.total_elapsed_time,  
    (d.total_elapsed_time/d.execution_count) AS [avg_elapsed_time],  
    d.last_elapsed_time, d.execution_count, *  
FROM sys.dm_exec_procedure_stats AS d  
Where OBJECT_NAME(object_id, database_id)like(N'%p_sel_product_by_price_and_quantity%')
ORDER BY [total_worker_time] DESC;  


SELECT cp.cacheobjtype, cp.usecounts, cp.plan_handle,st.objectid,st.text,db_name(st.dbid),qps.query_plan   
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan_stats(plan_handle) AS qps
where qps.dbid = db_id('')
    and st.objectid IS NOT NULL

------------------------------------------------------------------------------------------------
--	Remove plan from QS
------------------------------------------------------------------------------------------------
--EXEC sp_query_store_remove_plan 3;
--------------------------------------------------------------------------------------------------
----	Remove Query 
--------------------------------------------------------------------------------------------------
--EXEC sp_query_store_remove_query 3;
