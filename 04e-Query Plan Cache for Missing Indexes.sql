
/**************************************************************************************************
- MISSING INDEXES examples
- Script attribution: Tiger Team Toolbox Mining-PlanCache scripts can be found on Git hub
- Link https://github.com/microsoft/tigertoolbox/tree/master/Mining-PlanCache
- Show Excution plan MISSING INDEXES examples
-- RUN FOR A FEW SECONDS THEN STOP AND LOOK AT RESULTS AS IT CAN TAKE AWHILE TO RUN
***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--GET PLANS FROM CACHE took 56 seconds
--------------------------------------------------------------------------------------------------


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'), 
	PlanMissingIndexes AS (SELECT query_plan, cp.usecounts, cp.refcounts, cp.plan_handle
							FROM sys.dm_exec_cached_plans cp (NOLOCK)
							CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) tp
							WHERE cp.cacheobjtype = 'Compiled Plan' 
								AND tp.query_plan.exist('//MissingIndex')=1
							)
SELECT  c1.value('(//MissingIndex/@Database)[1]', 'sysname') AS database_name,
	c1.value('(//MissingIndex/@Schema)[1]', 'sysname') AS [schema_name],
	c1.value('(//MissingIndex/@Table)[1]', 'sysname') AS [table_name],
	c1.value('@StatementText', 'VARCHAR(4000)') AS sql_text,
	c1.value('@StatementId', 'int') AS StatementId,
	pmi.usecounts,
	pmi.refcounts,
	c1.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') AS impact,
	REPLACE(c1.query('for $group in //ColumnGroup for $column in $group/Column where $group/@Usage="EQUALITY" return string($column/@Name)').value('.', 'varchar(max)'),'] [', '],[') AS equality_columns,
	REPLACE(c1.query('for $group in //ColumnGroup for $column in $group/Column where $group/@Usage="INEQUALITY" return string($column/@Name)').value('.', 'varchar(max)'),'] [', '],[') AS inequality_columns,
	REPLACE(c1.query('for $group in //ColumnGroup for $column in $group/Column where $group/@Usage="INCLUDE" return string($column/@Name)').value('.', 'varchar(max)'),'] [', '],[') AS include_columns,
	pmi.query_plan,
	pmi.plan_handle
FROM PlanMissingIndexes pmi
CROSS APPLY pmi.query_plan.nodes('//StmtSimple') AS q1(c1)
WHERE pmi.usecounts > 1
ORDER BY c1.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') DESC
OPTION(RECOMPILE, MAXDOP 1); 
GO