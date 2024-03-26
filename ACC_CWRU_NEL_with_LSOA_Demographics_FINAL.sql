WITH 

LSOA_cte (LSOA_Code, LSOA_Name, CCG_Code, CCG_Name, STP_Code, STP_Name, ICS_Code, ICS_Name,
			Pop_70_plus, Population, IMD_Score, IMD_Decile, Employment_Deprivation_Domain, Income_Deprivation_Affecting_Older_People_Index) 

AS (SELECT lsoa.LSOA_Code,	lsoan.LSOA_Name, ccg.CCG2019_Code, ccg.CCG2019_Name, ics.STP21, ics.STP21_42_STP_name_from_ODS_API_April_2021, ics.ICS, ics.ICS_Name,
			cast(pop.[70_plus_prop] as float) 'Pop_70_plus',								
			cast(replace((case when substring(pop.Population_all,1,1) = '"'							
					then substring(pop.Population_all,2,len(pop.Population_all)-2)					
					else pop.Population_all end),',','') as int) as 'Population',			
			lsoa.IMD_Score as 'IMD_Score', -- MAX Aggregation chosen only to ensure no duplication										
			lsoa.IMD_Decile as 'IMD_Decile',										
			--dd.Barriers_to_Housing_and_Services_Domain,										
			--dd.Crime_Domain,										
			--dd.Education_Skills_and_Training_Domain,										
			dd.Employment_Deprivation_Domain,										
			--dd.Health_Deprivation_and_Disability_Domain,										
			--dd.Income_Deprivation_Domain,										
			--dd.Income_Deprivation_Affecting_Children_Index,										
			dd.Income_Deprivation_Affecting_Older_People_Index								
			--dd.Living_Environment_Deprivation_Domain,										
			--dd.Index_of_Multiple_Deprivation
	 FROM NHSE_Reference.dbo.tbl_Ref_Other_Deprivation_By_LSOA lsoa	
		LEFT OUTER JOIN   NHSE_Reference.dbo.tbl_Ref_ODS_LSOA lsoan -- LSOAname											
			ON lsoa.LSOA_Code = lsoan.LSOA		
		--LEFT OUTER JOIN NHSE_Sandbox_DC.dbo.[Rural_Urban_Classification__2011__of_Lower_Layer_Super_Output_Areas_in_England_and_Walestxt] ru											
		--	ON lsoa.LSOA_Code = ru.[LSOA11CD]										
		LEFT OUTER JOIN NHSE_Sandbox_DC.[dbo].[LSOA Population SAPE21DT1a-mid-2018-on-2019-LA-lsoa-syoa-estimates-formattedtxt] pop											
			ON lsoa.LSOA_Code = pop.LSOA_Code										
		LEFT OUTER JOIN [NHSE_Sandbox_DC].[dbo].[LSOA_imd_scores_all_domains_2019] dd											
			on lsoa.LSOA_Code = dd.FeatureCode	
		LEFT OUTER JOIN NHSE_Sandbox_DC.dbo.LSOA_2011_to_CCG_Apr19 ccg
			on lsoa.LSOA_Code = ccg.LSOA2011_Code
		LEFT OUTER JOIN --select * from
					NHSE_Sandbox_DC.dbo.Universal_CCG_Mapper$ ics
			on ccg.CCG2019_Code = ics.CCG_Code

	WHERE lsoa.Effective_Snapshot_Date = '2019-12-31'
	) ,

ETHN_cte (LSOA_Code, nonWhiteProp)
AS (SELECT e.LSOA_Name as 'LSOA_Code', --note the deliberate error!
		   (1 - e.White_perc) as 'nonWhiteProp'	--select * 
	FROM NHSE_Sandbox_DC.dbo.LSOA_Ethnicity_Categories$ e) ,

CWRU_cte (FinancialYear, LSOA_Code, CWRU_NEL)
AS (SELECT  				
			--REPLACE(ccg.Org_Name,',',' ') as 'CCG_of_residence',								
			--REPLACE(pr.Provider_Site_Name,',',' ') as 'ProviderSite',	
			sp.Der_Financial_Year,						
			sp.Der_Postcode_LSOA_2011_Code AS 'LSOA_Code',							
			--sp.Der_Postcode_LSOA_Code,											
			--CC.APCS_Ident,										
			--CASE WHEN pod.National_POD_Desc LIKE '%Non-elective%' THEN 'Non-elective'										
			--	ELSE 'Elective' END AS 'POD_Group',									
			--CASE WHEN hrg.HRG_Desc LIKE '%transplant%' THEN 'Transplant'										
			--	ELSE 'Non-transplant' END AS 'Transplant_flag',									
			--cc.CC_Ident,										
			--cc.Unbundled_HRG,										
			--cc.CC_Days_LOS,										
			--cc.Advanced_Resp_Supp_Days,										
											
			/* PROVIDER EFFICIENCY ATTRIBUTION TO LSOA NEEDS TO BE REFINED. Needs to be weighted?										
			   SO DOES THE APACHE Score: join at patient level */										
													
			--AVG(cast(PE.u0 as float)) as 'ProviderEffiency_residual',										
			--AVG(cast(pe.u0se as float)) as 'ProviderEfficiency_standard_error',										
			--avg(cast(ap.APACHE_score as float)) as 'APACHE_Score',										
			--sum(CASE 										
			--		WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067								
			--		WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587							
			--		WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847								
			--		WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.000							
			--		WHEN cc.Unbundled_HRG = 'XC05Z'	THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)*0.8475) -- 2_organ ARS split							
			--		WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS*0.6425								
			--		WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203							
			--ELSE CC_Days_LOS*1.00										
			--END) AS 'CostWeightedBeddays_all',										
													
			sum(CASE WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067					
					WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587				
					WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847					
					WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.000				
					WHEN cc.Unbundled_HRG = 'XC05Z'	THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)*0.8475) -- 2_organ ARS split				
					WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS*0.6425					
					WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203				
						ELSE CC_Days_LOS*1.00 END) AS 'CWRU_NEL'
													
			--sum(CASE WHEN pod.National_POD_Code LIKE 'EL%' 										
			--		THEN (CASE 								
			--					WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067					
			--					WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587				
			--					WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847					
			--					WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.000				
			--					WHEN cc.Unbundled_HRG = 'XC05Z'	THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)*0.8475) -- 2_organ ARS split				
			--					WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS*0.6425					
			--					WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203				
			--			ELSE CC_Days_LOS*1.00 END)							
			--	ELSE 0 END) AS 'EL_CWRU'									
													
			--cc.CC_Start_Date,										
													
	FROM  NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc											
		LEFT OUTER JOIN  NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp 											
			ON cc.APCS_Ident = sp.APCS_Ident										
		LEFT OUTER JOIN NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Der der											
			ON sp.APCS_Ident = der.APCS_Ident																		
		LEFT OUTER JOIN  nhse_reference.dbo.tbl_Ref_ODS_ProviderSite pr											
			ON sp.Der_Provider_Site_Code = pr.Provider_Site_Code										
		LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_ODS_Commissioner_AllOrgs co
			ON sp.Der_Commissioner_Code = co.Org_Code										
		LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_ODS_CCG ccg -- IDENTIFIES CCG OF RESIDENCE, RATHER THAN COMMISSIONER											
			ON sp.Der_Postcode_CCG_Code = ccg.Org_Code										
		LEFT OUTER JOIN NHSE_Reference.dbo.tbl_Ref_ACM_National_POD pod											
			ON der.National_POD_Code = pod.National_POD_Code										
		LEFT OUTER JOIN NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg											
			ON der.Spell_Core_HRG = hrg.HRG_Code				
																		
		/*											
			NEED TO RE-DO THE APACHE SCORES AT TRUST/SITE LEVEL - THERE ARE ERRORS										
		*/											
		--LEFT OUTER JOIN NHSE_Sandbox_DC.dbo.ACC_Provider_Efficiency_Metric_runmlwin_CC_Episodes_2019_09_19_provider_effectscsv pe											
		--	ON sp.Der_Provider_Code = pe.Provider_code										
		--LEFT OUTER JOIN (											
		--					SELECT ic.[Provider_code], max(ic.[ APACHE_Score_Trust ]) as 'APACHE_score'						
		--					FROM NHSE_Sandbox_DC.dbo.ICNARC_scores_unit_trust ic						
		--					GROUP BY ic.[Provider_code]						
		--				) ap							
			--ON sp.Der_Provider_Code = ap.Provider_code																			
													
	WHERE												
		cc.Unbundled_HRG like 'XC%'											
		AND sp.Der_Activity_Month between 201904 and 201303											
		AND pr.Provider_Code like 'R%' --AND cc.CC_Type = 'ACC' --AND cc.CC_Patient_Type  = 'ADU'											
		AND CC_Days_LOS >= Advanced_Resp_Supp_Days											
		--AND CC_Days_LOS > 0									
		AND pod.National_POD_Desc LIKE '%Non-elective%'											
		--AND hrg.HRG_Desc NOT LIKE '%transplant%'											
													
	GROUP BY sp.Der_Postcode_LSOA_2011_Code, sp.Der_Financial_Year													
				--CASE WHEN pod.National_POD_Desc LIKE '%Non-elective%' THEN 'Non-elective'									
					--ELSE 'Elective' END								
				--CASE WHEN hrg.HRG_Desc LIKE '%transplant%' THEN 'Transplant'									
				--	ELSE 'Non-transplant' END								
													
	--ORDER BY sp.Der_Postcode_LSOA_Code												
	)

select b.FinancialYear,
		a.LSOA_Code, 
		a.LSOA_Name,
		a.CCG_Code,
		a.CCG_Name,
		a.STP_Code,
		a.STP_Name,
		a.ICS_Code,
		a.ICS_Name,
		Population,
		((a.Pop_70_plus*Population)*Income_Deprivation_Affecting_Older_People_Index)/Population as 'Pop70depr',
		((a.Pop_70_plus*Population) - ((a.Pop_70_plus*Population)*Income_Deprivation_Affecting_Older_People_Index))/Population as 'Pop70nonDepr',
		((Population - (a.Pop_70_plus*Population))*Employment_Deprivation_Domain)/Population as 'PopUnder70depr',
		((Population - (a.Pop_70_plus*Population)) - ((Population - (a.Pop_70_plus*Population))*Employment_Deprivation_Domain))/Population as 'PopUnder70nonDepr',
		c.nonWhiteProp,
		b.CWRU_NEL
from LSOA_cte a
left outer join CWRU_cte b
	on a.LSOA_Code = b.LSOA_Code
left outer join ETHN_cte c
	on a.LSOA_Code = c.LSOA_Code