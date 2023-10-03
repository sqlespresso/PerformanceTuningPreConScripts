/**************************************************************************************************
- NESTED LOOPS examples
- Script attribution: Tiger Team Toolbox Mining-PlanCache scripts can be found on Git hub
- Link https://github.com/microsoft/tigertoolbox/tree/master/Mining-PlanCache
- Show Excution plan NESTED LOOPSexamples

- TURN ON QUERY PLAN

***************************************************************************************************/


--------------------------------------------------------------------------------------------------
--GET PLANS FROM CACHE
--------------------------------------------------------------------------------------------------



SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'), 
	Scansearch AS (SELECT qp.query_plan, cp.usecounts, ss.query('.') AS StmtSimple, cp.plan_handle
					FROM sys.dm_exec_cached_plans cp (NOLOCK)
					CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
					CROSS APPLY qp.query_plan.nodes('//StmtSimple') AS p(ss)
					WHERE ss.exist('//RelOp[@PhysicalOp = "Nested Loops"]') = 1
						AND ss.exist('@QueryHash') = 1
					)
SELECT StmtSimple.value('StmtSimple[1]/@StatementText', 'VARCHAR(4000)') AS sql_text,
	StmtSimple.value('StmtSimple[1]/@StatementId', 'int') AS StatementId,
	c1.value('@NodeId','int') AS node_id,
	c3.value('@Database','sysname') AS database_name,
	c3.value('@Schema','sysname') AS [schema_name],
	c3.value('@Table','sysname') AS table_name,
	c1.value('@PhysicalOp','sysname') AS physical_operator, 
	c1.value('@LogicalOp','sysname') AS logical_operator, 
	c2.value('@Optimized','sysname') AS Batch_Sort_Optimized,
	--c2.value('@WithUnorderedPrefetch','sysname') AS WithUnorderedPrefetch,
	c4.value('@SerialDesiredMemory', 'int') AS MemGrant_SerialDesiredMemory,
	c5.value('@EstimatedAvailableMemoryGrant', 'int') AS EstimatedAvailableMemoryGrant,
	--c5.value('@EstimatedPagesCached', 'int') AS EstimatedPagesCached,
	--c5.value('@EstimatedAvailableDegreeOfParallelism', 'int') AS EstimatedAvailableDegreeOfParallelism,
	ss.usecounts,
	ss.query_plan,
	StmtSimple.value('StmtSimple[1]/@QueryHash', 'VARCHAR(100)') AS query_hash,
	StmtSimple.value('StmtSimple[1]/@QueryPlanHash', 'VARCHAR(100)') AS query_plan_hash,
	StmtSimple.value('StmtSimple[1]/@StatementSubTreeCost', 'sysname') AS StatementSubTreeCost,
	c1.value('@TableCardinality','sysname') AS TableCardinality,
	c1.value('@EstimateRows','sysname') AS EstimateRows,
	--c1.value('@EstimateIO','sysname') AS EstimateIO,
	--c1.value('@EstimateCPU','sysname') AS EstimateCPU,
	c1.value('@AvgRowSize','int') AS AvgRowSize,
	--c1.value('@Parallel','bit') AS Parallel,
	c1.value('@EstimateRebinds','int') AS EstimateRebinds,
	c1.value('@EstimateRewinds','int') AS EstimateRewinds,
	c1.value('@EstimatedExecutionMode','sysname') AS EstimatedExecutionMode,
	StmtSimple.value('StmtSimple[1]/@StatementOptmEarlyAbortReason', 'sysname') AS StatementOptmEarlyAbortReason,
	StmtSimple.value('StmtSimple[1]/@StatementOptmLevel', 'sysname') AS StatementOptmLevel,
	ss.plan_handle
FROM Scansearch ss
CROSS APPLY query_plan.nodes('//RelOp') AS q1(c1)
CROSS APPLY c1.nodes('./NestedLoops') AS q2(c2)
CROSS APPLY c1.nodes('./OutputList/ColumnReference[1]') AS q3(c3)
OUTER APPLY query_plan.nodes('//MemoryGrantInfo') AS q4(c4)
OUTER APPLY query_plan.nodes('//OptimizerHardwareDependentProperties') AS q5(c5)
WHERE c1.exist('@PhysicalOp[. = "Nested Loops"]') = 1
	AND c3.value('@Schema','sysname') <> '[sys]'
	AND c2.value('@Optimized','sysname') = 1
OPTION(RECOMPILE, MAXDOP 1); 
GO