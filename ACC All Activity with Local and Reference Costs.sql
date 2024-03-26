
--IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results 
--CREATE TABLE #Results (HRG_Desc varchar(255), TruncPnt int)
--	INSERT INTO #Results (HRG_Desc, TruncPnt)
--	VALUES ('Adult Critical Care, 0 Organs Supported', 0),
--		   ('Adult Critical Care, 1 Organ Supported', 0),
--		   ('Adult Critical Care, 2 Organs Supported', 5),
--		   ('Adult Critical Care, 3 Organs Supported', 18),
--		   ('Adult Critical Care, 4 Organs Supported', 41),
--		   ('Adult Critical Care, 5 Organs Supported', 50),
--		   ('Adult Critical Care, 6 or more Organs Supported', 60)
--SELECT HRG_Desc, TruncPnt from #Results

SELECT 
--TOP 1000 
	'SUS' AS 'DataSource'	
	, CC_Type
	, cc.Der_Financial_Year AS 'Year'	
	, cc.Der_Activity_Month AS 'Month'
	--, sp.Der_Postcode_LSOA_2011_Code as 'LSOA_Code'
	, icb.ICB22CD
	, icb.ICB22CDH
	, icb.ICB22NM
	, icb.LOC22NM
	--, ccg_r.LSOA2011_Name, ccg_r.CCG2019_Name
	--, stp.STP as 'Population_STP_num'
	--, stp.STP21 as 'Population_STP_code'
	--, stp.STP21_42_STP_name_from_ODS_API_April_2021 as 'Population_STP_name'
	----, stp.STP21ons
	--, stp.ICS as 'Population_ICS_code'
	--, stp.ICS_name as 'Population_ICS_name'
	--, ltrim(str(stp.ICS)) + ' - ' + stp.ICS_name as 'Population_ICS'
		--, cc.Der_Activity_Month AS 'Activity_Month'			
	--, sp.Admission_Date
	--, sp.Discharge_Date
	--, dm.Discharge_Method_Desc
	--, ep.APCE_Ident
	--, ep.Der_Episode_Number

	--, ROW_NUMBER() OVER (PARTITION BY ep.APCE_Ident ORDER BY cc.CC_Ident asc)			
	--  + ROW_NUMBER() OVER (PARTITION BY ep.APCE_Ident ORDER BY cc.CC_Ident desc) AS 'TotalCCPs'			
	--, ROW_NUMBER() OVER (PARTITION BY ep.APCE_Ident ORDER BY cc.CC_Ident asc) AS 'CCP_Number'			
	--, ep.Episode_Start_Date			
	--, ep.Episode_End_Date	
	--, cc.CC_Ident
	--, pr.Provider_Code
	--, pr.Provider_Name	
	--, cc.Der_Provider_Code 
	--, sp.Der_Provider_Site_Code as 'Provider_Site_Code'
	--, ps.Provider_Site_Name_Short as 'Provider_Site_Name'
	--, prov_stp.Provider_STP_Mapped
	--, stp2.STP as 'Provider_STP_num'
	--, stp2.STP21 as 'Provider_STP_code'
	--, stp2.STP21_42_STP_name_from_ODS_API_April_2021 as 'Provider_STP_name'
	--, stp2.ICS as 'Provider_ICS_code'
	--, stp2.ICS_name as 'Provider_ICS_name'
	--, ltrim(str(stp2.ICS)) + ' - ' + stp2.ICS_name as 'Provider_ICS_mapped'
	--, stp2.R19 as 'Prov_reg_code'
	--, stp2.Region19_7 as 'Prov_region'
	, pod.Level_2_Desc as 'POD_Group'
	, pod.POD_Group_1 as 'POD_Desc'
	--	, cc.Unbundled_HRG
	--, der.Responsible_Purchaser_Type	
	--, CASE WHEN der.Responsible_Purchaser_Type LIKE 'CCG%' THEN 'Non-specialised'
	--	WHEN der.Responsible_Purchaser_Type LIKE 'Comm%' THEN 'Specialised'
	--	ELSE 'Other'
	--	END as 'Specialised_flag'
	--, der.Responsible_Purchaser_Assignment_Method
	--, der.Responsible_Purchaser_Code
	--, com.Org_Name
--, CASE
--		WHEN cc.CC_Unit_Bed_Config = 02 THEN 'Level 2 beds only'
--		/* Level 2 = where patients require more detailed observation or intervention including support for a single failing organ system or post-operative care and those ''stepping down'' from higher levels of care*/
--		WHEN cc.CC_Unit_Bed_Config = 03 THEN 'Level 3 beds only'
--		/*. Level 3 care is defined as patients needing advanced respiratory support alone or support of at least two organ systems. Note basic respiratory and basic cardiovascular support occurring on one day count as one organ. This level includes beds for all complex patients requiring support for multi-organ failure.'*/
--		WHEN cc.CC_Unit_Bed_Config = 05 THEN 'Flexible critical care unit'
--		/*Flexible = where there is a mix of level 2 and level 3 beds*/
--		WHEN cc.CC_Unit_Bed_Config = 90 THEN 'Temporary CC bed'
--		/*Temp = Temporary use of non critical care bed*/
--		END AS 'CC_BedConfig_Desc'

--	, CASE	
--		WHEN cc.CC_Unit_Function = 1 THEN 'Non-specific, general adult critical care patients predominate'
--		WHEN cc.CC_Unit_Function = 2 THEN 'Surgical adult patients (unspecified specialty)'
--		WHEN cc.CC_Unit_Function = 3 THEN 'Medical adult patients (unspecified specialty)'
--		WHEN cc.CC_Unit_Function = 5 THEN 'Neurosciences adult patients predominate'
--		WHEN cc.CC_Unit_Function = 6 THEN 'Cardiac surgical adult patients predominate'
--		WHEN cc.CC_Unit_Function = 7 THEN 'Thoracic surgical adult patients predominate'
--		WHEN cc.CC_Unit_Function = 8 THEN 'Burns and plastic surgery adult patients predominate'
--		WHEN cc.CC_Unit_Function = 9 THEN 'Spinal adult patients predominate'
--		WHEN cc.CC_Unit_Function = 10 THEN 'Renal adult patients predominate'
--		WHEN cc.CC_Unit_Function = 11 THEN 'Liver adult patients predominate'
--		WHEN cc.CC_Unit_Function = 12 THEN 'Obstetric and gynaecology critical care patients predominate'
--		WHEN cc.CC_Unit_Function = 90 THEN 'non standard location using a ward area'
--		WHEN cc.CC_Unit_Function = 4 THEN 'Paediatric Intensive Care Unit'
--		WHEN cc.CC_Unit_Function = 16 THEN 'Ward for children and young people'
--		WHEN cc.CC_Unit_Function = 17 THEN 'High Dependency Unit for children and young people'
--		WHEN cc.CC_Unit_Function = 18 THEN 'Renal Unit for children and young people'
--		WHEN cc.CC_Unit_Function = 19 THEN 'Burns Unit for children and young people'
--		WHEN cc.CC_Unit_Function = 92 THEN 'Non standard location using the operating department for children'
--		WHEN cc.CC_Unit_Function = 13 THEN 'Neonatal Intensive Care Unit'
--		WHEN cc.CC_Unit_Function = 14 THEN 'Facility for Babies on a Neonatal Transitional Care Ward'
--		WHEN cc.CC_Unit_Function = 15 THEN 'Facility for Babies on a Maternity Ward'
--		WHEN cc.CC_Unit_Function = 91 THEN 'non standard location using the operating department'
--	END AS 'CC_Unit_Function'

--	, CASE 
--		WHEN cc.CC_Admission_Source = 01 THEN 'Same NHS hospital site'
--		WHEN cc.CC_Admission_Source = 02 THEN 'Other NHS hospital site (same or different NHS Trust)'
--		WHEN cc.CC_Admission_Source = 03 THEN 'Independent Hospital Provider in the UK'
--		WHEN cc.CC_Admission_Source = 04 THEN 'Non-hospital source within the UK (e.g. home)'
--		WHEN cc.CC_Admission_Source = 05 THEN 'Non UK source'
--		END AS 'CC_Admission_Source'

--	, CASE WHEN cc.CC_Admission_Type = 01 THEN	'Unplanned local admission.'
--	-- All emergency or urgent patients referred to the unit only as a result of an unexpected acute illness occurring within the local area (hospitals within the Trust together with neighbouring community units and services).
--			WHEN cc.CC_Admission_Type = 02 THEN 'Unplanned transfer in.' 
----All emergency or urgent patients  referred to the unit as a result of an unexpected acute illness occurring outside the local area (including private and overseas Health Care Providers).
--			WHEN cc.CC_Admission_Type = 03 THEN 'Planned transfer in (tertiary referral).'
---- A pre-arranged admission to the unit after treatment or initial stabilisation at another Health Care Provider (including private and overseas Health Care Providers) but requiring specialist or higher-level care that cannot be provided at the source hospital or unit.
--			WHEN cc.CC_Admission_Type = 04 THEN 'Planned local surgical admission.'
----A pre-arranged surgical admission from the local area to the to the unit, acceptance by the unit must have occurred prior to the start of the surgical procedure and the procedure will usually have been of an elective or scheduled nature. For example, following a major procedure, for a high risk medical condition associated with any level of surgery, admitted prior to elective surgery for optimisation, admitted for monitoring of pain control eg epidurals, or obstetric surgical cases admitted on a planned basis.
--			WHEN cc.CC_Admission_Type = 05 THEN 'Planned local medical admission from the local area.'
---- Booked medical admission, for example, planned investigation or high risk medical treatment.
--			WHEN cc.CC_Admission_Type = 06 THEN 'Repatriation.'
---- The patient is normally resident in your local area and is being admitted or readmitted to your unit from another hospital (including overseas Health Care Providers). This situation will normally arise when a patient is returning from tertiary or specialist care.
--			ELSE NULL END AS 'CC_Admission_Type'


	--, CASE 
	--	WHEN cc.CC_Source_Location = 01 THEN 'Theatre and Recovery (following surgical and/or anaesthetic procedure)'
	--	WHEN cc.CC_Source_Location = 02 THEN 'Recovery only (when used to provide temporary critical care facility)'
	--	WHEN cc.CC_Source_Location = 03 THEN 'Other Ward (not critical care)'
	--	WHEN cc.CC_Source_Location = 04	THEN 'Imaging department'
	--	WHEN cc.CC_Source_Location = 05 THEN 'Accident and emergency'
	--	WHEN cc.CC_Source_Location = 06 THEN 'Other intermediate/specialist including endoscopy and catheter'
	--	WHEN cc.CC_Source_Location = 07 THEN 'Obstetrics area'
	--	WHEN cc.CC_Source_Location = 08 THEN 'Clinic'
	--	WHEN cc.CC_Source_Location = 09 THEN 'Home or other residence (including nursing home, H.M. Prison or other residential care)'
	--	WHEN cc.CC_Source_Location = 10 THEN 'Adult level three critical care bed (ICU bed)'
	--	WHEN cc.CC_Source_Location = 11 THEN 'Adult level two critical care bed (HDU bed)'
	--	WHEN cc.CC_Source_Location = 12 THEN 'Paediatric critical care area (neonatal and paediatric care)'
	--	END AS 'CC_SrcLoc_Desc'
	--, hrg1.HRG_Desc
	--, src.Admission_Source_Desc
	--, am.Admission_Method_Desc
	--, dm.Discharge_Method_Desc
	--, dd.Discharge_Destination_Desc
	--, adsc.Admission_Source_Desc
	--, ddc.Discharge_Destination_Desc
	--, cc.CC_Discharge_Location
	--, cc.CC_Discharge_Status
	--, ep.Episode_Number
	--, rn.CCPsInSpell
	--, cc.CC_Start_Date
	--, cc.CC_Discharge_Date	
	--, hrg1.HRG_Desc AS 'Spell_HRG'	
	--, hrg1.HRG_SubChapter_Desc 'SpellHRG_Subchapter'
	--, hrg1.HRG_Chapter_Desc as 'SpellHRG_Chapter'

	--, hrg.HRG_Desc AS 'Unbundled_HRG'
	--, trun.HRG_Desc
	--, SUBSTRING(hrg.hrg_desc,PATINDEX('%[0-9]%',hrg.HRG_Desc),1) as 'Organs'
	--, trun.TruncPnt

	--, count(distinct sp.APCS_Ident) AS 'Spells'
	--, count(distinct cc.CC_Ident) AS 'CCPs'
	--, count(cc.CC_Ident) AS 'CCPs'
	--, sum(case when cc.CC_Days_LOS <= trun.TruncPnt then 1 else 0 end) as '<=TrncPt'
	--, sum(case when cc.CC_Days_LOS > trun.TruncPnt then 1 else 0 end) as '>TrncPt'
	--, sum(case when cc.CC_Days_LOS > trun.TruncPnt then 1 else 0 end)*1.00
	--     / count(cc.CC_Ident) as 'CCPs>TruncPt%'
	
	--, sum(cc.CC_Days_LOS) as 'CC_LOS'
	--, sum(CASE WHEN cc.CC_Days_LOS <= trun.TruncPnt THEN CC_Days_LOS
	--	ELSE trun.TruncPnt END) AS 'Truncated_LOS'

	--, sum(cc.CC_Days_LOS) -
	--  sum(CASE WHEN cc.CC_Days_LOS <= trun.TruncPnt THEN CC_Days_LOS
	--	ELSE trun.TruncPnt END) AS 'Residual_Days'

	--, ((sum(cc.CC_Days_LOS)*1.00 - 
	--    sum(CASE WHEN cc.CC_Days_LOS <= trun.TruncPnt 
	--			THEN CC_Days_LOS ELSE trun.TruncPnt END)*1.00)/
	--    sum(cc.CC_Days_LOS)) as 'Residual%'

	--, (cc.CC_Days_LOS)*SUBSTRING(hrg.hrg_desc,PATINDEX('%[0-9]%',hrg.HRG_Desc),1) as 'OrganDays'

	--, count(distinct der.APCS_Ident) as 'Spells'
	--, count(distinct cc.cc_ident) as 'CCPs'
	, count(distinct sp.APCS_Ident) as 'Spells_unique_patients'
	, sum(cc.CC_Days_LOS) as 'CC_BedDays'
	, sum(CASE WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067					
					WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587				
					WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847					
					WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.000				
					WHEN cc.Unbundled_HRG = 'XC05Z'	THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)*0.8475) -- 2_organ ARS split
					WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS*0.6425					
					WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203				
						ELSE CC_Days_LOS*1.00 END) AS 'CWRU'

	--, sum(cc.CC_Level2_days) as 'CC_Level2_Days'
	--, sum(cc.CC_Level3_Days) as 'CC_Level3_Days'

	--, count(distinct cc.apcs_ident) as 'Spells'
	--, count(*) as 'CCPs'

			/* NEED A CASE STATEMENT HERE FOR HIGHEST CARDIAC/RESP
			   AND TO EXCLUDE GASTRO AND THEN TAKE MAX() OF ALL AS PROXY*/
			--, sum(cc.Advanced_Cardiovasc_Supp_Days +		
			--  cc.Advanced_Resp_Supp_Days +
			--  cc.Basic_Cardiovasc_Supp_Days +		
			--  cc.Basic_Resp_Supp_Days +
			--  cc.Gastro_Supp_Days +	
			--  cc.Liver_Supp_days +		
			--  cc.Neurological_Supp_Days +
			--  cc.Renal_Supp_Days) as 'NonZeroOrganDays'
	  		
			
	--, SUM((cc.CC_Days_LOS) * 
	--		CASE WHEN lp.[ACC_Local_Provider_Mean_1617_price_non-MFF] IS NULL
	--			 THEN lm.[National_Median_16-17-price_non-MFF]
	--			 ELSE lp.[ACC_Local_Provider_Mean_1617_price_non-MFF] END) AS 'LocalPricePayment'
				
	--, SUM((cc.CC_Days_LOS) * 
	--		CASE WHEN rc.MFFdMean IS NULL 
	--			 THEN rca.[National Average Unit Cost]			
	--			 WHEN rca.[National Average Unit Cost] IS NULL 
	--			 THEN rcb.[Average of National Average Unit Cost]	
	--			 ELSE rc.MFFdMean END) AS 'ReferencePricePayment'	

	--, cc.Organ_Supp_Max			
	--, cc.CC_Days_LOS*(lp.[ACC_Local_Provider_Mean_1617_price_non-MFF]) AS 'Local'			
	--, cc.CC_Days_LOS*rc.MFFdUnitCost  AS 'Reference'			
				
	--, CONVERT(varchar, SUM(CAST(Der_PbR_ACC_Days*lp.MEAN AS money)), 1) AS 'Local_Price'			
	--, CONVERT(varchar, SUM(CAST(Der_PbR_ACC_Days*rc.Cost AS money)), 1) AS 'Ref_Cost'			
				
	/*NEXT STEP IS TO COMPARE THIS OUTPUT TO SIMILAR USING OTHER WAYS OF COUNTING CC DAYS			
	  THIS INCLUDES THE RELEVANT FIELD FROM THE APCS TABLE, THE RELEVANT FIELD FROM APCE			
	  AND THE RELEVANT FIELD FROM PBR_CC TABLE. TRY TO MATCH PREVIOUS RESULTS. done			
	  ALSO CHECK COMPLETENESS OF LOCAL PRICES AND FILL IN WITH MEANS WHERE BLANK			
	  ALSO CHECK ON */			
				
from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc				
	left outer join NHSE_Reference.dbo.vw_Ref_ODS_ProviderSite_Provider pr			
		on cc.Der_Provider_Code = pr.Provider_Code		
	left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp			
		on cc.APCS_Ident = sp.APCS_Ident		
	left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite ps
		on sp.Der_Provider_Site_Code = ps.Provider_Site_Code
	left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Der der			
		on sp.APCS_Ident = der.APCS_Ident		
	left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Cost co			
		on sp.APCS_Ident = co.APCS_Ident	
	left outer join --select * from
	NHSE_Reference.dbo.tbl_Ref_ACM_National_POD pod
		on sp.Der_National_POD_Code = pod.National_POD_Code
			
	left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCE ep			
		on cc.APCE_Ident = ep.APCE_Ident
	--left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCE_Ward wa
	--	on ep.APCE_Ident = wa.APCE_Ident

	--/*JOIN FOR LOCAL PRICES - NB MAY NEED TO BE RELOADED IN SSIS*/			
	--		left outer join NHSE_Sandbox_DC.[dbo].[ACC_Local_Bedday_Prices_201617$] lp			
	--			on lp.UnbundledHRG = cc.Unbundled_HRG		
	--			and lp.ProviderCode = cc.Provider_Code		
	--		left outer join NHSE_Sandbox_DC.dbo.acc_local_prices_1617_median_lq$ lm			
	--			on cc.Unbundled_HRG = lm.HRG		
				
	--/*JOIN FOR REFERENCE COSTS - SEE JANINE JAMES IF ANY ISSUES*/			
	--		left outer join NHSE_Sandbox_DC.jj.tbl_ReferenceCosts_1617 rc
	--			on cc.Provider_Code = rc.OrgCode
	--			and cc.Unbundled_HRG = rc.CurrencyCode
	--			and cc.CC_Unit_Function = SUBSTRING(rc.[ServiceCode], (PATINDEX('%[0-9]%', rc.[ServiceCode])),2)
	--		left outer join NHSE_Sandbox_DC.[dbo].[ACC_ReferenceCosts_NoProvCode$] rca
	--			on cc.Unbundled_HRG = rca.[Currency Code]
	--			and cc.CC_Unit_Function = SUBSTRING(rca.[Service Code], (PATINDEX('%[0-9]%', rca.[Service Code])),2)
	--		left outer join NHSE_Sandbox_DC.[dbo].[ACC_RefCosts_HRG_Only$] rcb
	--			on cc.Unbundled_HRG = rcb.[Currency Code]

	/*JOIN FOR NUMBER OF CCPs IN SPELL. CAN BE CHANGED TO CCPs PER EPISODE*/
			--left outer join (
			--			select cc.CC_Ident
			--				, ROW_NUMBER() OVER (PARTITION BY sp.APCS_Ident ORDER BY cc.CC_Ident asc)
			--				  + ROW_NUMBER() OVER (PARTITION BY sp.APCS_Ident ORDER BY cc.CC_Ident desc) - 1 AS 'CCPsInSpell'
			--			from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc				
			--				left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp			
			--					on cc.APCS_Ident = sp.APCS_Ident	
			--		) rn on rn.CC_Ident = cc.CC_Ident
				
	--left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg
	--	on cc.Unbundled_HRG = hrg.HRG_Code
	----left outer join #Results trun
	----	on hrg.HRG_Desc = trun.HRG_Desc
	--left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg1
	--	on co.HRG_Code = hrg1.HRG_Code
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_APC_AdmissionMethod am
	--	on sp.Admission_Method = am.Admission_Method_Der
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_APC_AdmissionSource src
	--	on sp.Source_of_Admission = src.Admission_Source
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_APC_DischargeDestination dd
	--	on sp.Discharge_Destination = dd.Discharge_Destination
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_APC_DischargeMethod dm
	--	on sp.Discharge_Method = dm.Discharge_Method
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_APC_DischargeDestination ddc
	--	on cc.CC_Discharge_Destination = ddc.Discharge_Destination
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_APC_AdmissionSource adsc
	--	on cc.CC_Admission_Source = adsc.Admission_Source

		/*
			This admission source join is wrong! Need to find an alternative or manually hard-code.
		*/

	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_APC_PatientClassification pc
	--	on sp.Patient_Classification = pc.Patient_Classification
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_ZZZ_AdministrativeCategory ac
	--	on sp.Administrative_Category = ac.Administrative_Category
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_ZZZ_TreatmentFunction tf
	--	on sp.Der_Dischg_Treatment_Function_Code = tf.Treatment_Function_Code	
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_ZZZ_RTTPeriodStatus rtt
	--	on sp.RTT_Period_Status = rtt.RTT_Period_Status
	left outer join NHSE_Reference.dbo.vw_Ref_ODS_Commissioner_AllOrgs com			
		on der.Responsible_Purchaser_Code = com.Org_Code	
	left outer join NHSE_Reference.dbo.tbl_Ref_ODS_LSOA lsoa
		on sp.Der_Postcode_LSOA_2011_Code = lsoa.LSOA
	left outer join NHSE_Sandbox_DC.dbo.[DP_LSOA_CCG_ICB_LAD Jul22] icb
		on sp.Der_Postcode_LSOA_2011_Code = icb.LSOA11CD

	--left outer join NHSE_Sandbox_DC.dbo.LSOA_2011_to_CCG_Apr19 ccg_r
	--	on sp.Der_Postcode_LSOA_2011_Code = ccg_r.LSOA2011_Code
	--left outer join NHSE_Sandbox_DC.dbo.Universal_CCG_Mapper_v2$ stp
	--	on ccg_r.CCG2019_Code = stp.CCG_code
	--left outer join (select distinct cc.Der_Provider_Code, 	
	--	CASE
	--	WHEN cc.Der_Provider_Code = 'R0A' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'R1H' THEN 'QMF'		WHEN cc.Der_Provider_Code = 'RHQ' THEN 'QF7'		WHEN cc.Der_Provider_Code = 'RR8' THEN 'QWO'		WHEN cc.Der_Provider_Code = 'RTD' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RWE' THEN 'QK1'		WHEN cc.Der_Provider_Code = 'RHM' THEN 'QRL'		WHEN cc.Der_Provider_Code = 'RJZ' THEN 'QKK'		WHEN cc.Der_Provider_Code = 'RJE' THEN 'QNC'		WHEN cc.Der_Provider_Code = 'RX1' THEN 'QT1'		WHEN cc.Der_Provider_Code = 'RYJ' THEN 'QRV'		WHEN cc.Der_Provider_Code = 'RJ1' THEN 'QKK'		WHEN cc.Der_Provider_Code = 'RTR' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RWA' THEN 'QOQ'		WHEN cc.Der_Provider_Code = 'RAL' THEN 'QMJ'		WHEN cc.Der_Provider_Code = 'RTH' THEN 'QU9'		WHEN cc.Der_Provider_Code = 'RJ7' THEN 'QWE'		WHEN cc.Der_Provider_Code = 'RXH' THEN 'QNX'		WHEN cc.Der_Provider_Code = 'R1K' THEN 'QRV'		WHEN cc.Der_Provider_Code = 'RVJ' THEN 'QUY'		WHEN cc.Der_Provider_Code = 'RXN' THEN 'QE1'		WHEN cc.Der_Provider_Code = 'RW6' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'RRK' THEN 'QHL'		WHEN cc.Der_Provider_Code = 'RR1' THEN 'QHL'		WHEN cc.Der_Provider_Code = 'REM' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RA7' THEN 'QUY'		WHEN cc.Der_Provider_Code = 'RXL' THEN 'QE1'		WHEN cc.Der_Provider_Code = 'RKB' THEN 'QWU'		WHEN cc.Der_Provider_Code = 'RM3' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'RTG' THEN 'QJ2'		WHEN cc.Der_Provider_Code = 'RGT' THEN 'QUE'		WHEN cc.Der_Provider_Code = 'RRV' THEN 'QMJ'		WHEN cc.Der_Provider_Code = 'RJ2' THEN 'QKK'		WHEN cc.Der_Provider_Code = 'RF4' THEN 'QMF'		WHEN cc.Der_Provider_Code = 'RPA' THEN 'QKS'		WHEN cc.Der_Provider_Code = 'RAJ' THEN 'QH8'		WHEN cc.Der_Provider_Code = 'RDD' THEN 'QH8'		WHEN cc.Der_Provider_Code = 'RWD' THEN 'QJM'		WHEN cc.Der_Provider_Code = 'RJL' THEN 'QOQ'		WHEN cc.Der_Provider_Code = 'RDU' THEN 'QNQ'		WHEN cc.Der_Provider_Code = 'RK9' THEN 'QJK'		WHEN cc.Der_Provider_Code = 'RXR' THEN 'QE1'		WHEN cc.Der_Provider_Code = 'RBQ' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RWP' THEN 'QGH'		WHEN cc.Der_Provider_Code = 'RM1' THEN 'QMM'		WHEN cc.Der_Provider_Code = 'RTE' THEN 'QR1'		WHEN cc.Der_Provider_Code = 'RHU' THEN 'QRL'		WHEN cc.Der_Provider_Code = 'RTF' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RCB' THEN 'QOQ'		WHEN cc.Der_Provider_Code = 'RNA' THEN 'QUA'		WHEN cc.Der_Provider_Code = 'RT3' THEN 'QKK'		WHEN cc.Der_Provider_Code = 'RL4' THEN 'QUA'		WHEN cc.Der_Provider_Code = 'RMC' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'RAE' THEN 'QWO'		WHEN cc.Der_Provider_Code = 'RYR' THEN 'QNX'		WHEN cc.Der_Provider_Code = 'RWW' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RDE' THEN 'QJG'		WHEN cc.Der_Provider_Code = 'RN5' THEN 'QRL'		WHEN cc.Der_Provider_Code = 'RQ6' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RWH' THEN 'QM7'		WHEN cc.Der_Provider_Code = 'RXP' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RP5' THEN 'QF7'		WHEN cc.Der_Provider_Code = 'RXC' THEN 'QNX'		WHEN cc.Der_Provider_Code = 'RWG' THEN 'QM7'		WHEN cc.Der_Provider_Code = 'RBL' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RC9' THEN 'QHG'		WHEN cc.Der_Provider_Code = 'RBN' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RFS' THEN 'QJ2'		WHEN cc.Der_Provider_Code = 'RKE' THEN 'QMJ'		WHEN cc.Der_Provider_Code = 'RXW' THEN 'QOC'		WHEN cc.Der_Provider_Code = 'RWF' THEN 'QKS'		WHEN cc.Der_Provider_Code = 'RNS' THEN 'QPM'		WHEN cc.Der_Provider_Code = 'R0B' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RVW' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RAS' THEN 'QRV'		WHEN cc.Der_Provider_Code = 'RBA' THEN 'QSL'		WHEN cc.Der_Provider_Code = 'RQM' THEN 'QRV'		WHEN cc.Der_Provider_Code = 'RQ8' THEN 'QH8'		WHEN cc.Der_Provider_Code = 'RH8' THEN 'QJK'		WHEN cc.Der_Provider_Code = 'RR7' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RTK' THEN 'QXU'		WHEN cc.Der_Provider_Code = 'RTX' THEN 'QE1'		WHEN cc.Der_Provider_Code = 'RHW' THEN 'QU9'		WHEN cc.Der_Provider_Code = 'RA2' THEN 'QXU'		WHEN cc.Der_Provider_Code = 'RXQ' THEN 'QU9'		WHEN cc.Der_Provider_Code = 'RVR' THEN 'QWE'		WHEN cc.Der_Provider_Code = 'RGP' THEN 'QMM'		WHEN cc.Der_Provider_Code = 'RBK' THEN 'QUA'		WHEN cc.Der_Provider_Code = 'REF' THEN 'QT6'		WHEN cc.Der_Provider_Code = 'RGN' THEN 'QUE'		WHEN cc.Der_Provider_Code = 'RFR' THEN 'QF7'		WHEN cc.Der_Provider_Code = 'RWY' THEN 'QWO'		WHEN cc.Der_Provider_Code = 'RJ6' THEN 'QWE'		WHEN cc.Der_Provider_Code = 'RAX' THEN 'QWE'		WHEN cc.Der_Provider_Code = 'RN3' THEN 'QOX'		WHEN cc.Der_Provider_Code = 'RXF' THEN 'QWO'		WHEN cc.Der_Provider_Code = 'RJR' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RD3' THEN 'QVV'		WHEN cc.Der_Provider_Code = 'RFF' THEN 'QF7'		WHEN cc.Der_Provider_Code = 'RK5' THEN 'QT1'		WHEN cc.Der_Provider_Code = 'RWJ' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'RNQ' THEN 'QPM'		WHEN cc.Der_Provider_Code = 'RN7' THEN 'QKS'		WHEN cc.Der_Provider_Code = 'RAP' THEN 'QMJ'		WHEN cc.Der_Provider_Code = 'RBT' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RQW' THEN 'QM7'		WHEN cc.Der_Provider_Code = 'RQX' THEN 'QMF'		WHEN cc.Der_Provider_Code = 'RD1' THEN 'QOX'		WHEN cc.Der_Provider_Code = 'RA9' THEN 'QJK'		WHEN cc.Der_Provider_Code = 'RGM' THEN 'QUE'		WHEN cc.Der_Provider_Code = 'RC1' THEN 'QHG'		WHEN cc.Der_Provider_Code = 'RMP' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'RBD' THEN 'QVV'		WHEN cc.Der_Provider_Code = 'RGR' THEN 'QJG'		WHEN cc.Der_Provider_Code = 'RA4' THEN 'QSL'		WHEN cc.Der_Provider_Code = 'RTP' THEN 'QNX'		WHEN cc.Der_Provider_Code = 'RRF' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'RCX' THEN 'QMM'		WHEN cc.Der_Provider_Code = 'RVY' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RNN' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RJC' THEN 'QWU'		WHEN cc.Der_Provider_Code = 'RCF' THEN 'QWO'		WHEN cc.Der_Provider_Code = 'RLT' THEN 'QWU'		WHEN cc.Der_Provider_Code = 'RCD' THEN 'QOQ'		WHEN cc.Der_Provider_Code = 'RNL' THEN 'QHM'		WHEN cc.Der_Provider_Code = 'RBZ' THEN 'QJK'		WHEN cc.Der_Provider_Code = 'R1F' THEN 'QRL'		WHEN cc.Der_Provider_Code = 'RD8' THEN 'QHG'		WHEN cc.Der_Provider_Code = 'RNZ' THEN 'QOX'		WHEN cc.Der_Provider_Code = 'RJN' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RPY' THEN 'QWE'		WHEN cc.Der_Provider_Code = 'RLQ' THEN 'QGH'		WHEN cc.Der_Provider_Code = 'RA3' THEN 'QUY'		WHEN cc.Der_Provider_Code = 'RBV' THEN 'QOP'		WHEN cc.Der_Provider_Code = 'RXK' THEN 'QUA'		WHEN cc.Der_Provider_Code = 'RL1' THEN 'QOC'		WHEN cc.Der_Provider_Code = 'RRJ' THEN 'QHL'		WHEN cc.Der_Provider_Code = 'RET' THEN 'QYG'		WHEN cc.Der_Provider_Code = 'RDZ' THEN 'QVV'		WHEN cc.Der_Provider_Code = 'RQ3' THEN 'QHL'		WHEN cc.Der_Provider_Code = 'RAN' THEN 'QM7' ELSE NULL
	--	END AS 'Provider_STP_Mapped'
	--	 from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc) prov_stp
	--	on cc.Der_Provider_Code = prov_stp.Der_Provider_Code
	--	left outer join (select distinct STP, STP21, STP21_42_STP_name_from_ODS_API_April_2021, STP21ons,
	--									ICS, ICS_name, R19, Region19_7 --select *
	--						from NHSE_Sandbox_DC.dbo.Universal_CCG_Mapper_v2$
	--						) stp2
	--		on prov_stp.Provider_STP_Mapped = stp2.STP21
	--left outer join NHSE_Reference.dbo.tbl_Ref_ClinCode_ICD10 icd			
	--	on der.Spell_Primary_Diagnosis = icd.ICD10_L4_Code		
	--left outer join NHSE_Reference.dbo.tbl_Ref_ClinCode_OPCS opcs			
	--	on der.Spell_Dominant_Procedure = opcs.OPCS_L4_Code		
				
where CC_Type = 'ACC'	
	and pr.Provider_Code like 'R%'			
	and cc.Unbundled_HRG like 'XC%'	
	--and hrg.HRG_Desc like '%6%'
	and cc.Der_Activity_Month BETWEEN '201903' AND '202004'	
	and icb.ICB22CD is not null
--and (ep.ward_code_ep_start_date like '%amu%'
--	or ep.ward_code_ep_start_date like '%acute%'
--	or ep.ward_code_ep_start_date like '%mau%'
--	or ep.ward_code_ep_start_date like '%cdu%'
--	or ep.ward_code_ep_start_date like '%cau%'
--	or ep.ward_code_ep_start_date like '%clinical%'
--	or ep.ward_code_ep_start_date like '%medic%')
--and sp.admission

	
	--and (hrg1.HRG_SubChapter_Desc like '%orthop%'
	--	or hrg1.HRG_SubChapter_Desc like '%spinal%')
	--and pr.Provider_Name like '%orthop%'		
	--and sp.Admission_Date = '2016-04-01'
	--and cc.APCS_Ident = '154398404'		
	--and der.Responsible_Purchaser_Type like '%SS%'
	--and cc.APCS_Ident IN ( /*Subscript to identifty long-stay patients in StCABG*/			
	--			SELECT  distinct
	--			sp.APCS_Ident
				
	--			FROM [NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_APCS] sp
	--			left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_1718_Cost co
	--			on sp.apcs_ident = co.apcs_ident
	--			left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_1718_Der der
	--			on sp.APCS_Ident = der.APCS_Ident
				
	--			where sp.Der_Age_at_CDS_Activity_Date between 19 and 999
	--			and co.HRG_Code LIKE 'ED28%'
	--			and der.Spell_PbR_CC_Days > 25
	--		)	
				
--ORDER BY sp.APCS_Ident desc, ep.APCE_Ident desc, cc.CC_Ident desc				
				
--group by 				
--	hrg.HRG_Desc
	--, trun.HRG_Desc
	--, SUBSTRING(hrg.hrg_desc,PATINDEX('%[0-9]%',hrg.HRG_Desc),1)
	--, trun.TruncPnt
--	 --cc.Der_Activity_Month		
--	  pr.Provider_Name	
--	 , der.Responsible_Purchaser_Type	
--	 , der.Responsible_Purchaser_Assignment_Method
--	 , der.Responsible_Purchaser_Code
--	 , com.Org_Name
--	--, am.Admission_Method_Desc
--	--, dm.Discharge_Method_Desc	

--order by hrg.HRG_Desc ASC

/* LOCAL DAILY DATA ANALYSIS WARDWATCHER*/

--UNION

--select 'Sample' AS 'DataSource'
--	, HRGDesc
--	, trun.TruncPnt
--	, count(cc.PrimaryKey) as 'CCPs'
--	, sum(case when cc.LOS <= trun.TruncPnt then 1 else 0 end) as '<=TrncPt'
--	, sum(case when cc.LOS > trun.TruncPnt then 1 else 0 end) as '>TrncPt'
--	--, sum(case when cc.LOS > trun.TruncPnt then 1 else 0 end)*1.00
--	--  / count(cc.PrimaryKey) as 'CCPs>TruncPt%'

--	, sum(cc.LOS) as 'CC_LOS'
--	, sum(CASE WHEN cc.LOS <= trun.TruncPnt THEN cc.LOS
--		ELSE trun.TruncPnt END) AS 'Truncated_LOS'

--	, sum(cc.LOS) -
--	  sum(CASE WHEN cc.LOS <= trun.TruncPnt THEN cc.LOS
--		ELSE trun.TruncPnt END) AS 'Residual_Days'

--	--, ((sum(cc.LOS)*1.00 - 
--	--    sum(CASE WHEN cc.LOS <= trun.TruncPnt 
--	--			THEN cc.LOS ELSE trun.TruncPnt END)*1.00)/
--	--    sum(cc.LOS)) as 'Residual%'

----select cc.PrimaryKey
----	, cc.ProviderCode
----	, '''' + convert(varchar(255), cc.DailyOrganProfile) + '''' AS 'DailyOrganProfile'
----	, cc.LOS
----	, cc.AvgOrgansCCP
----	, cc.LinearEst
----	, cc.OrganTrajectory
----	, cc.StartingAvg
----	, cc.FinishingAvg
----	, cc.OrgansOnLastDay
--from NHSE_Sandbox_DC.dbo.ACCDailyData$ cc
--	left outer join #Results trun
--		on cc.HRGDesc = trun.HRG_Desc

group by CC_Type, cc.Der_Financial_Year, cc.Der_Activity_Month
	--, sp.Der_Postcode_LSOA_2011_Code as 'LSOA_Code'
	, icb.ICB22CD
	, icb.ICB22CDH
	, icb.ICB22NM
	, icb.LOC22NM
	--, ccg_r.LSOA2011_Name, ccg_r.CCG2019_Name
	--, stp.STP
	--, stp.STP21
	--, stp.STP21_42_STP_name_from_ODS_API_April_2021
	----, stp.STP21ons
	--, stp.ICS
	--, stp.ICS_name 
	--, ltrim(str(stp.ICS)) + ' - ' + stp.ICS_name
	--, cc.Der_Activity_Month AS 'Activity_Month'			
	--, sp.Admission_Date
	--, sp.Discharge_Date
	--, dm.Discharge_Method_Desc
	--, ep.APCE_Ident
	--, ep.Der_Episode_Number

	--, ROW_NUMBER() OVER (PARTITION BY ep.APCE_Ident ORDER BY cc.CC_Ident asc)			
	--  + ROW_NUMBER() OVER (PARTITION BY ep.APCE_Ident ORDER BY cc.CC_Ident desc) AS 'TotalCCPs'			
	--, ROW_NUMBER() OVER (PARTITION BY ep.APCE_Ident ORDER BY cc.CC_Ident asc) AS 'CCP_Number'			
	--, ep.Episode_Start_Date			
	--, ep.Episode_End_Date	
	--, cc.CC_Ident
	--, pr.Provider_Code
	--, pr.Provider_Name	
	--, cc.Der_Provider_Code
	--, sp.Der_Provider_Site_Code
	--, ps.Provider_Site_Name_Short
	--, prov_stp.Provider_STP_Mapped
	--, stp2.STP 
	--, stp2.STP21 
	--, stp2.STP21_42_STP_name_from_ODS_API_April_2021
	--, stp2.ICS 
	--, stp2.ICS_name 
	--, ltrim(str(stp2.ICS)) + ' - ' + stp2.ICS_name 
	--, stp2.R19 
	--, stp2.Region19_7
	
	--, der.Responsible_Purchaser_Type	
	--, CASE WHEN der.Responsible_Purchaser_Type LIKE 'CCG%' THEN 'Non-specialised'
	--		WHEN der.Responsible_Purchaser_Type LIKE 'Comm%' THEN 'Specialised'
	--		ELSE 'Other'
	--		END
	--, der.Responsible_Purchaser_Assignment_Method

	, pod.Level_2_Desc 
	, pod.POD_Group_1 
	--, cc.Der_Activity_Month
	--, der.Responsible_Purchaser_Type	
	--, cc.CC_Unit_Bed_Config
	--, cc.CC_Unit_Function
	--, cc.CC_Admission_Source
	--, cc.CC_Admission_Type
	--, cc.CC_Source_Location
	--cc.HRGDesc
--		, trun.TruncPnt

----order by cc.Unbundled_HRG desc