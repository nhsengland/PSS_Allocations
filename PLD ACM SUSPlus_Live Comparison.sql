WITH

pld_new as(
	SELECT  'PLD_new' as 'Source'
		, pld.DER_Activity_Year
		, icb.ICB_Name
		, reg1.Region_Name
		, pod.Level_1_Desc
		, pod.POD_Group_1
		, pod.Level_2_Desc
		, sc.NHSE_ServiceCategory_Desc
		, ss.ServiceCode_Desc
		, sum(CLN_Activity_Count) as 'Activity'
		
	FROM NHSE_Reporting_Regional.dbo.vw_DS_Snap_PLD pld	
	left join [NHSE_Reference].[dbo].[tbl_Ref_NCB_NPoC_Map_2223] NPOC on pld.DER_NHSE_ServiceLine = NPOC.Service_Line	
	  left outer join NHSE_Reference.dbo.tbl_Ref_ACM_ServiceCategory sc	on pld.DER_NHSE_ServiceCategory = sc.NHSE_ServiceCategory
	  left outer join NHSE_Reference.dbo.tbl_Ref_ACM_National_POD pod on pld.DER_National_POD_Code = pod.National_POD_Code
	  LEFT OUTER JOIN NHSE_Sandbox_DC.dbo.tbl_Reference_SpecialisedServiceLines ss on pld.DER_NHSE_ServiceLine = ss.ServiceCode
	  left outer join NHSE_Reference.dbo.tbl_Ref_Other_CCGToICB icb	on pld.DER_CCG_Code = icb.Org_Code
      left outer join NHSE_Reference.dbo.tbl_Ref_ODS_CCGToRegion reg on pld.DER_CCG_Code = reg.CCG_Code
	  left outer join NHSE_Reference.dbo.tbl_Ref_ODS_Region reg1 on reg.Region_Code = reg1.Region_Code

	WHERE
	pld.DER_Postcode_LSOA_Code LIKE 'E%'	
		AND pld.DER_CCG_Code IS NOT NULL	
		AND NPOC.NPoC_Cat IS NOT NULL	
		AND NPOC.NPoC_Cat <> 'Z00'

	GROUP BY DER_Activity_Year
	  , icb.ICB_Name
	  , reg1.Region_Name
	  , pod.Level_1_Desc
	  , pod.POD_Group_1
	  , pod.Level_2_Desc
      , sc.NHSE_ServiceCategory_Desc
      , ss.ServiceCode_Desc
), 

pld as (
	SELECT  'PLD' as 'Source'
		, pld.DER_Activity_Year
		, icb.ICB_Name
		, reg1.Region_Name
		, pod.Level_1_Desc
		, pod.POD_Group_1
		, pod.Level_2_Desc
		, sc.NHSE_ServiceCategory_Desc
		, ss.ServiceCode_Desc
		, sum(CLN_Activity_Count) as 'Activity'
		--, sum(CLN_Total_Cost) as 'Cost'
		
	FROM [NHSE_SLAM].[DWS_Reg].[tbl_Data_PLD] pld	
	left join [NHSE_Reference].[dbo].[tbl_Ref_NCB_NPoC_Map_2223] NPOC on pld.DER_NHSE_ServiceLine = NPOC.Service_Line	
	  left outer join NHSE_Reference.dbo.tbl_Ref_ACM_ServiceCategory sc	on pld.DER_NHSE_ServiceCategory = sc.NHSE_ServiceCategory
	  left outer join NHSE_Reference.dbo.tbl_Ref_ACM_National_POD pod on pld.DER_National_POD_Code = pod.National_POD_Code
	  LEFT OUTER JOIN NHSE_Sandbox_DC.dbo.tbl_Reference_SpecialisedServiceLines ss on pld.DER_NHSE_ServiceLine = ss.ServiceCode
	  left outer join NHSE_Reference.dbo.tbl_Ref_Other_CCGToICB icb	on pld.DER_CCG_Code = icb.Org_Code
      left outer join NHSE_Reference.dbo.tbl_Ref_ODS_CCGToRegion reg on pld.DER_CCG_Code = reg.CCG_Code
	  left outer join NHSE_Reference.dbo.tbl_Ref_ODS_Region reg1 on reg.Region_Code = reg1.Region_Code

	WHERE
	pld.DER_Postcode_LSOA_Code LIKE 'E%'	
		AND pld.DER_CCG_Code IS NOT NULL	
		AND NPOC.NPoC_Cat IS NOT NULL	
		AND NPOC.NPoC_Cat <> 'Z00'

	GROUP BY DER_Activity_Year
	  , icb.ICB_Name
	  , reg1.Region_Name
	  , pod.Level_1_Desc
	  , pod.POD_Group_1
	  , pod.Level_2_Desc
      , sc.NHSE_ServiceCategory_Desc
      , ss.ServiceCode_Desc
),

acm as (
	SELECT 'ACM' as 'Source'
	  , DER_Activity_Year
	  , icb.ICB_Name
	  , reg1.Region_Name
	  , pod.Level_1_Desc
	  , pod.POD_Group_1
	  , pod.Level_2_Desc
      , sc.NHSE_ServiceCategory_Desc
      , ss.ServiceCode_Desc
      , sum([CLN_Activity_Actual]) as 'Activity'
	  --, sum([CLN_Price_Actual]) as 'Price_Actual'
      --,[CLN_Activity_Plan]
 
      --,[CLN_Commissioner_Code]
 
      --,[CLN_MFF_Actual]
      --,[CLN_MFF_Plan]

      --,[CLN_Price_Plan]
      --,[CLN_Provider_Code]
      --,[CLN_Treatment_Function_Code]
      --,[CLN_Ward_Code]

      --,[DER_Activity_Month]
      --,[DER_CCG_Code]
      --,[DER_Commissioner_Code]
      --,[DER_GP_Practice_Code]
      --,[DER_HRG_Code]

      --,[DER_PbR_Qualified]
      --,[DER_Provider_Code]

  FROM --select top 1000 * from
  [NHSE_SLAM].[DW].[tbl_data_ACM] acm
  left outer join NHSE_Reference.dbo.tbl_Ref_ACM_ServiceCategory sc	on acm.DER_NHSE_ServiceCategory = sc.NHSE_ServiceCategory
  left outer join NHSE_Reference.dbo.tbl_Ref_ACM_National_POD pod on acm.DER_National_POD_Code = pod.National_POD_Code
  LEFT OUTER JOIN --select * from
	NHSE_Sandbox_DC.dbo.tbl_Reference_SpecialisedServiceLines ss on acm.DER_NHSE_ServiceLine = ss.ServiceCode
  left outer join NHSE_Reference.dbo.tbl_Ref_Other_CCGToICB icb on acm.DER_CCG_Code = icb.Org_Code
  left outer join NHSE_Reference.dbo.tbl_Ref_ODS_CCGToRegion reg on acm.DER_CCG_Code = reg.CCG_Code
  left outer join NHSE_Reference.dbo.tbl_Ref_ODS_Region reg1 on reg.Region_Code = reg1.Region_Code

  where DER_Record_Type = 'Actual'
 
  group by DER_Activity_Year
	  , icb.ICB_Name
	  , reg1.Region_Name
	  , pod.Level_1_Desc
	  , pod.POD_Group_1
	  , pod.Level_2_Desc
      , sc.NHSE_ServiceCategory_Desc
      , ss.ServiceCode_Desc
)

select * from acm
union all
select * from pld
union all
select * from pld_new

--select
	--acm.DER_Activity_Year
	--, acm.ICB_Name, acm.Region_Name
	--, acm.POD_Group_1, acm.Level_1_Desc, acm.Level_2_Desc
	--, acm.NHSE_ServiceCategory_Desc
	--, acm.ServiceCode, acm.ServiceCode_Desc
	--, acm.[ACM Activity], pld.[PLD Activity], pld_new.PLD_new_Activity
--from acm
--full join pld 
--	on pld.DER_Activity_Year = acm.DER_Activity_Year
--		and pld.ICB_Name = acm.ICB_Name
--		and pld.Level_1_Desc = acm.Level_1_Desc
--		and pld.Level_2_Desc = acm.Level_2_Desc
--		and left(pld.NHSE_ServiceCategory_Desc, 30) = left(acm.NHSE_ServiceCategory_Desc, 30)
--		and pld.POD_Group_1 = acm.POD_Group_1
--		and pld.Region_Name = acm.Region_Name
--		and pld.ServiceCode_Desc = acm.ServiceCode_Desc
--full join pld_new
--	on pld_new.DER_Activity_Year = acm.DER_Activity_Year
--		and pld_new.ICB_Name = acm.ICB_Name
--		and pld_new.Level_1_Desc = acm.Level_1_Desc
--		and pld_new.Level_2_Desc = acm.Level_2_Desc
--		and left(pld_new.NHSE_ServiceCategory_Desc, 30) = left(acm.NHSE_ServiceCategory_Desc, 30)
--		and pld_new.POD_Group_1 = acm.POD_Group_1
--		and pld_new.Region_Name = acm.Region_Name
--		and pld_new.ServiceCode_Desc = acm.ServiceCode_Desc
