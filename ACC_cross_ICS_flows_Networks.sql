SELECT
--TOP 1000 
	'SUS' AS 'DataSource'	
	, cc.Der_Financial_Year AS 'Year'
	--, cc.Der_Activity_Month AS 'Activity_Month'	
	--, com.Org_Code
	--, com.Org_Name	
	--, com.Org_Type
	--, sp.Der_Postcode_LSOA_2011_Code
	--, lsoa.LSOA_Name
	--, sp.Der_Postcode_MSOA_2011_Code
	--, msoa.MSOA_Name
	--, ccg_r.LSOA2011_Name
	--, ccg_r.LAD2019_Name
	, ccg_r.CCG2019_Code
	, ccg_r.CCG2019_Name

	, icb.ICB22CD as 'Population_ICB22CD', icb.ICB22CDH as 'Population_ICB22CDH', icb.ICB22NM as 'Population_ICB22NM'
	, icb3.NHSER22CD as 'Population_R22CD', icb3.NHSER22CDH as 'Population_R22CDH', icb3.NHSER22NM as 'Population_R22NM'

	--, pr.Provider_Code as 'SUS_Provider_Code', pr.Provider_Name as 'SUS_Provider_Name'
	--, pr.Provider_Site_Code as 'SUS_Site_Code', pr.Provider_Site_Name as 'SUS_Site_Name', pr.Provider_Site_Name_Short as 'SUS_Site_Name_Short'

	--, cc.Der_Provider_Code
	--, prov_icb.Provider_ICB_Mapped
	--, icb2.ICB22CD as 'Provider_ICB22CD', icb2.ICB22CDH as 'Provider_ICB22CDH', icb2.ICB22NM as 'Provider_ICB22NM'
	--, icb2.NHSER22CD as 'Provider_R22CD', icb2.NHSER22CDH as 'Provider_R22CDH', icb2.NHSER22NM as 'Provider_R22NM'

	--, an.Site_Code as 'NETWORK_Site_Code', an.Site_Name as 'NETWORK_Site_Name'
	--, an.Trust_Code as 'NETWORK_Trust_Code', an.Trust_Name as 'NETWORK_Trust_Name'
	--, an.ICB_Code as 'NETWORK_ICB_Code', an.ICB_Name as 'NETWORK_ICB_Name'
	--, an.ACC_Network as 'NETWORK_ACC_Network'
	--, an.Region as 'NETWORK_Region'

	--, case when icb.ICB22CDH = icb2.ICB22CDH then 'In_area' else 'Out_of_area' end as 'ICB_Match'
	--, case when icb3.NHSER22CDH = icb2.NHSER22CDH then 'In_region' else 'Out_of_region' end as 'R22_Match'

	, case when co.Tariff_Type LIKE 'Elective%' then 'Elective'
			when co.Tariff_Type LIKE 'Non-elective%' then 'Non-elective'
			else 'Other' end as 'POD'
	
	--, hrg.HRG_Code, hrg.HRG_Desc
	--, hrg.HRG_SubChapter_Code, hrg.HRG_SubChapter_Desc
	--, hrg.HRG_Chapter_Code, hrg.HRG_Chapter_Desc
	--, LEFT(hrg.HRG_Chapter_Desc, CHARINDEX('with CC Score', hrg.HRG_Chapter_Desc)-2) as 'HRG_Truncated'

	--, icd.ICD10_L4_Desc as 'Primary_Diagnosis'
	--, opcs.OPCS_L4_Desc as 'Dominant_Procedure'
	--, der.NCBFinal_Spell_ServiceLine, sline.Service_Line_Desc
	--, der.NCBFinal_Spell_NPoC, sline.NPoC_CRG_Desc

	--, CASE 
	--	WHEN der.[Responsible_Purchaser_Type] = 'CCG' THEN 'Non-Specialised'
	--	WHEN der.[Responsible_Purchaser_Type] = 'Comm Hub' THEN 'Specialised'
	--	ELSE 'Other' END AS 'Responsible_Purchaser_Type'
	--, der.Spell_Treatment_Function_Code, tf.Treatment_Function_Desc
	--, der.Spell_Main_Specialty_Code, msp.Main_Specialty_Desc, msp.Main_Specialty_Group
	
	/*NEED TO ADD HERE THE SPLIT BY SPECIALTY OR SERVICE LINE:
		HRG WILL BE TOO GRANULAR, BUT NPOC TOO COARSE! CLINICIAN SPECIALTY?? HRG SUB-CHAPTER?*/
	--, count(*) as 'CCP_count'
	--, count(distinct cc.CC_Ident) as 'CCP_dist_count'
	--, count(distinct cc.APCE_Ident) as 'APCE_dist_count'

	--, cchrg.HRG_Code as 'UnbundledHRG_code'

	--, CASE WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days > 0
	--			THEN 'XC05Z_ARS'
	--		WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days = 0
	--			THEN 'XC05Z_noARS'
	--		ELSE cc.Unbundled_HRG END as 'UnbundledHRG_code'

	--, CASE WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days > 0
	--			THEN 'Adult Critical Care, 2 Organs Supported with Advanced Respiratory Support'
	--		WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days = 0
	--			THEN 'Adult Critical Care, 2 Organs Supported without Advanced Respiratory Support'
	--		ELSE cchrg.HRG_Desc END AS 'UnbundledHRG_desc'

	--, ac.Administrative_Category_Desc_Short as 'Admin_Category'

	, count(distinct cc.APCS_Ident) as 'APCS_dist_count'
	, sum(cc.CC_Days_LOS) as 'CC_BedDays'
	, sum(	CASE WHEN cc.Unbundled_HRG = 'XC01Z' THEN CC_Days_LOS*1.3067					
					WHEN cc.Unbundled_HRG = 'XC02Z'	THEN CC_Days_LOS*1.1587				
					WHEN cc.Unbundled_HRG = 'XC03Z' THEN CC_Days_LOS*1.0847					
					WHEN cc.Unbundled_HRG = 'XC04Z'	THEN CC_Days_LOS*1.000				
					WHEN cc.Unbundled_HRG = 'XC05Z'	THEN (Advanced_Resp_Supp_Days*1.00) + ((CC_Days_LOS-Advanced_Resp_Supp_Days)*0.8475) 
						-- 2_organ ARS split
					WHEN cc.Unbundled_HRG = 'XC06Z' THEN CC_Days_LOS*0.6425					
					WHEN cc.Unbundled_HRG = 'XC07Z'	THEN CC_Days_LOS*0.5203				
						ELSE CC_Days_LOS*1.00 END
			) AS 'CWRU'

--select top 100 *
from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc
	left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp
		on cc.APCS_Ident = sp.APCS_Ident
	left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr			
		on sp.Der_Provider_Site_Code = pr.Provider_Site_Code
	--left outer join --select top 1000 * from
	--	NHSE_Sandbox_DC.dbo.ACC_Networks$ an
	--	on sp.Der_Provider_Site_Code = an.Site_Code

	left outer join --select top 1000 * from 
				NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Der der /* WHAT IN THE NAME OF... THE 1920_DER AND 1920_COST TABLES HAVE GONE???? */
		on sp.APCS_Ident = der.APCS_Ident
	left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2021_Cost co
		on sp.APCS_Ident = co.APCS_Ident
	--left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg
	--	on co.HRG_Code = hrg.HRG_Code
	--left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound cchrg
	--	on cc.Unbundled_HRG = cchrg.HRG_Code
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_ZZZ_AdministrativeCategory ac
	--	on sp.Administrative_Category = ac.Administrative_Category
										
	--left outer join NHSE_Reference.dbo.tbl_Ref_NCB_NPoC_Map sline
	--	on der.NCBFinal_Spell_ServiceLine = sline.Service_Line_Code
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_ZZZ_TreatmentFunction tf
	--	on der.Spell_Treatment_Function_Code = tf.Treatment_Function_Code
	--left outer join NHSE_Reference.dbo.tbl_Ref_DataDic_ZZZ_MainSpecialty msp
	--	on der.Spell_Main_Specialty_Code = msp.Main_Specialty_Code
	--left outer join --select top 1000 * from
	--	NHSE_Reference.dbo.tbl_Ref_ClinCode_ICD10 icd			
	--	on der.Spell_Primary_Diagnosis = icd.ICD10_L4_Code		
	--left outer join -- select top 1000 * from
	--	NHSE_Reference.dbo.tbl_Ref_ClinCode_OPCS opcs			
	--	on der.Spell_Dominant_Procedure = opcs.OPCS_L4_Code	

	--left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCE ep			
	--	on cc.APCE_Ident = ep.APCE_Ident
	--left outer join NHSE_Reference.dbo.vw_Ref_ODS_Commissioner_AllOrgs com			
	--	on der.Responsible_Purchaser_Code = com.Org_Code	
	left outer join NHSE_Sandbox_DC.dbo.LSOA_2011_to_CCG_Apr19 ccg_r
		on sp.Der_Postcode_LSOA_2011_Code = ccg_r.LSOA2011_Code
	--left outer join NHSE_Reference.dbo.tbl_Ref_ODS_LSOA lsoa
	--	on sp.Der_Postcode_LSOA_2011_Code = lsoa.LSOA
	--left outer join NHSE_Reference.dbo.tbl_Ref_ODS_MSOA msoa
	--	on sp.Der_Postcode_MSOA_2011_Code = msoa.MSOA
	left outer join NHSE_Sandbox_DC.dbo.[DP_LSOA_CCG_ICB_LAD Jul22] icb
		on sp.Der_Postcode_LSOA_2011_Code = icb.LSOA11CD

	left outer join (select distinct cc.Der_Provider_Code, 	
						CASE
			WHEN cc.Der_Provider_Code = 'R0A' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'R0B' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'R0D' THEN 'QVV'
			WHEN cc.Der_Provider_Code = 'R1E' THEN 'QNC'
			WHEN cc.Der_Provider_Code = 'R1F' THEN 'QRL'
			WHEN cc.Der_Provider_Code = 'R1H' THEN 'QMF'
			WHEN cc.Der_Provider_Code = 'R1K' THEN 'QRV'
			WHEN cc.Der_Provider_Code = 'RA2' THEN 'QXU'
			WHEN cc.Der_Provider_Code = 'RA3' THEN 'QUY'
			WHEN cc.Der_Provider_Code = 'RA4' THEN 'QSL'
			WHEN cc.Der_Provider_Code = 'RA7' THEN 'QUY'
			WHEN cc.Der_Provider_Code = 'RA9' THEN 'QJK'
			WHEN cc.Der_Provider_Code = 'RAE' THEN 'QWO'
			WHEN cc.Der_Provider_Code = 'RAJ' THEN 'QH8'
			WHEN cc.Der_Provider_Code = 'RAL' THEN 'QMJ'
			WHEN cc.Der_Provider_Code = 'RAN' THEN 'QM7'
			WHEN cc.Der_Provider_Code = 'RAP' THEN 'QMJ'
			WHEN cc.Der_Provider_Code = 'RAS' THEN 'QRV'
			WHEN cc.Der_Provider_Code = 'RAX' THEN 'QWE'
			WHEN cc.Der_Provider_Code = 'RBA' THEN 'QSL'
			WHEN cc.Der_Provider_Code = 'RBD' THEN 'QVV'
			WHEN cc.Der_Provider_Code = 'RBK' THEN 'QUA'
			WHEN cc.Der_Provider_Code = 'RBL' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RBN' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RBQ' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RBT' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RBV' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RBZ' THEN 'QJK'
			WHEN cc.Der_Provider_Code = 'RC1' THEN 'QHG'
			WHEN cc.Der_Provider_Code = 'RC9' THEN 'QHG'
			WHEN cc.Der_Provider_Code = 'RCB' THEN 'QOQ'
			WHEN cc.Der_Provider_Code = 'RCD' THEN 'QOQ'
			WHEN cc.Der_Provider_Code = 'RCF' THEN 'QWO'
			WHEN cc.Der_Provider_Code = 'RCX' THEN 'QMM'
			WHEN cc.Der_Provider_Code = 'RD1' THEN 'QOX'
			WHEN cc.Der_Provider_Code = 'RD3' THEN 'QVV'
			WHEN cc.Der_Provider_Code = 'RD7' THEN 'QNQ'
			WHEN cc.Der_Provider_Code = 'RD8' THEN 'QHG'
			WHEN cc.Der_Provider_Code = 'RDD' THEN 'QH8'
			WHEN cc.Der_Provider_Code = 'RDE' THEN 'QJG'
			WHEN cc.Der_Provider_Code = 'RDU' THEN 'QNQ'
			WHEN cc.Der_Provider_Code = 'RDZ' THEN 'QVV'
			WHEN cc.Der_Provider_Code = 'RE9' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'REF' THEN 'QT6'
			WHEN cc.Der_Provider_Code = 'REM' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'REP' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RET' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RF4' THEN 'QMF'
			WHEN cc.Der_Provider_Code = 'RFF' THEN 'QF7'
			WHEN cc.Der_Provider_Code = 'RFR' THEN 'QF7'
			WHEN cc.Der_Provider_Code = 'RFS' THEN 'QJ2'
			WHEN cc.Der_Provider_Code = 'RFW' THEN 'QRV'
			WHEN cc.Der_Provider_Code = 'RGM' THEN 'QUE'
			WHEN cc.Der_Provider_Code = 'RGN' THEN 'QUE'
			WHEN cc.Der_Provider_Code = 'RGP' THEN 'QMM'
			WHEN cc.Der_Provider_Code = 'RGQ' THEN 'QJG'
			WHEN cc.Der_Provider_Code = 'RGR' THEN 'QJG'
			WHEN cc.Der_Provider_Code = 'RGT' THEN 'QUE'
			WHEN cc.Der_Provider_Code = 'RH5' THEN 'QSL'
			WHEN cc.Der_Provider_Code = 'RH8' THEN 'QJK'
			WHEN cc.Der_Provider_Code = 'RHM' THEN 'QRL'
			WHEN cc.Der_Provider_Code = 'RHQ' THEN 'QF7'
			WHEN cc.Der_Provider_Code = 'RHU' THEN 'QRL'
			WHEN cc.Der_Provider_Code = 'RHW' THEN 'QU9'
			WHEN cc.Der_Provider_Code = 'RJ1' THEN 'QKK'
			WHEN cc.Der_Provider_Code = 'RJ2' THEN 'QKK'
			WHEN cc.Der_Provider_Code = 'RJ6' THEN 'QWE'
			WHEN cc.Der_Provider_Code = 'RJ7' THEN 'QWE'
			WHEN cc.Der_Provider_Code = 'RJC' THEN 'QWU'
			WHEN cc.Der_Provider_Code = 'RJE' THEN 'QNC'
			WHEN cc.Der_Provider_Code = 'RJF' THEN 'QNC'
			WHEN cc.Der_Provider_Code = 'RJL' THEN 'QOQ'
			WHEN cc.Der_Provider_Code = 'RJN' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RJR' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RJZ' THEN 'QKK'
			WHEN cc.Der_Provider_Code = 'RK5' THEN 'QT1'
			WHEN cc.Der_Provider_Code = 'RK9' THEN 'QJK'
			WHEN cc.Der_Provider_Code = 'RKB' THEN 'QWU'
			WHEN cc.Der_Provider_Code = 'RKE' THEN 'QMJ'
			WHEN cc.Der_Provider_Code = 'RL1' THEN 'QOC'
			WHEN cc.Der_Provider_Code = 'RL4' THEN 'QUA'
			WHEN cc.Der_Provider_Code = 'RLN' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RLQ' THEN 'QGH'
			WHEN cc.Der_Provider_Code = 'RLT' THEN 'QWU'
			WHEN cc.Der_Provider_Code = 'RLU' THEN 'QHL'
			WHEN cc.Der_Provider_Code = 'RM1' THEN 'QMM'
			WHEN cc.Der_Provider_Code = 'RM2' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RM3' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RMC' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RMP' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RN3' THEN 'QOX'
			WHEN cc.Der_Provider_Code = 'RN5' THEN 'QRL'
			WHEN cc.Der_Provider_Code = 'RN7' THEN 'QKS'
			WHEN cc.Der_Provider_Code = 'RNA' THEN 'QUA'
			WHEN cc.Der_Provider_Code = 'RNL' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RNN' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RNQ' THEN 'QPM'
			WHEN cc.Der_Provider_Code = 'RNS' THEN 'QPM'
			WHEN cc.Der_Provider_Code = 'RNZ' THEN 'QOX'
			WHEN cc.Der_Provider_Code = 'RP5' THEN 'QF7'
			WHEN cc.Der_Provider_Code = 'RPA' THEN 'QKS'
			WHEN cc.Der_Provider_Code = 'RPC' THEN 'QKS'
			WHEN cc.Der_Provider_Code = 'RPY' THEN 'QWE'
			WHEN cc.Der_Provider_Code = 'RQ3' THEN 'QHL'
			WHEN cc.Der_Provider_Code = 'RQ6' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RQ8' THEN 'QH8'
			WHEN cc.Der_Provider_Code = 'RQM' THEN 'QRV'
			WHEN cc.Der_Provider_Code = 'RQQ' THEN 'QUE'
			WHEN cc.Der_Provider_Code = 'RQW' THEN 'QM7'
			WHEN cc.Der_Provider_Code = 'RQX' THEN 'QMF'
			WHEN cc.Der_Provider_Code = 'RR1' THEN 'QHL'
			WHEN cc.Der_Provider_Code = 'RR7' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RR8' THEN 'QWO'
			WHEN cc.Der_Provider_Code = 'RRF' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RRJ' THEN 'QHL'
			WHEN cc.Der_Provider_Code = 'RRK' THEN 'QHL'
			WHEN cc.Der_Provider_Code = 'RRV' THEN 'QMJ'
			WHEN cc.Der_Provider_Code = 'RT3' THEN 'QRV'
			WHEN cc.Der_Provider_Code = 'RTD' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RTE' THEN 'QR1'
			WHEN cc.Der_Provider_Code = 'RTF' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RTG' THEN 'QJ2'
			WHEN cc.Der_Provider_Code = 'RTH' THEN 'QU9'
			WHEN cc.Der_Provider_Code = 'RTK' THEN 'QXU'
			WHEN cc.Der_Provider_Code = 'RTP' THEN 'QNX'
			WHEN cc.Der_Provider_Code = 'RTR' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RTX' THEN 'QE1'
			WHEN cc.Der_Provider_Code = 'RVJ' THEN 'QUY'
			WHEN cc.Der_Provider_Code = 'RVL' THEN 'QMJ'
			WHEN cc.Der_Provider_Code = 'RVR' THEN 'QWE'
			WHEN cc.Der_Provider_Code = 'RVV' THEN 'QKS'
			WHEN cc.Der_Provider_Code = 'RVW' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RVY' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RW3' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RW6' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RWA' THEN 'QOQ'
			WHEN cc.Der_Provider_Code = 'RWD' THEN 'QJM'
			WHEN cc.Der_Provider_Code = 'RWE' THEN 'QK1'
			WHEN cc.Der_Provider_Code = 'RWF' THEN 'QKS'
			WHEN cc.Der_Provider_Code = 'RWG' THEN 'QM7'
			WHEN cc.Der_Provider_Code = 'RWH' THEN 'QM7'
			WHEN cc.Der_Provider_Code = 'RWJ' THEN 'QOP'
			WHEN cc.Der_Provider_Code = 'RWP' THEN 'QGH'
			WHEN cc.Der_Provider_Code = 'RWW' THEN 'QYG'
			WHEN cc.Der_Provider_Code = 'RWY' THEN 'QWO'
			WHEN cc.Der_Provider_Code = 'RX1' THEN 'QT1'
			WHEN cc.Der_Provider_Code = 'RXC' THEN 'QNX'
			WHEN cc.Der_Provider_Code = 'RXF' THEN 'QWO'
			WHEN cc.Der_Provider_Code = 'RXH' THEN 'QNX'
			WHEN cc.Der_Provider_Code = 'RXK' THEN 'QUA'
			WHEN cc.Der_Provider_Code = 'RXL' THEN 'QE1'
			WHEN cc.Der_Provider_Code = 'RXN' THEN 'QE1'
			WHEN cc.Der_Provider_Code = 'RXP' THEN 'QHM'
			WHEN cc.Der_Provider_Code = 'RXQ' THEN 'QU9'
			WHEN cc.Der_Provider_Code = 'RXR' THEN 'QE1'
			WHEN cc.Der_Provider_Code = 'RXW' THEN 'QOC'
			WHEN cc.Der_Provider_Code = 'RYJ' THEN 'QRV'
			WHEN cc.Der_Provider_Code = 'RYR' THEN 'QNX'
			WHEN cc.Der_Provider_Code = 'RYV' THEN 'QUE'
			 ELSE NULL
				END AS 'Provider_ICB_Mapped'
		 from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc) prov_icb
		on cc.Der_Provider_Code = prov_icb.Der_Provider_Code
		
		left outer join (select distinct ICB22CD, ICB22CDH, ICB22NM, NHSER22CD, NHSER22CDH, NHSER22NM 
						 from NHSE_Sandbox_DC.dbo.[DP_CCG_ICB_NHSE Jul22]
							) icb2
			on prov_icb.Provider_ICB_Mapped = icb2.ICB22CDH

		left outer join (select distinct ICB22CD, ICB22CDH, ICB22NM, NHSER22CD, NHSER22CDH, NHSER22NM 
						 from NHSE_Sandbox_DC.dbo.[DP_CCG_ICB_NHSE Jul22]
							) icb3
			on icb.ICB22CDH = icb3.ICB22CDH

where CC_Type = 'ACC'	
	--pr.Provider_Code like 'R%'			
	and cc.Unbundled_HRG like 'XC%'	
	--and (icb2.NHSER22CDH = 'Y56' 
	--	 or icb2.NHSER22CDH = 'Y56')
	and sp.Discharge_Date between '2019-04-01' and '2020-03-29'
	--and an.Site_Code is not NULL

group by	
	cc.Der_Financial_Year
	--, cc.Der_Activity_Month AS 'Activity_Month'	
	--, com.Org_Code
	--, com.Org_Name	
	--, com.Org_Type
	--, sp.Der_Postcode_LSOA_2011_Code
	--, lsoa.LSOA_Name
	--, sp.Der_Postcode_MSOA_2011_Code
	--, msoa.MSOA_Name
	--, ccg_r.LSOA2011_Name
	--, ccg_r.LAD2019_Name
	, ccg_r.CCG2019_Code
	, ccg_r.CCG2019_Name
	, icb.ICB22CD 
	, icb.ICB22CDH 
	, icb.ICB22NM 
	, icb3.NHSER22CD
	, icb3.NHSER22CDH 
	, icb3.NHSER22NM 

	--, pr.Provider_Code
	--, pr.Provider_Name	
	--, cc.Der_Provider_Code
	--, pr.Provider_Site_Code
	--, pr.Provider_Site_Name
	--, pr.Provider_Site_Name_Short

	--, prov_icb.Provider_ICB_Mapped
	--, icb2.ICB22CD 
	--, icb2.ICB22CDH
	--, icb2.ICB22NM
	--, icb2.NHSER22CD
	--, icb2.NHSER22CDH
	--, icb2.NHSER22NM
	
	--, an.Site_Code
	--, an.Site_Name
	--, an.Trust_Code
	--, an.Trust_Name
	--, an.ICB_Code
	--, an.ICB_Name
	--, an.ACC_Network
	--, an.Region

	--, case when icb.ICB22CDH = icb2.ICB22CDH then 'In_area' else 'Out_of_area' end
	--, case when icb3.NHSER22CDH = icb2.NHSER22CDH then 'In_area' else 'Out_of_area' end

	, case when co.Tariff_Type LIKE 'Elective%' then 'Elective'
			when co.Tariff_Type LIKE 'Non-elective%' then 'Non-elective'
			else 'Other' end
	
	--, hrg.HRG_Code, hrg.HRG_Desc
	--, hrg.HRG_SubChapter_Code, hrg.HRG_SubChapter_Desc
	--, hrg.HRG_Chapter_Code, hrg.HRG_Chapter_Desc
	--, icd.ICD10_L4_Desc
	--, opcs.OPCS_L4_Desc
	--, der.NCBFinal_Spell_ServiceLine, sline.Service_Line_Desc
	--, der.NCBFinal_Spell_NPoC, sline.NPoC_CRG_Desc

	--, CASE
	--	WHEN der.[Responsible_Purchaser_Type] = 'CCG' THEN 'Non-Specialised'
	--	WHEN der.[Responsible_Purchaser_Type] = 'Comm Hub' THEN 'Specialised'
	--	ELSE 'Other' END
	--, der.Spell_Treatment_Function_Code, tf.Treatment_Function_Desc
	--, der.Spell_Main_Specialty_Code, msp.Main_Specialty_Desc, msp.Main_Specialty_Group

	--, CASE WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days > 0
	--			THEN 'XC05Z_ARS'
	--		WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days = 0
	--			THEN 'XC05Z_noARS'
	--		ELSE cc.Unbundled_HRG END

	--, CASE WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days > 0
	--			THEN 'Adult Critical Care, 2 Organs Supported with Advanced Respiratory Support'
	--		WHEN cc.Unbundled_HRG = 'XC05Z' AND Advanced_Resp_Supp_Days = 0
	--			THEN 'Adult Critical Care, 2 Organs Supported without Advanced Respiratory Support'
	--		ELSE cchrg.HRG_Desc END

	--, ac.Administrative_Category_Desc_Short

--select * from nhse_sandbox_dc.dbo.ACC_Networks$