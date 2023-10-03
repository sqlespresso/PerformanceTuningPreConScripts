
/**************************************************************************************************
- Automatic Plan Corrections
- Script attribution: 
- Link https://github.com/sqlespresso/PerformanceTuningPreConScripts
- Using sp_estimate_data_compression_savings to estimate table or index\partition 


***************************************************************************************************/



----------------------------------------------------------------------------------------------------
---- TURN ON
----------------------------------------------------------------------------------------------------
ALTER DATABASE [AdventureWorks2019]
SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = ON );

----------------------------------------------------------------------------------------------------
---- Verify
----------------------------------------------------------------------------------------------------
select * from sys.database_automatic_tuning_options where name = 'FORCE_LAST_GOOD_PLAN'


----------------------------------------------------------------------------------------------------
---- Look at Recommendations
----------------------------------------------------------------------------------------------------
SELECT * FROM sys.dm_db_tuning_recommendations
ORDER BY execute_action_start_time


----------------------------------------------------------------------------------------------------
---- See Why or Get Manual Scripts
----------------------------------------------------------------------------------------------------
--Get scripts to fix regressions
SELECT reason, score,
      script = JSON_VALUE(details, '$.implementationDetails.script'),
      planForceDetails.*,
      estimated_gain = (regressedPlanExecutionCount + recommendedPlanExecutionCount)
                  * (regressedPlanCpuTimeAverage - recommendedPlanCpuTimeAverage)/1000000,
      error_prone = IIF(regressedPlanErrorCount > recommendedPlanErrorCount, 'YES','NO')
FROM sys.dm_db_tuning_recommendations
CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH (  [query_id] int '$.queryId',
            regressedPlanId int '$.regressedPlanId',
            recommendedPlanId int '$.recommendedPlanId',
            regressedPlanErrorCount int,
            recommendedPlanErrorCount int,
            regressedPlanExecutionCount int,
            regressedPlanCpuTimeAverage float,
            recommendedPlanExecutionCount int,
            recommendedPlanCpuTimeAverage float
          ) AS planForceDetails;

