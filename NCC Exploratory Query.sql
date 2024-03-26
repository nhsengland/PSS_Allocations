WITH 

LSOA AS (
		select l.LSOA_Code, p.LSOA_Name, IMD_Score, -- NEED TO ADD DEPRIVATION INDICES FOR INCOMES DEPR AFFCT CHILDREN??
				Population_Aged_16_To_59_Excl_Prisoners as 'Female_16_59_pop' -- NEED TO SELECT CORRECT FIELDS: LSOA, DEPR, AND FEMALE SEX AGE BANDS?
		from NHSE_Reference.dbo.tbl_Ref_Other_Deprivation_By_LSOA l
		left outer join NHSE_Reference.dbo.tbl_Ref_ODS_LSOA s
			on l.LSOA_Code = s.LSOA
		left outer join NHSE_Sandbox_DC.dbo.[LSOA Population SAPE21DT1a-mid-2018-on-2019-LA-lsoa-syoa-estimates-formattedtxt] p
			on s.LSOA = p.LSOA_Code
		left outer join nhse_sandbox_dc.[dbo].[LSOA_population_age_sex$] q
			on l.LSOA_Code = q.LSOA_Code
		where l.Effective_Snapshot_Date = '2019-12-31'
			and q.Sex = 'F'
),

Baby as (
	select APCS_Ident, 
			avg(cast(Person_Weight as float)) as 'Mean_person_weight_over_spell',
			stdev(cast(Person_Weight as float)) as 'StDev_person_weight_over_spell'
	from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc
	where CC_Type = 'NCC'
		and cc.CC_Patient_Type = 'CHI'
		and Unbundled_HRG like 'XA%'
		and cc.Der_Financial_Year = '2018/19'
	GROUP BY APCS_Ident
),

NCC AS (
		select 
		--top 1000
		--pr.Provider_Name, pr.Provider_Site_Name,-- APCE_Ident, Episode_Number, CC_Ident, CC_Period_Number,
							--cc.Der_Provider_Code, cc.Commissioner_Code,
							--CC_Type, CC_Patient_Type, cc.Unbundled_HRG, hrg.HRG_Desc,
							--cc.Admission_Date, cc.Discharge_Date, Episode_Start_Date, Episode_End_Date,
							--CC_Days_LOS, Total_Episode_Level_CC_Days_LOS,
							 --CC_Activity_Date
						--cc.Der_Financial_Year,
						--Der_Financial_Quarter,
						--cc.Der_Activity_Month,
						--sp.Der_Postcode_LSOA_2011_Code as 'LSOA_Code',
						sp.Der_Postcode_MSOA_2011_Code as 'MSOA_2011_Code',			
						sp.Der_Postcode_MSOA_Code as 'MSOA_Code',
						sp.Der_Provider_Code as 'Provider_Code',
						--cc.Unbundled_HRG,
						--hrg.HRG_Desc,
						--case when cc.Unbundled_HRG = 'XA01Z' then 4.0
						--	when cc.Unbundled_HRG = 'XA02Z' then 2.0
						--	when cc.Unbundled_HRG = 'XA03Z' then 1.0
						--	when cc.Unbundled_HRG = 'XA04Z' then 0.8
						--	when cc.Unbundled_HRG = 'XA05Z' then 0.6
						--	else 1.0 end as 'HRG_bedday_costWeight',
						sum(cc.CC_Days_LOS) as 'bedDays',
						sum(case when cc.Unbundled_HRG = 'XA01Z' then 4.0
							when cc.Unbundled_HRG = 'XA02Z' then 2.0
							when cc.Unbundled_HRG = 'XA03Z' then 1.0
							when cc.Unbundled_HRG = 'XA04Z' then 0.8
							when cc.Unbundled_HRG = 'XA05Z' then 0.6
							else 1.0 end) as 'costWeighted_bedDays'
						--sum(cast(Person_Weight as float)) as 'Baby_kilos_total_[WeightNumerator]',
						--	sum(cc.CC_Days_LOS) as 'CC_Days_[Weight_Denominator]',
						--sum(cast(Person_Weight as float))/sum(cc.CC_Days_LOS) as 'babyWeight_mean' -- because records are at daily level
						--NUMBER OF BABIES FROM NCC???
				
		--select count(distinct cc.APCS_Ident) as 'Spells'
		
		from nhse_susplus_live.[dbo].[tbl_Data_PbR_CC] cc
			left outer join NHSE_Reference.dbo.tbl_Ref_PbR_Full_Unbundled_HRG hrg
			on cc.Unbundled_HRG = hrg.HRG_Code
			left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp
			on cc.APCS_Ident = sp.APCS_Ident
			left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr
			on sp.Der_Provider_Site_Code = pr.Provider_Site_Code

		where CC_Type = 'NCC'
		and cc.CC_Patient_Type = 'CHI'
		and Unbundled_HRG like 'XA%'
		--and HRG_Code is not null
		and cc.Der_Financial_Year = '2018/19'
		--and cc.CC_Days_LOS > 0
		--APCS_Ident = '494003084'

		group by sp.Der_Postcode_MSOA_2011_Code,			
						sp.Der_Postcode_MSOA_Code,
						sp.Der_Provider_Code
		--order by APCS_Ident desc, CC_Period_Number asc
),

Births AS  -- THIS IS DEFINITELY NOT RIGHT - how many babies per episode?
(
		select --pr.Provider_Name, 
				--pr.Provider_Site_Name, 
				sp.Der_Postcode_LSOA_2011_Code,
				--sp.Der_Postcode_CCG_Code,
				--hrg.HRG_Desc,
				count(*) AS 'Mothers_[denom]',
				sum(sp.Der_Age_at_CDS_Activity_Date) as 'Total_mother_years_[num]',
				sum(case 
					when sp.Der_Age_at_CDS_Activity_Date < 25 then 1
					else 0 
					end) as 'Spells_mother_under25',
				sum(case 
					when sp.Der_Age_at_CDS_Activity_Date between 25 and 34 then 1
					else 0 
					end) as 'Spells_mother_25to34',
				sum(case 
					when sp.Der_Age_at_CDS_Activity_Date > 34 then 1
					else 0 
					end) as 'Spells_mother_35plus'
			--sum(case when bb.Birth_Order_Baby_1 is not null then 1 else 0 end + --as 'Baby1',
			--	case when bb.Birth_Order_Baby_2 is not null then 1 else 0 end + --as 'Baby2',
			--	case when bb.Birth_Order_Baby_3 is not null then 1 else 0 end + --as 'Baby3',
			--	case when bb.Birth_Order_Baby_4 is not null then 1 else 0 end + --as 'Baby4',
			--	case when bb.Birth_Order_Baby_5 is not null then 1 else 0 end + --as 'Baby5',
			--	case when bb.Birth_Order_Baby_6 is not null then 1 else 0 end + --as 'Baby6',
			--	case when bb.Birth_Order_Baby_7 is not null then 1 else 0 end + --as 'Baby7',
			--	case when bb.Birth_Order_Baby_8 is not null then 1 else 0 end + --as 'Baby8',
			--	case when bb.Birth_Order_Baby_9 is not null then 1 else 0 end) as 'babiesTotal' --as 'Baby9'

		--select top 1000 *
		from --[NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_APCE_Baby] bb
			--left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCE] ep
			--on bb.apce_ident = ep.apce_ident
			nhse_susplus_live.[dbo].[tbl_Data_SEM_APCS] sp
			left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr
			on sp.Der_Provider_Site_Code = pr.Provider_Site_Code
			left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg
			on sp.Spell_Core_HRG_SUS = hrg.HRG_Code
			--left outer join [NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_APCE_Baby] bb
			--on sp.apcs_ident = bb.apcs_ident

		where sp.Der_Financial_Year = '2018/19'
		and sp.Spell_Core_HRG_SUS in
		(
			'NZ30A','NZ30B','NZ30C','NZ31A','NZ31B','NZ31C','NZ32A','NZ32B','NZ32C','NZ33A','NZ33B','NZ33C',
			'NZ34A','NZ34B','NZ34C','NZ40A','NZ40B','NZ40C','NZ41A','NZ41B','NZ41C','NZ42A','NZ42B','NZ42C',
			'NZ43A','NZ43B','NZ43C','NZ44A','NZ44B','NZ44C','NZ50A','NZ50B','NZ50C','NZ51A','NZ51B','NZ51C'
		)

		group by sp.Der_Postcode_LSOA_2011_Code--, sp.Der_Postcode_CCG_Code
				--hrg.HRG_Desc
)

select *
from LSOA l
left outer join NCC n
on l.LSOA_Code = n.LSOA_Code
left outer join Births b
on l.LSOA_Code = b.Der_Postcode_LSOA_2011_Code
--where NCC.Provider_Name is not null