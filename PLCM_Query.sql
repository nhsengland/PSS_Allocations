/*
The PLCM is held in three separate tables in the NCDR, all are within the NHSE_SLAM repository.

•	The activity-based data is here:- [NHSE_SLAM].[DWS_Reg].[tbl_Data_PLD]
•	The high-cost drugs data is here:- [NHSE_SLAM].[DWS_Reg].[tbl_Data_Drugs]
•	The high-cost devices data is here:- [NHSE_SLAM].[DWS_Reg].[tbl_data_devices]

To get the aggregate PLCM position that we use in the benchmarking tool, we need to aggregate the three datasets in a certain way to ensure that we don’t double count any patient IDs.
*/

SELECT [A].[DER_CCG_Code], COUNT(DISTINCT [A].[DER_Pseudo_NHS_Number]) AS patients, SUM([A].[activity_cost]) AS activity_cost, SUM([A].[devices_cost]) AS devices_cost, SUM([A].[drugs_cost]) AS drugs_cost, SUM([A].[total_cost]) AS total_cost
FROM	
((SELECT [DER_CCG_Code], [DER_Pseudo_NHS_Number], [CLN_Total_Cost] AS activity_cost, NULL AS devices_cost, NULL AS drugs_cost, [CLN_Total_Cost] AS total_cost
  	FROM [NHSE_SLAM].[DWS_Reg].[tbl_Data_PLD] AS PLD	
 	WHERE DER_Activity_Year LIKE '%22/23%'	
  		AND DER_NHSE_ServiceCategory LIKE '%21%'	
  		AND DER_Postcode_LSOA_Code LIKE 'E%'
  		AND DER_CCG_Code IS NOT NULL)
  UNION ALL
(SELECT [DER_CCG_Code], [DER_Pseudo_NHS_Number], NULL AS activity_cost, [CLN_Total_Cost] AS devices_cost, NULL AS drugs_cost, [CLN_Total_Cost] AS total_cost
  	FROM [NHSE_SLAM].[DWS_Reg].[tbl_data_devices] AS devices
WHERE DER_Activity_Year LIKE '%22/23%'
AND DER_NHSE_ServiceCategory LIKE '%21%'	
  		AND DER_Postcode_LSOA_Code LIKE 'E%'
  		AND DER_CCG_Code IS NOT NULL)
  UNION ALL
(SELECT [DER_CCG_Code], [DER_Pseudo_NHS_Number], NULL AS activity_cost, NULL AS devices_cost, [CLN_Total_Cost] AS drugs_cost, [CLN_Total_Cost] AS total_cost
FROM [NHSE_SLAM].[DWS_Reg].[tbl_Data_Drugs] AS drugs
 	WHERE DER_Activity_Year LIKE '%22/23%'
  		AND DER_NHSE_ServiceCategory LIKE '%21%'	
  		AND DER_Postcode_LSOA_Code LIKE 'E%'
  		AND DER_CCG_Code IS NOT NULL)
  ) AS A
   GROUP BY   [DER_CCG_Code]
   ORDER BY   [DER_CCG_Code]
