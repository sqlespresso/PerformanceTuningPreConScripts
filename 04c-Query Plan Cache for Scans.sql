
/**************************************************************************************************
- SCANS examples
- Script attribution: Tiger Team Toolbox Mining-PlanCache scripts can be found on Git hub
- Link https://github.com/microsoft/tigertoolbox/tree/master/Mining-PlanCache
- Show Excution plan SCAN examples

---- RUN FOR A FEW SECONDS THEN STOP AND LOOK AT RESULTS AS IT CAN TAKE AWHILE TO RUN
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
					WHERE cp.cacheobjtype = 'Compiled Plan'
						AND (ss.exist('//RelOp[@PhysicalOp = "Index Scan"]') = 1
								OR ss.exist('//RelOp[@PhysicalOp = "Clustered Index Scan"]') = 1)
						AND ss.exist('@QueryHash') = 1
					)
SELECT StmtSimple.value('StmtSimple[1]/@StatementText', 'VARCHAR(4000)') AS sql_text,
	StmtSimple.value('StmtSimple[1]/@StatementId', 'int') AS StatementId,
	c1.value('@NodeId','int') AS node_id,
	c2.value('@Database','sysname') AS database_name,
	c2.value('@Schema','sysname') AS [schema_name],
	c2.value('@Table','sysname') AS table_name,
	c1.value('@PhysicalOp','sysname') AS physical_operator, 
	c2.value('@Index','sysname') AS index_name,
	c3.value('@ScalarString[1]','VARCHAR(4000)') AS [predicate],
	c1.value('@TableCardinality','sysname') AS TableCardinality,
	c1.value('@EstimateRows','sysname') AS EstimateRows,
	--c1.value('@EstimateIO','sysname') AS EstimateIO,
	--c1.value('@EstimateCPU','sysname') AS EstimateCPU,
	c1.value('@AvgRowSize','int') AS AvgRowSize,
	--c1.value('@Parallel','bit') AS Parallel,
	c1.value('@EstimateRebinds','int') AS EstimateRebinds,
	c1.value('@EstimateRewinds','int') AS EstimateRewinds,
	c1.value('@EstimatedExecutionMode','sysname') AS EstimatedExecutionMode,
	c4.value('@Lookup','bit') AS Lookup,
	c4.value('@Ordered','bit') AS Ordered,
	c4.value('@ScanDirection','sysname') AS ScanDirection,
	c4.value('@ForceSeek','bit') AS ForceSeek,
	c4.value('@ForceScan','bit') AS ForceScan,
	c4.value('@NoExpandHint','bit') AS NoExpandHint,
	c4.value('@Storage','sysname') AS Storage,
	ss.usecounts,
	ss.query_plan,
	StmtSimple.value('StmtSimple[1]/@QueryHash', 'VARCHAR(100)') AS query_hash,
	StmtSimple.value('StmtSimple[1]/@QueryPlanHash', 'VARCHAR(100)') AS query_plan_hash,
	StmtSimple.value('StmtSimple[1]/@StatementSubTreeCost', 'sysname') AS StatementSubTreeCost,
	c1.value('@EstimatedTotalSubtreeCost','sysname') AS EstimatedTotalSubtreeCost,
	StmtSimple.value('StmtSimple[1]/@StatementOptmEarlyAbortReason', 'sysname') AS StatementOptmEarlyAbortReason,
	StmtSimple.value('StmtSimple[1]/@StatementOptmLevel', 'sysname') AS StatementOptmLevel,
	ss.plan_handle
FROM Scansearch ss
CROSS APPLY query_plan.nodes('//RelOp') AS q1(c1)
CROSS APPLY c1.nodes('./IndexScan') AS q4(c4)
CROSS APPLY c1.nodes('./IndexScan/Object') AS q2(c2)
OUTER APPLY c1.nodes('./IndexScan/Predicate/ScalarOperator[1]') AS q3(c3)
WHERE (c1.exist('@PhysicalOp[. = "Index Scan"]') = 1
		OR c1.exist('@PhysicalOp[. = "Clustered Index Scan"]') = 1)
	AND c2.value('@Schema','sysname') <> '[sys]'
OPTION(RECOMPILE, MAXDOP 1); 
GO