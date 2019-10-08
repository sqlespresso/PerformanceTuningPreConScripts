
/**************************************************************************************************
- IMPLICIT CONVERSION examples
- Script attribution: Tiger Team Toolbox Mining-PlanCache scripts can be found on Git hub
- Link https://github.com/microsoft/tigertoolbox/tree/master/Mining-PlanCache
- Show Excution plan IMPLICIT CONVERSION examples

-- RUN FOR A FEW SECONDS THEN STOP AND LOOK AT RESULTS AS IT CAN TAKE AWHILE TO RUN

***************************************************************************************************/

--------------------------------------------------------------------------------------------------
--Example Query
--------------------------------------------------------------------------------------------------

USE AdventureWorks2016CTP3
SELECT p.FirstName, p.LastName, e.NationalIDNumber, e.LoginID
FROM HumanResources.Employee e
INNER JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE NationalIDNumber = 112457891;

--------------------------------------------------------------------------------------------------
--GET PLANS FROM CACHE
--------------------------------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'), 
	Convertsearch AS (SELECT qp.query_plan, cp.usecounts, cp.objtype, cp.plan_handle, cs.query('.') AS StmtSimple
					FROM sys.dm_exec_cached_plans cp (NOLOCK)
					CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
					CROSS APPLY qp.query_plan.nodes('//StmtSimple') AS p(cs)
					WHERE cp.cacheobjtype = 'Compiled Plan' 
							AND cs.exist('@QueryHash') = 1
							AND cs.exist('.//ScalarOperator[contains(@ScalarString, "CONVERT_IMPLICIT")]') = 1
							AND cs.exist('.[contains(@StatementText, "Convertsearch")]') = 0
					)
SELECT TOP 10 c2.value('@StatementText', 'VARCHAR(4000)') AS sql_text,
	c2.value('@StatementId', 'int') AS StatementId,
	c3.value('@ScalarString[1]','VARCHAR(4000)') AS expression,
	ss.usecounts,
	ss.query_plan,
	StmtSimple.value('StmtSimple[1]/@QueryHash', 'VARCHAR(100)') AS query_hash,
	StmtSimple.value('StmtSimple[1]/@QueryPlanHash', 'VARCHAR(100)') AS query_plan_hash,
	StmtSimple.value('StmtSimple[1]/@StatementSubTreeCost', 'sysname') AS StatementSubTreeCost,
	c2.value('@EstimatedTotalSubtreeCost','sysname') AS EstimatedTotalSubtreeCost,
	StmtSimple.value('StmtSimple[1]/@StatementOptmEarlyAbortReason', 'sysname') AS StatementOptmEarlyAbortReason,
	StmtSimple.value('StmtSimple[1]/@StatementOptmLevel', 'sysname') AS StatementOptmLevel,
	ss.plan_handle
FROM Convertsearch ss
CROSS APPLY query_plan.nodes('//StmtSimple') AS q2(c2)
CROSS APPLY c2.nodes('.//ScalarOperator[contains(@ScalarString, "CONVERT_IMPLICIT")]') AS q3(c3)
OPTION(RECOMPILE, MAXDOP 1); 
GO