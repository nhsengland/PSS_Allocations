--ALTER PROCEDURE accProviderVars
--AS
--BEGIN

WITH 

LSOA_baseTable (LSOA_Code, LSOA_Name, CCG_Code, CCG_Name, STP_Code, STP_Name, ICS_Code, ICS_Name,
					Pop_70_plus, Population, IMD_Score, IMD_Decile, Employment_Deprivation_Domain, Income_Deprivation_Affecting_Older_People_Index) 

	AS (SELECT lsoa.LSOA_Code,	lsoan.LSOA_Name, ccg.CCG2019_Code, ccg.CCG2019_Name, ics.STP21, ics.STP21_42_STP_name_from_ODS_API_April_2021, ics.ICS, ics.ICS_Name,
				cast(pop.[70_plus_prop] as float) 'Pop_70_plus',								
				cast(replace((case when substring(pop.Population_all,1,1) = '"'							
						then substring(pop.Population_all,2,len(pop.Population_all)-2)					
						else pop.Population_all end),',','') as int) as 'Population',			
				lsoa.IMD_Score as 'IMD_Score', -- MAX Aggregation chosen only to ensure no duplication										
				lsoa.IMD_Decile as 'IMD_Decile',																		
				dd.Employment_Deprivation_Domain,																			
				dd.Income_Deprivation_Affecting_Older_People_Index								
		 FROM NHSE_Reference.dbo.tbl_Ref_Other_Deprivation_By_LSOA lsoa
			LEFT OUTER JOIN   NHSE_Reference.dbo.tbl_Ref_ODS_LSOA lsoan -- LSOAname											
				ON lsoa.LSOA_Code = lsoan.LSOA
			LEFT OUTER JOIN NHSE_Sandbox_DC.[dbo].[LSOA Population SAPE21DT1a-mid-2018-on-2019-LA-lsoa-syoa-estimates-formattedtxt] pop											
				ON lsoa.LSOA_Code = pop.LSOA_Code										
			LEFT OUTER JOIN [NHSE_Sandbox_DC].[dbo].[LSOA_imd_scores_all_domains_2019] dd											
				on lsoa.LSOA_Code = dd.FeatureCode	
			LEFT OUTER JOIN NHSE_Sandbox_DC.dbo.LSOA_2011_to_CCG_Apr19 ccg
				on lsoa.LSOA_Code = ccg.LSOA2011_Code
			LEFT OUTER JOIN --select * from
						NHSE_Sandbox_DC.dbo.Universal_CCG_Mapper_v2$ ics
				on ccg.CCG2019_Code = ics.CCG_Code
		WHERE lsoa.Effective_Snapshot_Date = '2019-12-31'
		),

ETHN_cte (LSOA_Code, nonWhiteProp)
	AS (SELECT e.LSOA_Name as 'LSOA_Code', --note the deliberate error!
			   (1 - e.White_perc) as 'nonWhiteProp'	--select * 
		FROM NHSE_Sandbox_DC.dbo.LSOA_Ethnicity_Categories$ e) ,

CWRU_NEL_cte (FinYear, LSOA_Code, CC_Days_Unweighted_NEL, CWRU_NEL)

	AS (SELECT sp.Der_Financial_Year,  									
			sp.Der_Postcode_LSOA_2011_Code AS 'LSOA_Code',
			sum(CC_Days_LOS) as 'CC_Days_LOS_Unweighted',
			sum(CASE WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067					
					WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587				
					WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847					
					WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.000				
					WHEN cc.Unbundled_HRG = 'XC05Z'	THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)*0.8475) -- 2_organ ARS split				
					WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS*0.6425					
					WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203				
						ELSE CC_Days_LOS*1.00 END) AS 'CWRU_NEL'									
													
	FROM  NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc					
			JOIN  NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp 				
				ON cc.APCS_Ident = sp.APCS_Ident			
			JOIN NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Der der				
				ON sp.APCS_Ident = der.APCS_Ident			
			JOIN NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Cost cost				
				ON sp.APCS_Ident = cost.APCS_Ident			
			LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr				
				ON sp.Der_Provider_Site_Code = pr.Provider_Site_Code			
			JOIN NHSE_Reference.dbo.vw_Ref_ODS_Commissioner_AllOrgs co				
				ON sp.Der_Commissioner_Code = co.Org_Code			
			LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_ODS_CCG ccg -- IDENTIFIES CCG OF RESIDENCE				
				ON sp.Der_Postcode_CCG_Code = ccg.Org_Code			
			LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_ACM_National_POD pod				
				ON der.National_POD_Code = pod.National_POD_Code			
			LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg				
				ON der.Spell_Core_HRG = hrg.HRG_Code			
			left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrgu				
				on cc.Unbundled_HRG = hrgu.HRG_Code					
			LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_Other_Deprivation_By_LSOA lsoa				
				ON sp.Der_Postcode_LSOA_Code = lsoa.LSOA_Code			
			LEFT OUTER JOIN NHSE_Sandbox_DC.dbo.[Rural_Urban_Classification__2011__of_Lower_Layer_Super_Output_Areas_in_England_and_Walestxt] ru				
				ON sp.Der_Postcode_LSOA_Code = ru.[LSOA11CD]			
			LEFT OUTER JOIN NHSE_Sandbox_DC.[dbo].[LSOA Population SAPE21DT1a-mid-2018-on-2019-LA-lsoa-syoa-estimates-formattedtxt] pop				
				ON sp.Der_Postcode_LSOA_Code = pop.LSOA_Code			
							
				left outer join NHSE_Reference.dbo.vw_Ref_ODS_Commissioner_AllOrgs com			
		on der.Responsible_Purchaser_Code = com.Org_Code																					
													
	WHERE												
			cc.Unbundled_HRG like 'XC%'				
			AND sp.Der_Activity_Month between 201504 and 202203				
			AND pr.Provider_Code like 'R%' --AND cc.CC_Type = 'ACC' --AND cc.CC_Patient_Type  = 'ADU'				
			AND CC_Days_LOS >= Advanced_Resp_Supp_Days				
			AND CC_Days_LOS > 0				
			AND lsoa.Effective_Snapshot_Date = '2019-12-31'				
			and cost.Tariff_Type like 'Non-elective%'														
													
	GROUP BY sp.Der_Financial_Year
			, sp.Der_Postcode_LSOA_2011_Code																									
	) ,


HRG_Elective_Weights (FinYear, HRG_Code, HRG_Desc, CC_Weight) AS 							
(
	SELECT sp.Der_Financial_Year,
			hrg.HRG_Code,
		   hrg.HRG_Desc,
			sum(CASE 				
					WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067 		
					WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587 	
					WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847 		
					WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.00	
					WHEN cc.Unbundled_HRG = 'XC05Z'		
							THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)* 0.8475)
					WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS* 0.6425 -- 1-org ARS distinction removed per clinical advice		
					WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203 	
			ELSE CC_Days_LOS*1.00				
			END) --AS 'CostWeightedBeddaysPerSpell'				
			/				
			count(der.APCS_Ident) --AS 'Spells'
			AS 'CC_Weight'
	FROM  NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc
		JOIN  NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp
			ON cc.APCS_Ident = sp.APCS_Ident
		JOIN NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Der der
			ON sp.APCS_Ident = der.APCS_Ident
		LEFT OUTER JOIN NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Cost cost
			on sp.apcs_ident = cost.apcs_ident
		LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg
			ON der.Spell_Core_HRG = hrg.HRG_Code
	WHERE sp.Der_Activity_Month between 201504 and 202203	
		and	sp.Der_Age_at_CDS_Activity_Date > 17
		and cost.Tariff_Type LIKE 'Elective%'
		AND sp.Der_Provider_Code like 'R%' 
		AND cc.CC_Type = 'ACC' --AND cc.CC_Patient_Type  = 'ADU'				
	
	GROUP BY sp.Der_Financial_Year, hrg.HRG_Code, hrg.HRG_Desc
) ,							
							
LSOA_Elective_Activity (FinYear, LSOA_Code, HRG, Elective_Spells, Elective_LOS) AS							
(							
	SELECT	sp.Der_Financial_Year
			, sp.Der_Postcode_LSOA_2011_Code
			, DER.Spell_Core_HRG as 'HRG_Code'
			, count(*) as 'Elective_Spells'
			, sum(der.Spell_PbR_Adj_LoS) as 'Elective_LOS_PbR_Adj'
	FROM NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp
		left outer join NHSE_Reference.dbo.vw_Ref_ODS_ProviderSite_Provider pr					
			on sp.Der_Provider_Code = pr.Provider_Code				
		left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Der der					
			on sp.APCS_Ident = der.APCS_Ident				
		left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Cost co					
			on sp.APCS_Ident = co.APCS_Ident	
	WHERE sp.Der_Activity_Month between 201504 and 202203					
		and	sp.Der_Age_at_CDS_Activity_Date > 17				
		and co.Tariff_Type LIKE 'Elective%'					
		and sp.Der_Provider_Code like 'R%'			
					
	GROUP BY sp.Der_Financial_Year
			 , sp.Der_Postcode_LSOA_2011_Code
			 , DER.Spell_Core_HRG								
),

Elective_ACC (FinYear, LSOA_Code, CC_Days_Unweighted_EL, ACC_CWRU_El) AS							
(							
	SELECT  sp.Der_Financial_Year, 
			sp.Der_Postcode_LSOA_2011_Code,								
			 sum(CC_Days_LOS) as 'CC_Days_Unweighted_EL',
			 sum(CASE 				
					WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067 		
					WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587 	
					WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847 		
					WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.00	
					WHEN cc.Unbundled_HRG = 'XC05Z'		
							THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)* 0.8475)
					WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS* 0.6425 -- 1-org ARS distinction removed per clinical advice		
					WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203 	
			ELSE CC_Days_LOS*1.00				
			END) AS 'Elective_CWRU'

	FROM  NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc					
			JOIN  NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp 				
				ON cc.APCS_Ident = sp.APCS_Ident			
			JOIN NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Der der				
				ON sp.APCS_Ident = der.APCS_Ident			
			JOIN NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Cost cost				
				ON sp.APCS_Ident = cost.APCS_Ident			
			LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr				
				ON sp.Der_Provider_Site_Code = pr.Provider_Site_Code			
			JOIN NHSE_Reference.dbo.vw_Ref_ODS_Commissioner_AllOrgs co				
				ON sp.Der_Commissioner_Code = co.Org_Code			
			LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_ODS_CCG ccg -- IDENTIFIES CCG OF RESIDENCE				
				ON sp.Der_Postcode_CCG_Code = ccg.Org_Code			
			LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_ACM_National_POD pod				
				ON der.National_POD_Code = pod.National_POD_Code		
			LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg				
				ON der.Spell_Core_HRG = hrg.HRG_Code
			left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrgu				
				on cc.Unbundled_HRG = hrgu.HRG_Code			
			LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_ODS_LSOA lsoan -- LSOAname				
				ON sp.Der_Postcode_LSOA_Code = lsoan.LSOA
			LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_Other_Deprivation_By_LSOA lsoa				
				ON sp.Der_Postcode_LSOA_Code = lsoa.LSOA_Code			
			left outer join NHSE_Reference.dbo.tbl_Ref_Other_CCGToSTP stp				
				on ccg.Org_Code = stp.CCG_Code			
			left outer join NHSE_Reference.dbo.tbl_Ref_ODS_CCGToRegion re				
				on sp.Der_Postcode_CCG_Code = re.CCG_Code			
			left outer join NHSE_Reference.dbo.tbl_Ref_ODS_Region reg				
				on re.Region_Code = reg.Region_Code			
			left outer join NHSE_Reference.dbo.tbl_Ref_Other_ProvToRegion rep				
				on pr.Provider_Code = rep.Provider_Code			
			left outer join NHSE_Reference.dbo.tbl_Ref_ODS_Region regp				
				on rep.Region_Code = regp.Region_Code					
			LEFT OUTER JOIN NHSE_Sandbox_DC.[dbo].[LSOA Population SAPE21DT1a-mid-2018-on-2019-LA-lsoa-syoa-estimates-formattedtxt] pop				
				ON sp.Der_Postcode_LSOA_Code = pop.LSOA_Code			
							
				left outer join NHSE_Reference.dbo.vw_Ref_ODS_Commissioner_AllOrgs com			
		on der.Responsible_Purchaser_Code = com.Org_Code								
							
	WHERE 
				cc.Unbundled_HRG like 'XC%'				
			AND sp.Der_Activity_Month between 201504 and 202203				
			AND pr.Provider_Code like 'R%' --AND cc.CC_Type = 'ACC' --AND cc.CC_Patient_Type  = 'ADU'				
			AND CC_Days_LOS >= Advanced_Resp_Supp_Days				
			AND CC_Days_LOS > 0				
			AND lsoa.Effective_Snapshot_Date = '2019-12-31'				
			and cost.Tariff_Type like 'Elective%'			
		
	GROUP BY sp.Der_Financial_Year, sp.Der_Postcode_LSOA_2011_Code
			
),
--dummy line!
--DominantProvider_cte (LSOA_Code, [R0A],[R0B],[R0D],[R1F],[R1H],[R1K],[RA2],[RA3],[RA4],[RA7],[RA9],[RAE],[RAJ],[RAL],[RAN],[RAP],[RAS],[RAX],[RBA],[RBD],[RBK],[RBL],[RBN],[RBQ],[RBS],[RBT],[RBV],[RBZ],[RC1],[RC9],[RCB],[RCD],[RCF],[RCU],[RCX],[RD1],[RD3],[RD7],[RD8],[RDD],[RDE],[RDU],[RDZ],[RE9],[REF],[REM],[REP],[RET],[RF4],[RFF],[RFR],[RFS],[RFW],[RGM],[RGN],[RGP],[RGQ],[RGR],[RGT],[RH5],[RH8],[RHM],[RHQ],[RHU],[RHW],[RJ1],[RJ2],[RJ6],[RJ7],[RJC],[RJE],[RJF],[RJL],[RJN],[RJR],[RJZ],[RK5],[RK9],[RKB],[RKE],[RL1],[RL4],[RLN],[RLQ],[RLT],[RLU],[RM1],[RM2],[RM3],[RMC],[RMP],[RN3],[RN5],[RN7],[RNA],[RNL],[RNN],[RNQ],[RNS],[RNZ],[RP4],[RP5],[RPA],[RPC],[RPY],[RQ3],[RQ6],[RQ8],[RQM],[RQQ],[RQW],[RQX],[RR1],[RR7],[RR8],[RRF],[RRJ],[RRK],[RRV],[RT3],[RTD],[RTE],[RTF],[RTG],[RTH],[RTK],[RTP],[RTR],[RTX],[RVJ],[RVL],[RVR],[RVV],[RVW],[RVY],[RW3],[RW6],[RWA],[RWD],[RWE],[RWF],[RWG],[RWH],[RWJ],[RWP],[RWW],[RWY],[RX1],[RXC],[RXF],[RXH],[RXK],[RXL],[RXN],[RXP],[RXQ],[RXR],[RXW],[RYJ],[RYR],[RZ1],[RNH],[R1E],[RYV], LSOA_total_CCdays)

--AS (
--		SELECT LSOA_Code, ISNULL([R0A],0) AS [R0A],ISNULL([R0B],0) AS [R0B],ISNULL([R0D],0) AS [R0D],ISNULL([R1F],0) AS [R1F],ISNULL([R1H],0) AS [R1H],ISNULL([R1K],0) AS [R1K],ISNULL([RA2],0) AS [RA2],ISNULL([RA3],0) AS [RA3],ISNULL([RA4],0) AS [RA4],ISNULL([RA7],0) AS [RA7],ISNULL([RA9],0) AS [RA9],ISNULL([RAE],0) AS [RAE],ISNULL([RAJ],0) AS [RAJ],ISNULL([RAL],0) AS [RAL],ISNULL([RAN],0) AS [RAN],ISNULL([RAP],0) AS [RAP],ISNULL([RAS],0) AS [RAS],ISNULL([RAX],0) AS [RAX],ISNULL([RBA],0) AS [RBA],ISNULL([RBD],0) AS [RBD],ISNULL([RBK],0) AS [RBK],ISNULL([RBL],0) AS [RBL],ISNULL([RBN],0) AS [RBN],ISNULL([RBQ],0) AS [RBQ],ISNULL([RBS],0) AS [RBS],ISNULL([RBT],0) AS [RBT],ISNULL([RBV],0) AS [RBV],ISNULL([RBZ],0) AS [RBZ],ISNULL([RC1],0) AS [RC1],ISNULL([RC9],0) AS [RC9],ISNULL([RCB],0) AS [RCB],ISNULL([RCD],0) AS [RCD],ISNULL([RCF],0) AS [RCF],ISNULL([RCU],0) AS [RCU],ISNULL([RCX],0) AS [RCX],ISNULL([RD1],0) AS [RD1],ISNULL([RD3],0) AS [RD3],ISNULL([RD7],0) AS [RD7],ISNULL([RD8],0) AS [RD8],ISNULL([RDD],0) AS [RDD],ISNULL([RDE],0) AS [RDE],ISNULL([RDU],0) AS [RDU],ISNULL([RDZ],0) AS [RDZ],ISNULL([RE9],0) AS [RE9],ISNULL([REF],0) AS [REF],ISNULL([REM],0) AS [REM],ISNULL([REP],0) AS [REP],ISNULL([RET],0) AS [RET],ISNULL([RF4],0) AS [RF4],ISNULL([RFF],0) AS [RFF],ISNULL([RFR],0) AS [RFR],ISNULL([RFS],0) AS [RFS],ISNULL([RFW],0) AS [RFW],ISNULL([RGM],0) AS [RGM],ISNULL([RGN],0) AS [RGN],ISNULL([RGP],0) AS [RGP],ISNULL([RGQ],0) AS [RGQ],ISNULL([RGR],0) AS [RGR],ISNULL([RGT],0) AS [RGT],ISNULL([RH5],0) AS [RH5],ISNULL([RH8],0) AS [RH8],ISNULL([RHM],0) AS [RHM],ISNULL([RHQ],0) AS [RHQ],ISNULL([RHU],0) AS [RHU],ISNULL([RHW],0) AS [RHW],ISNULL([RJ1],0) AS [RJ1],ISNULL([RJ2],0) AS [RJ2],ISNULL([RJ6],0) AS [RJ6],ISNULL([RJ7],0) AS [RJ7],ISNULL([RJC],0) AS [RJC],ISNULL([RJE],0) AS [RJE],ISNULL([RJF],0) AS [RJF],ISNULL([RJL],0) AS [RJL],ISNULL([RJN],0) AS [RJN],ISNULL([RJR],0) AS [RJR],ISNULL([RJZ],0) AS [RJZ],ISNULL([RK5],0) AS [RK5],ISNULL([RK9],0) AS [RK9],ISNULL([RKB],0) AS [RKB],ISNULL([RKE],0) AS [RKE],ISNULL([RL1],0) AS [RL1],ISNULL([RL4],0) AS [RL4],ISNULL([RLN],0) AS [RLN],ISNULL([RLQ],0) AS [RLQ],ISNULL([RLT],0) AS [RLT],ISNULL([RLU],0) AS [RLU],ISNULL([RM1],0) AS [RM1],ISNULL([RM2],0) AS [RM2],ISNULL([RM3],0) AS [RM3],ISNULL([RMC],0) AS [RMC],ISNULL([RMP],0) AS [RMP],ISNULL([RN3],0) AS [RN3],ISNULL([RN5],0) AS [RN5],ISNULL([RN7],0) AS [RN7],ISNULL([RNA],0) AS [RNA],ISNULL([RNL],0) AS [RNL],ISNULL([RNN],0) AS [RNN],ISNULL([RNQ],0) AS [RNQ],ISNULL([RNS],0) AS [RNS],ISNULL([RNZ],0) AS [RNZ],ISNULL([RP4],0) AS [RP4],ISNULL([RP5],0) AS [RP5],ISNULL([RPA],0) AS [RPA],ISNULL([RPC],0) AS [RPC],ISNULL([RPY],0) AS [RPY],ISNULL([RQ3],0) AS [RQ3],ISNULL([RQ6],0) AS [RQ6],ISNULL([RQ8],0) AS [RQ8],ISNULL([RQM],0) AS [RQM],ISNULL([RQQ],0) AS [RQQ],ISNULL([RQW],0) AS [RQW],ISNULL([RQX],0) AS [RQX],ISNULL([RR1],0) AS [RR1],ISNULL([RR7],0) AS [RR7],ISNULL([RR8],0) AS [RR8],ISNULL([RRF],0) AS [RRF],ISNULL([RRJ],0) AS [RRJ],ISNULL([RRK],0) AS [RRK],ISNULL([RRV],0) AS [RRV],ISNULL([RT3],0) AS [RT3],ISNULL([RTD],0) AS [RTD],ISNULL([RTE],0) AS [RTE],ISNULL([RTF],0) AS [RTF],ISNULL([RTG],0) AS [RTG],ISNULL([RTH],0) AS [RTH],ISNULL([RTK],0) AS [RTK],ISNULL([RTP],0) AS [RTP],ISNULL([RTR],0) AS [RTR],ISNULL([RTX],0) AS [RTX],ISNULL([RVJ],0) AS [RVJ],ISNULL([RVL],0) AS [RVL],ISNULL([RVR],0) AS [RVR],ISNULL([RVV],0) AS [RVV],ISNULL([RVW],0) AS [RVW],ISNULL([RVY],0) AS [RVY],ISNULL([RW3],0) AS [RW3],ISNULL([RW6],0) AS [RW6],ISNULL([RWA],0) AS [RWA],ISNULL([RWD],0) AS [RWD],ISNULL([RWE],0) AS [RWE],ISNULL([RWF],0) AS [RWF],ISNULL([RWG],0) AS [RWG],ISNULL([RWH],0) AS [RWH],ISNULL([RWJ],0) AS [RWJ],ISNULL([RWP],0) AS [RWP],ISNULL([RWW],0) AS [RWW],ISNULL([RWY],0) AS [RWY],ISNULL([RX1],0) AS [RX1],ISNULL([RXC],0) AS [RXC],ISNULL([RXF],0) AS [RXF],ISNULL([RXH],0) AS [RXH],ISNULL([RXK],0) AS [RXK],ISNULL([RXL],0) AS [RXL],ISNULL([RXN],0) AS [RXN],ISNULL([RXP],0) AS [RXP],ISNULL([RXQ],0) AS [RXQ],ISNULL([RXR],0) AS [RXR],ISNULL([RXW],0) AS [RXW],ISNULL([RYJ],0) AS [RYJ],ISNULL([RYR],0) AS [RYR],ISNULL([RZ1],0) AS [RZ1],ISNULL([RNH],0) AS [RNH],ISNULL([R1E],0) AS [R1E],ISNULL([RYV],0) AS [RYV], LSOA_total_CCdays

--		FROM 
--			(
--			SELECT m.LSOA_Code,
--					m.Provider_Code,
--					m.CC_Days_LOS,
--					(SUM(m.CC_Days_LOS) OVER(PARTITION BY m.LSOA_Code)) AS 'LSOA_total_CCdays',

--					CASE WHEN m.CC_Days_LOS = 0 THEN 0
--						ELSE cast((m.CC_Days_LOS/(SUM(m.CC_Days_LOS) OVER(PARTITION BY m.LSOA_Code))) AS FLOAT) END AS 'Prov_percent_of_LSOA'

--			FROM
--					(
--						SELECT sp.Der_Postcode_LSOA_2011_Code AS 'LSOA_Code', 
--								sp.Der_Provider_Code as 'Provider_Code', 
--								SUM(cc.CC_Days_LOS) as 'CC_Days_LOS'
--						FROM NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc
--							left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp
--							on cc.APCS_Ident = sp.APCS_Ident
--						WHERE sp.Der_Provider_Code like 'R%'
--								AND cc.Unbundled_HRG like 'XC%'											
--								AND sp.Der_Activity_Month between 201804 and 201903																					
--								AND CC_Days_LOS >= Advanced_Resp_Supp_Days
--						GROUP BY sp.Der_Postcode_LSOA_2011_Code, sp.Der_Provider_Code
--					) m
--			) tbl

--		PIVOT (
--		SUM(CC_Days_LOS)
--		FOR Provider_Code in ([R0A],[R0B],[R0D],[R1F],[R1H],[R1K],[RA2],[RA3],[RA4],[RA7],[RA9],[RAE],[RAJ],[RAL],[RAN],[RAP],[RAS],[RAX],[RBA],[RBD],[RBK],[RBL],[RBN],[RBQ],[RBS],[RBT],[RBV],[RBZ],[RC1],[RC9],[RCB],[RCD],[RCF],[RCU],[RCX],[RD1],[RD3],[RD7],[RD8],[RDD],[RDE],[RDU],[RDZ],[RE9],[REF],[REM],[REP],[RET],[RF4],[RFF],[RFR],[RFS],[RFW],[RGM],[RGN],[RGP],[RGQ],[RGR],[RGT],[RH5],[RH8],[RHM],[RHQ],[RHU],[RHW],[RJ1],[RJ2],[RJ6],[RJ7],[RJC],[RJE],[RJF],[RJL],[RJN],[RJR],[RJZ],[RK5],[RK9],[RKB],[RKE],[RL1],[RL4],[RLN],[RLQ],[RLT],[RLU],[RM1],[RM2],[RM3],[RMC],[RMP],[RN3],[RN5],[RN7],[RNA],[RNL],[RNN],[RNQ],[RNS],[RNZ],[RP4],[RP5],[RPA],[RPC],[RPY],[RQ3],[RQ6],[RQ8],[RQM],[RQQ],[RQW],[RQX],[RR1],[RR7],[RR8],[RRF],[RRJ],[RRK],[RRV],[RT3],[RTD],[RTE],[RTF],[RTG],[RTH],[RTK],[RTP],[RTR],[RTX],[RVJ],[RVL],[RVR],[RVV],[RVW],[RVY],[RW3],[RW6],[RWA],[RWD],[RWE],[RWF],[RWG],[RWH],[RWJ],[RWP],[RWW],[RWY],[RX1],[RXC],[RXF],[RXH],[RXK],[RXL],[RXN],[RXP],[RXQ],[RXR],[RXW],[RYJ],[RYR],[RZ1],[RNH],[R1E],[RYV])
--		) as pvt
--	),

OwningCCG_cte 

(LSOA_Code, [03R],[01W],[02T],[07L],[09N],[07K],[06K],[99M],[08M],[03V],[07N],[02H],[09L],[08T],[04Q],[08H],[01T],[03F],[09D],[01H],[05V],[06W],[09A],[06D],[05R],[03M],[04V],[11A],[11E],[02M],[05F],[00X],[08W],[03H],[00T],[02W],[02F],[09E],[06A],[06L],[09Y],[02N],[05T],[05H],[11X],[04Y],[15E],[99F],[06N],[04K],[07Y],[08D],[01F],[04D],[00P],[03J],[08K],[08N],[00R],[10X],[06Y],[04N],[02D],[01V],[00M],[02X],[07J],[13T],[02A],[05X],[07Q],[08A],[15D],[08X],[15C],[15A],[09J],[99H],[04E],[03Q],[09C],[08L],[00V],[11N],[01R],[08E],[04C],[04L],[05G],[12D],[11J],[02G],[05W],[08G],[02Y],[09P],[11M],[05N],[07H],[05L],[01J],[03A],[10L],[07P],[06P],[08Y],[03L],[03E],[01C],[00J],[05D],[07R],[04G],[06Q],[05A],[15N],[10J],[10C],[08J],[03D],[08C],[03K],[10R],[09F],[07V],[02E],[00Q],[01Y],[99C],[99K],[06V],[14L],[03N],[07M],[02P],[10V],[06H],[15F],[05Y],[99E],[01D],[09H],[10K],[04M],[99N],[06F],[07G],[99G],[10Q],[12F],[08Q],[01G],[03W],[04H],[02Q],[00Y],[99A],[01X],[00L],[99J],[01A],[10D],[08R],[15M],[04F],[99D],[01E],[01K],[09X],[10A],[07W],[00D],[05Q],[08V],[14Y],[00C],[05J],[02R],[03T],[00N],[09W],[06T],[06M],[10E],[09G],[05C],[08F],[07T],[07X],[00K],[08P])

AS (
	select LSOA_Code, [03R],[01W],[02T],[07L],[09N],[07K],[06K],[99M],[08M],[03V],[07N],[02H],[09L],[08T],[04Q],[08H],[01T],[03F],[09D],[01H],[05V],[06W],[09A],[06D],[05R],[03M],[04V],[11A],[11E],[02M],[05F],[00X],[08W],[03H],[00T],[02W],[02F],[09E],[06A],[06L],[09Y],[02N],[05T],[05H],[11X],[04Y],[15E],[99F],[06N],[04K],[07Y],[08D],[01F],[04D],[00P],[03J],[08K],[08N],[00R],[10X],[06Y],[04N],[02D],[01V],[00M],[02X],[07J],[13T],[02A],[05X],[07Q],[08A],[15D],[08X],[15C],[15A],[09J],[99H],[04E],[03Q],[09C],[08L],[00V],[11N],[01R],[08E],[04C],[04L],[05G],[12D],[11J],[02G],[05W],[08G],[02Y],[09P],[11M],[05N],[07H],[05L],[01J],[03A],[10L],[07P],[06P],[08Y],[03L],[03E],[01C],[00J],[05D],[07R],[04G],[06Q],[05A],[15N],[10J],[10C],[08J],[03D],[08C],[03K],[10R],[09F],[07V],[02E],[00Q],[01Y],[99C],[99K],[06V],[14L],[03N],[07M],[02P],[10V],[06H],[15F],[05Y],[99E],[01D],[09H],[10K],[04M],[99N],[06F],[07G],[99G],[10Q],[12F],[08Q],[01G],[03W],[04H],[02Q],[00Y],[99A],[01X],[00L],[99J],[01A],[10D],[08R],[15M],[04F],[99D],[01E],[01K],[09X],[10A],[07W],[00D],[05Q],[08V],[14Y],[00C],[05J],[02R],[03T],[00N],[09W],[06T],[06M],[10E],[09G],[05C],[08F],[07T],[07X],[00K],[08P]
	from
		(select l1.LSOA_Code,
				l3.CCG2019_Code as 'CCG_Code',
				1 AS 'Value'

		from NHSE_Reference.dbo.tbl_Ref_Other_Deprivation_By_LSOA l1
		left outer join NHSE_Reference.dbo.tbl_Ref_ODS_LSOA l2
			on l1.LSOA_Code = l2.LSOA
		left outer join NHSE_Sandbox_DC.dbo.LSOA_2011_to_CCG_Apr19 l3
			on l1.LSOA_Code = l3.LSOA2011_Code

		where Effective_Snapshot_Date = '2019-12-31'
		) x

		PIVOT (
		SUM(Value)
		FOR CCG_Code IN ([03R],[01W],[02T],[07L],[09N],[07K],[06K],[99M],[08M],[03V],[07N],[02H],[09L],[08T],[04Q],[08H],[01T],[03F],[09D],[01H],[05V],[06W],[09A],[06D],[05R],[03M],[04V],[11A],[11E],[02M],[05F],[00X],[08W],[03H],[00T],[02W],[02F],[09E],[06A],[06L],[09Y],[02N],[05T],[05H],[11X],[04Y],[15E],[99F],[06N],[04K],[07Y],[08D],[01F],[04D],[00P],[03J],[08K],[08N],[00R],[10X],[06Y],[04N],[02D],[01V],[00M],[02X],[07J],[13T],[02A],[05X],[07Q],[08A],[15D],[08X],[15C],[15A],[09J],[99H],[04E],[03Q],[09C],[08L],[00V],[11N],[01R],[08E],[04C],[04L],[05G],[12D],[11J],[02G],[05W],[08G],[02Y],[09P],[11M],[05N],[07H],[05L],[01J],[03A],[10L],[07P],[06P],[08Y],[03L],[03E],[01C],[00J],[05D],[07R],[04G],[06Q],[05A],[15N],[10J],[10C],[08J],[03D],[08C],[03K],[10R],[09F],[07V],[02E],[00Q],[01Y],[99C],[99K],[06V],[14L],[03N],[07M],[02P],[10V],[06H],[15F],[05Y],[99E],[01D],[09H],[10K],[04M],[99N],[06F],[07G],[99G],[10Q],[12F],[08Q],[01G],[03W],[04H],[02Q],[00Y],[99A],[01X],[00L],[99J],[01A],[10D],[08R],[15M],[04F],[99D],[01E],[01K],[09X],[10A],[07W],[00D],[05Q],[08V],[14Y],[00C],[05J],[02R],[03T],[00N],[09W],[06T],[06M],[10E],[09G],[05C],[08F],[07T],[07X],[00K],[08P])
		) as pv
	),

TempTable (FinYear, LSOA_Code, Elective_Spells, CC_Weighted_EL_Spells)
AS
(
	SELECT d.FinYear,
		d.LSOA_Code,
		SUM(case when (d.Elective_Spells*w.CC_Weight) is null 
			then 0 else (d.Elective_Spells) end) AS 'Elective_Spells',
		sum(case when (d.Elective_Spells*w.CC_Weight) is null 
			then 0 else (d.Elective_Spells*w.CC_Weight) end) as 'CC_Weighted_EL_Spells'				
	FROM LSOA_Elective_Activity d
	LEFT OUTER JOIN HRG_Elective_Weights w 						
		on d.HRG = w.hrg_code	
		and d.FinYear = w.HRG_Code
	WHERE w.HRG_Desc is not null
	GROUP BY d.FinYear, d.LSOA_Code
)

SELECT  b.FinYear,
	a.LSOA_Code, a.LSOA_Name, a.CCG_Code, a.CCG_Name, a.STP_Code, a.STP_Name, a.ICS_Code, a.ICS_Name,
	a.Population,
	((a.Pop_70_plus*a.Population)*Income_Deprivation_Affecting_Older_People_Index) as 'Pop70depr',
	((a.Pop_70_plus*Population) - ((a.Pop_70_plus*Population)*Income_Deprivation_Affecting_Older_People_Index)) as 'Pop70nonDepr',
	((Population - (a.Pop_70_plus*Population))*Employment_Deprivation_Domain) as 'PopUnder70depr',
	((Population - (a.Pop_70_plus*Population)) - ((Population - (a.Pop_70_plus*Population))*Employment_Deprivation_Domain)) as 'PopUnder70nonDepr',

	((a.Pop_70_plus*a.Population)*Income_Deprivation_Affecting_Older_People_Index)/Population as 'Pop70deprPRP',
	((a.Pop_70_plus*Population) - ((a.Pop_70_plus*Population)*Income_Deprivation_Affecting_Older_People_Index))/Population as 'Pop70nonDeprPRP',
	((Population - (a.Pop_70_plus*Population))*Employment_Deprivation_Domain)/Population as 'PopUnder70deprPRP',
	((Population - (a.Pop_70_plus*Population)) - ((Population - (a.Pop_70_plus*Population))*Employment_Deprivation_Domain))/Population as 'PopUnder70nonDeprPRP',

	c.nonWhiteProp,
	a.Population*c.nonWhiteProp 'nonWhite_Population',
	b.CC_Days_Unweighted_NEL as 'CC_Days_NEL_Unwgtd',
	case when b.CWRU_NEL is null 
		then 0 else b.CWRU_NEL end as 'CWRU_NEL',
		
	--els.LSOA_Code,
	els.Elective_Spells,
	els.CC_Weighted_EL_Spells,

	el.CC_Days_Unweighted_EL as 'CC_Days_EL_Unwgtd',
	case when el.ACC_CWRU_El is null 
		then 0 else el.ACC_CWRU_El end as 'CWRU_EL',

		[03R],[01W],[02T],[07L],[09N],[07K],[06K],[99M],[08M],[03V],[07N],[02H],[09L],[08T],[04Q],[08H],[01T],[03F],[09D],[01H],[05V],[06W],[09A],[06D],[05R],[03M],[04V],[11A],[11E],[02M],[05F],[00X],[08W],[03H],[00T],[02W],[02F],[09E],[06A],[06L],[09Y],[02N],[05T],[05H],[11X],[04Y],[15E],[99F],[06N],[04K],[07Y],[08D],[01F],[04D],[00P],[03J],[08K],[08N],[00R],[10X],[06Y],[04N],[02D],[01V],[00M],[02X],[07J],[13T],[02A],[05X],[07Q],[08A],[15D],[08X],[15C],[15A],[09J],[99H],[04E],[03Q],[09C],[08L],[00V],[11N],[01R],[08E],[04C],[04L],[05G],[12D],[11J],[02G],[05W],[08G],[02Y],[09P],[11M],[05N],[07H],[05L],[01J],[03A],[10L],[07P],[06P],[08Y],[03L],[03E],[01C],[00J],[05D],[07R],[04G],[06Q],[05A],[15N],[10J],[10C],[08J],[03D],[08C],[03K],[10R],[09F],[07V],[02E],[00Q],[01Y],[99C],[99K],[06V],[14L],[03N],[07M],[02P],[10V],[06H],[15F],[05Y],[99E],[01D],[09H],[10K],[04M],[99N],[06F],[07G],[99G],[10Q],[12F],[08Q],[01G],[03W],[04H],[02Q],[00Y],[99A],[01X],[00L],[99J],[01A],[10D],[08R],[15M],[04F],[99D],[01E],[01K],[09X],[10A],[07W],[00D],[05Q],[08V],[14Y],[00C],[05J],[02R],[03T],[00N],[09W],[06T],[06M],[10E],[09G],[05C],[08F],[07T],[07X],[00K],[08P]

--dummy line!
--		CAST(ISNULL([R0A],0)/pr.LSOA_total_CCdays as FLOAT) AS [R0A],CAST(ISNULL([R0B],0)/LSOA_total_CCdays as FLOAT) AS [R0B],CAST(ISNULL([R0D],0)/LSOA_total_CCdays as FLOAT) AS [R0D],CAST(ISNULL([R1F],0)/LSOA_total_CCdays as FLOAT) AS [R1F],CAST(ISNULL([R1H],0)/LSOA_total_CCdays as FLOAT) AS [R1H],CAST(ISNULL([R1K],0)/LSOA_total_CCdays as FLOAT) AS [R1K],CAST(ISNULL([RA2],0)/LSOA_total_CCdays as FLOAT) AS [RA2],CAST(ISNULL([RA3],0)/LSOA_total_CCdays as FLOAT) AS [RA3],CAST(ISNULL([RA4],0)/LSOA_total_CCdays as FLOAT) AS [RA4],CAST(ISNULL([RA7],0)/LSOA_total_CCdays as FLOAT) AS [RA7],CAST(ISNULL([RA9],0)/LSOA_total_CCdays as FLOAT) AS [RA9],CAST(ISNULL([RAE],0)/LSOA_total_CCdays as FLOAT) AS [RAE],CAST(ISNULL([RAJ],0)/LSOA_total_CCdays as FLOAT) AS [RAJ],CAST(ISNULL([RAL],0)/LSOA_total_CCdays as FLOAT) AS [RAL],CAST(ISNULL([RAN],0)/LSOA_total_CCdays as FLOAT) AS [RAN],CAST(ISNULL([RAP],0)/LSOA_total_CCdays as FLOAT) AS [RAP],CAST(ISNULL([RAS],0)/LSOA_total_CCdays as FLOAT) AS [RAS],CAST(ISNULL([RAX],0)/LSOA_total_CCdays as FLOAT) AS [RAX],CAST(ISNULL([RBA],0)/LSOA_total_CCdays as FLOAT) AS [RBA],CAST(ISNULL([RBD],0)/LSOA_total_CCdays as FLOAT) AS [RBD],CAST(ISNULL([RBK],0)/LSOA_total_CCdays as FLOAT) AS [RBK],CAST(ISNULL([RBL],0)/LSOA_total_CCdays as FLOAT) AS [RBL],CAST(ISNULL([RBN],0)/LSOA_total_CCdays as FLOAT) AS [RBN],CAST(ISNULL([RBQ],0)/LSOA_total_CCdays as FLOAT) AS [RBQ],CAST(ISNULL([RBS],0)/LSOA_total_CCdays as FLOAT) AS [RBS],CAST(ISNULL([RBT],0)/LSOA_total_CCdays as FLOAT) AS [RBT],CAST(ISNULL([RBV],0)/LSOA_total_CCdays as FLOAT) AS [RBV],CAST(ISNULL([RBZ],0)/LSOA_total_CCdays as FLOAT) AS [RBZ],CAST(ISNULL([RC1],0)/LSOA_total_CCdays as FLOAT) AS [RC1],CAST(ISNULL([RC9],0)/LSOA_total_CCdays as FLOAT) AS [RC9],CAST(ISNULL([RCB],0)/LSOA_total_CCdays as FLOAT) AS [RCB],CAST(ISNULL([RCD],0)/LSOA_total_CCdays as FLOAT) AS [RCD],CAST(ISNULL([RCF],0)/LSOA_total_CCdays as FLOAT) AS [RCF],CAST(ISNULL([RCU],0)/LSOA_total_CCdays as FLOAT) AS [RCU],CAST(ISNULL([RCX],0)/LSOA_total_CCdays as FLOAT) AS [RCX],CAST(ISNULL([RD1],0)/LSOA_total_CCdays as FLOAT) AS [RD1],CAST(ISNULL([RD3],0)/LSOA_total_CCdays as FLOAT) AS [RD3],CAST(ISNULL([RD7],0)/LSOA_total_CCdays as FLOAT) AS [RD7],CAST(ISNULL([RD8],0)/LSOA_total_CCdays as FLOAT) AS [RD8],CAST(ISNULL([RDD],0)/LSOA_total_CCdays as FLOAT) AS [RDD],CAST(ISNULL([RDE],0)/LSOA_total_CCdays as FLOAT) AS [RDE],CAST(ISNULL([RDU],0)/LSOA_total_CCdays as FLOAT) AS [RDU],CAST(ISNULL([RDZ],0)/LSOA_total_CCdays as FLOAT) AS [RDZ],CAST(ISNULL([RE9],0)/LSOA_total_CCdays as FLOAT) AS [RE9],CAST(ISNULL([REF],0)/LSOA_total_CCdays as FLOAT) AS [REF],CAST(ISNULL([REM],0)/LSOA_total_CCdays as FLOAT) AS [REM],CAST(ISNULL([REP],0)/LSOA_total_CCdays as FLOAT) AS [REP],CAST(ISNULL([RET],0)/LSOA_total_CCdays as FLOAT) AS [RET],CAST(ISNULL([RF4],0)/LSOA_total_CCdays as FLOAT) AS [RF4],CAST(ISNULL([RFF],0)/LSOA_total_CCdays as FLOAT) AS [RFF],CAST(ISNULL([RFR],0)/LSOA_total_CCdays as FLOAT) AS [RFR],CAST(ISNULL([RFS],0)/LSOA_total_CCdays as FLOAT) AS [RFS],CAST(ISNULL([RFW],0)/LSOA_total_CCdays as FLOAT) AS [RFW],CAST(ISNULL([RGM],0)/LSOA_total_CCdays as FLOAT) AS [RGM],CAST(ISNULL([RGN],0)/LSOA_total_CCdays as FLOAT) AS [RGN],CAST(ISNULL([RGP],0)/LSOA_total_CCdays as FLOAT) AS [RGP],CAST(ISNULL([RGQ],0)/LSOA_total_CCdays as FLOAT) AS [RGQ],CAST(ISNULL([RGR],0)/LSOA_total_CCdays as FLOAT) AS [RGR],CAST(ISNULL([RGT],0)/LSOA_total_CCdays as FLOAT) AS [RGT],CAST(ISNULL([RH5],0)/LSOA_total_CCdays as FLOAT) AS [RH5],CAST(ISNULL([RH8],0)/LSOA_total_CCdays as FLOAT) AS [RH8],CAST(ISNULL([RHM],0)/LSOA_total_CCdays as FLOAT) AS [RHM],CAST(ISNULL([RHQ],0)/LSOA_total_CCdays as FLOAT) AS [RHQ],CAST(ISNULL([RHU],0)/LSOA_total_CCdays as FLOAT) AS [RHU],CAST(ISNULL([RHW],0)/LSOA_total_CCdays as FLOAT) AS [RHW],CAST(ISNULL([RJ1],0)/LSOA_total_CCdays as FLOAT) AS [RJ1],CAST(ISNULL([RJ2],0)/LSOA_total_CCdays as FLOAT) AS [RJ2],CAST(ISNULL([RJ6],0)/LSOA_total_CCdays as FLOAT) AS [RJ6],CAST(ISNULL([RJ7],0)/LSOA_total_CCdays as FLOAT) AS [RJ7],CAST(ISNULL([RJC],0)/LSOA_total_CCdays as FLOAT) AS [RJC],CAST(ISNULL([RJE],0)/LSOA_total_CCdays as FLOAT) AS [RJE],CAST(ISNULL([RJF],0)/LSOA_total_CCdays as FLOAT) AS [RJF],CAST(ISNULL([RJL],0)/LSOA_total_CCdays as FLOAT) AS [RJL],CAST(ISNULL([RJN],0)/LSOA_total_CCdays as FLOAT) AS [RJN],CAST(ISNULL([RJR],0)/LSOA_total_CCdays as FLOAT) AS [RJR],CAST(ISNULL([RJZ],0)/LSOA_total_CCdays as FLOAT) AS [RJZ],CAST(ISNULL([RK5],0)/LSOA_total_CCdays as FLOAT) AS [RK5],CAST(ISNULL([RK9],0)/LSOA_total_CCdays as FLOAT) AS [RK9],CAST(ISNULL([RKB],0)/LSOA_total_CCdays as FLOAT) AS [RKB],CAST(ISNULL([RKE],0)/LSOA_total_CCdays as FLOAT) AS [RKE],CAST(ISNULL([RL1],0)/LSOA_total_CCdays as FLOAT) AS [RL1],CAST(ISNULL([RL4],0)/LSOA_total_CCdays as FLOAT) AS [RL4],CAST(ISNULL([RLN],0)/LSOA_total_CCdays as FLOAT) AS [RLN],CAST(ISNULL([RLQ],0)/LSOA_total_CCdays as FLOAT) AS [RLQ],CAST(ISNULL([RLT],0)/LSOA_total_CCdays as FLOAT) AS [RLT],CAST(ISNULL([RLU],0)/LSOA_total_CCdays as FLOAT) AS [RLU],CAST(ISNULL([RM1],0)/LSOA_total_CCdays as FLOAT) AS [RM1],CAST(ISNULL([RM2],0)/LSOA_total_CCdays as FLOAT) AS [RM2],CAST(ISNULL([RM3],0)/LSOA_total_CCdays as FLOAT) AS [RM3],CAST(ISNULL([RMC],0)/LSOA_total_CCdays as FLOAT) AS [RMC],CAST(ISNULL([RMP],0)/LSOA_total_CCdays as FLOAT) AS [RMP],CAST(ISNULL([RN3],0)/LSOA_total_CCdays as FLOAT) AS [RN3],CAST(ISNULL([RN5],0)/LSOA_total_CCdays as FLOAT) AS [RN5],CAST(ISNULL([RN7],0)/LSOA_total_CCdays as FLOAT) AS [RN7],CAST(ISNULL([RNA],0)/LSOA_total_CCdays as FLOAT) AS [RNA],CAST(ISNULL([RNL],0)/LSOA_total_CCdays as FLOAT) AS [RNL],CAST(ISNULL([RNN],0)/LSOA_total_CCdays as FLOAT) AS [RNN],CAST(ISNULL([RNQ],0)/LSOA_total_CCdays as FLOAT) AS [RNQ],CAST(ISNULL([RNS],0)/LSOA_total_CCdays as FLOAT) AS [RNS],CAST(ISNULL([RNZ],0)/LSOA_total_CCdays as FLOAT) AS [RNZ],CAST(ISNULL([RP4],0)/LSOA_total_CCdays as FLOAT) AS [RP4],CAST(ISNULL([RP5],0)/LSOA_total_CCdays as FLOAT) AS [RP5],CAST(ISNULL([RPA],0)/LSOA_total_CCdays as FLOAT) AS [RPA],CAST(ISNULL([RPC],0)/LSOA_total_CCdays as FLOAT) AS [RPC],CAST(ISNULL([RPY],0)/LSOA_total_CCdays as FLOAT) AS [RPY],CAST(ISNULL([RQ3],0)/LSOA_total_CCdays as FLOAT) AS [RQ3],CAST(ISNULL([RQ6],0)/LSOA_total_CCdays as FLOAT) AS [RQ6],CAST(ISNULL([RQ8],0)/LSOA_total_CCdays as FLOAT) AS [RQ8],CAST(ISNULL([RQM],0)/LSOA_total_CCdays as FLOAT) AS [RQM],CAST(ISNULL([RQQ],0)/LSOA_total_CCdays as FLOAT) AS [RQQ],CAST(ISNULL([RQW],0)/LSOA_total_CCdays as FLOAT) AS [RQW],CAST(ISNULL([RQX],0)/LSOA_total_CCdays as FLOAT) AS [RQX],CAST(ISNULL([RR1],0)/LSOA_total_CCdays as FLOAT) AS [RR1],CAST(ISNULL([RR7],0)/LSOA_total_CCdays as FLOAT) AS [RR7],CAST(ISNULL([RR8],0)/LSOA_total_CCdays as FLOAT) AS [RR8],CAST(ISNULL([RRF],0)/LSOA_total_CCdays as FLOAT) AS [RRF],CAST(ISNULL([RRJ],0)/LSOA_total_CCdays as FLOAT) AS [RRJ],CAST(ISNULL([RRK],0)/LSOA_total_CCdays as FLOAT) AS [RRK],CAST(ISNULL([RRV],0)/LSOA_total_CCdays as FLOAT) AS [RRV],CAST(ISNULL([RT3],0)/LSOA_total_CCdays as FLOAT) AS [RT3],CAST(ISNULL([RTD],0)/LSOA_total_CCdays as FLOAT) AS [RTD],CAST(ISNULL([RTE],0)/LSOA_total_CCdays as FLOAT) AS [RTE],CAST(ISNULL([RTF],0)/LSOA_total_CCdays as FLOAT) AS [RTF],CAST(ISNULL([RTG],0)/LSOA_total_CCdays as FLOAT) AS [RTG],CAST(ISNULL([RTH],0)/LSOA_total_CCdays as FLOAT) AS [RTH],CAST(ISNULL([RTK],0)/LSOA_total_CCdays as FLOAT) AS [RTK],CAST(ISNULL([RTP],0)/LSOA_total_CCdays as FLOAT) AS [RTP],CAST(ISNULL([RTR],0)/LSOA_total_CCdays as FLOAT) AS [RTR],CAST(ISNULL([RTX],0)/LSOA_total_CCdays as FLOAT) AS [RTX],CAST(ISNULL([RVJ],0)/LSOA_total_CCdays as FLOAT) AS [RVJ],CAST(ISNULL([RVL],0)/LSOA_total_CCdays as FLOAT) AS [RVL],CAST(ISNULL([RVR],0)/LSOA_total_CCdays as FLOAT) AS [RVR],CAST(ISNULL([RVV],0)/LSOA_total_CCdays as FLOAT) AS [RVV],CAST(ISNULL([RVW],0)/LSOA_total_CCdays as FLOAT) AS [RVW],CAST(ISNULL([RVY],0)/LSOA_total_CCdays as FLOAT) AS [RVY],CAST(ISNULL([RW3],0)/LSOA_total_CCdays as FLOAT) AS [RW3],CAST(ISNULL([RW6],0)/LSOA_total_CCdays as FLOAT) AS [RW6],CAST(ISNULL([RWA],0)/LSOA_total_CCdays as FLOAT) AS [RWA],CAST(ISNULL([RWD],0)/LSOA_total_CCdays as FLOAT) AS [RWD],CAST(ISNULL([RWE],0)/LSOA_total_CCdays as FLOAT) AS [RWE],CAST(ISNULL([RWF],0)/LSOA_total_CCdays as FLOAT) AS [RWF],CAST(ISNULL([RWG],0)/LSOA_total_CCdays as FLOAT) AS [RWG],CAST(ISNULL([RWH],0)/LSOA_total_CCdays as FLOAT) AS [RWH],CAST(ISNULL([RWJ],0)/LSOA_total_CCdays as FLOAT) AS [RWJ],CAST(ISNULL([RWP],0)/LSOA_total_CCdays as FLOAT) AS [RWP],CAST(ISNULL([RWW],0)/LSOA_total_CCdays as FLOAT) AS [RWW],CAST(ISNULL([RWY],0)/LSOA_total_CCdays as FLOAT) AS [RWY],CAST(ISNULL([RX1],0)/LSOA_total_CCdays as FLOAT) AS [RX1],CAST(ISNULL([RXC],0)/LSOA_total_CCdays as FLOAT) AS [RXC],CAST(ISNULL([RXF],0)/LSOA_total_CCdays as FLOAT) AS [RXF],CAST(ISNULL([RXH],0)/LSOA_total_CCdays as FLOAT) AS [RXH],CAST(ISNULL([RXK],0)/LSOA_total_CCdays as FLOAT) AS [RXK],CAST(ISNULL([RXL],0)/LSOA_total_CCdays as FLOAT) AS [RXL],CAST(ISNULL([RXN],0)/LSOA_total_CCdays as FLOAT) AS [RXN],CAST(ISNULL([RXP],0)/LSOA_total_CCdays as FLOAT) AS [RXP],CAST(ISNULL([RXQ],0)/LSOA_total_CCdays as FLOAT) AS [RXQ],CAST(ISNULL([RXR],0)/LSOA_total_CCdays as FLOAT) AS [RXR],CAST(ISNULL([RXW],0)/LSOA_total_CCdays as FLOAT) AS [RXW],CAST(ISNULL([RYJ],0)/LSOA_total_CCdays as FLOAT) AS [RYJ],CAST(ISNULL([RYR],0)/LSOA_total_CCdays as FLOAT) AS [RYR],CAST(ISNULL([RZ1],0)/LSOA_total_CCdays as FLOAT) AS [RZ1],CAST(ISNULL([RNH],0)/LSOA_total_CCdays as FLOAT) AS [RNH],CAST(ISNULL([R1E],0)/LSOA_total_CCdays as FLOAT) AS [R1E],CAST(ISNULL([RYV],0)/LSOA_total_CCdays as FLOAT) AS [RYV]


from LSOA_baseTable a
	left outer join CWRU_NEL_cte b
		on a.LSOA_Code = b.LSOA_Code
	left outer join ETHN_cte c
		on a.LSOA_Code = c.LSOA_Code
	left outer join TempTable els
		on b.LSOA_Code = els.LSOA_Code
		and b.FinYear = els.FinYear
	left outer join Elective_ACC el
		on b.LSOA_Code = el.LSOA_Code	
		and b.FinYear = el.FinYear
	left outer join OwningCCG_cte ccg
		on b.LSOA_Code = ccg.LSOA_Code
	--left outer join DominantProvider_cte pr
	--	on a.LSOA_Code = pr.LSOA_Code

--END;