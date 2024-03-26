WITH

baby as (
	select
				--sp.Der_Postcode_LSOA_2011_Code as 'LSOA_Code',			
				--lsoa.LSOA_Name,
				--imd.Index_of_Multiple_Deprivation,
				--imd2.IMD_Score,
				--imd2.IMD_Rank,
				--imd2.IMD_Decile,
				--imd2.Income_Rank,
				--imd2.Income_Score,
				--imd2.Income_Decile,
				--imd2.Employment_Score,
				--imd2.Employment_Rank,
				--imd2.Employment_Decile,
				--imd.Income_Deprivation_Domain,
				--imd.Employment_Deprivation_Domain,
				--sp.Der_Postcode_MSOA_2011_Code as 'MSOA_2011_Code',			
				sp.Der_Financial_Year,
				sp.Der_Provider_Code,
				pr.Provider_Name,
				sp.Der_Provider_Site_Code,
				pr.Provider_Site_Name,
				icb.[ODS ICB Code],
				icb.[ICB Name],
				icb.[NHS Trusts],
				icb.[ODS Trust Code],
				icb.[Local Authority],
				icb.[NHS England Region],
				icb.[ODS LA Code],
				icb.[ODS Sub ICB Code],
				icb.[ONS ICB Boundary Code],
				icb.[Sub ICB Locations_(formerly CCGs)],
				sp.Der_Postcode_CCG_Code,
				ccg.Org_Name,
				ccg.Mapped_Org_Name,

				count(*) as 'Births_all',
				
				sum(case when bb.Gestation_Length_Baby_1 is not null then 1 else 0 end) as 'Births_with_gestation_length',
				sum(case when bb.Gestation_Length_Baby_1 between 0 and 27 then 1 else 0 end) as 'extremePreterm_0_27',				
				sum(case when bb.Gestation_Length_Baby_1 between 28 and 32 then 1 else 0 end) as 'veryPreterm_28_32',				
				sum(case when bb.Gestation_Length_Baby_1 between 33 and 37 then 1 else 0 end) as 'preTerm_33_37',				
				sum(case when bb.Gestation_Length_Baby_1 between 38 and 40 then 1 else 0 end) as 'fullTerm_38_40',				
				sum(case when bb.Gestation_Length_Baby_1 between 41 and 42 then 1 else 0 end) as 'lateTerm_41_42',				
				sum(case when bb.Gestation_Length_Baby_1 between 43 and 52 then 1 else 0 end) as 'postTerm_43_52',
				sum(case when bb.Gestation_Length_Baby_1 > 52 then 1 else 0 end) as 'postTerm_53plus',
				/*53 WEEKS+ EXCLUDED DUE TO OBVIOUS DQ ISSUE: BIOLOGICALLY IMPOSSIBLE!*/
				--sum(imd2.Total_Population_Excl_Prisoners) as 'PopulationExclPrisoners_forDenominator',

				--sum(case when imd2.IMD_Decile > 7 
				--	then imd2.Total_Population_Excl_Prisoners	
				--	else 0 end) as 'LowestQuintileIMD_populationNumerator',
				--sum(case when imd2.Income_Decile > 7 
				--	then imd2.Total_Population_Excl_Prisoners	
				--	else 0 end) as 'LowestQuintileIncomeDepr_populationNumerator',
				--sum(case when imd2.Employment_Decile > 7 
				--	then imd2.Total_Population_Excl_Prisoners	
				--	else 0 end) as 'LowestQuintileEmploymentDepr_populationNumerator',

				--sum(case when bb.Delivery_Method_Baby_1 in ('7') then 1 else 0 end) as 'Elective caesarean section',
				--sum(case when bb.Delivery_Method_Baby_1 in ('8') then 1 else 0 end) as 'Emergency caesarean section',

				--sum(case when bb.Sex_Baby_1 = 2 then 1 else 0 end) as 'Female_indicator',
				
				sum(case when bb.Birth_Weight_Baby_1 is not null then 1 else 0 end) as 'Birthweight_denominator',
				sum(case when bb.Birth_Weight_Baby_1 < 1500 then 1 else 0 end) as 'birthsUnder1500g',
				sum(case when bb.Birth_Weight_Baby_1 between 1500 and 2000 then 1 else 0 end) as 'birthsBetween1500and2000g',
				sum(case when bb.Birth_Weight_Baby_1 between 2001 and 2500 then 1 else 0 end) as 'birthsBetween2001and2500g',
				sum(case when bb.Birth_Weight_Baby_1 between 2501 and 3000 then 1 else 0 end) as 'birthsBetween2501and3000g',
				sum(case when bb.Birth_Weight_Baby_1 between 3001 and 3500 then 1 else 0 end) as 'birthsBetween3001and3500g',
				sum(case when bb.Birth_Weight_Baby_1 between 3501 and 4000 then 1 else 0 end) as 'birthsBetween3501and4000g',
				sum(case when bb.Birth_Weight_Baby_1 > 4000 then 1 else 0 end) as 'birthsOver4000g',

				sum(CASE WHEN pr.Provider_Code in ('RJZ','RQM','RQ3','RR1','RD8','RFF','RQ8','RHU','RNL','RVV') THEN 1 ELSE 0 END) AS 'DQ_Issues'

			--select * from NHSE_Sandbox_PublicHealth.dbo.Ref_CCG_ICB
			--select count(*) as 'recordCount_GestationLengthPresent'
			from [NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_APCE_Baby] bb		
						
				left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCE] ep				
					on bb.apce_ident = ep.apce_ident				
				left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCS] sp				
					on ep.apcs_ident = sp.apcs_ident	
				left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS_2223_Der der
					on sp.apcs_ident = der.apcs_ident			
				left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr				
					on sp.Der_Provider_Site_Code = pr.Provider_Site_Code		

				left outer join NHSE_Sandbox_DC.dbo.DT_Prov_CCG_ICB_Lookup_Sept22 icb
					on pr.Provider_Code = icb.[ODS Trust Code]
				left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg				
					on sp.Spell_Core_HRG_SUS = hrg.HRG_Code						
				left outer join NHSE_Sandbox_DC.dbo.LSOA_imd_scores_all_domains_2019 imd
					on sp.Der_Postcode_LSOA_2011_Code = imd.FeatureCode
				--left outer join NHSE_Reference.dbo.tbl_Ref_ODS_LSOA lsoa
				--	on sp.Der_Postcode_LSOA_2011_Code = lsoa.LSOA
				--left outer join --select pop.LSOA_Code, pop.LSOA_Name, CAST(REPLACE(REPLACE(pop.Population_all,'"',''),',','') as int) as 'Popn_clean' from
				--	NHSE_Sandbox_DC.dbo.[LSOA Population SAPE21DT1a-mid-2018-on-2019-LA-lsoa-syoa-estimates-formattedtxt] pop
				--	on sp.Der_Postcode_LSOA_2011_Code = pop.LSOA_Code
				left outer join NHSE_Reference.dbo.tbl_Ref_Other_Deprivation_By_LSOA imd2
					on sp.Der_Postcode_LSOA_2011_Code = imd2.LSOA_Code
				left outer join NHSE_Reference.dbo.tbl_Ref_Other_CCGToICB ccg
					on sp.Der_Postcode_CCG_Code = ccg.Org_Code

			where   --sp.Der_Financial_Year = '2019/20'
					sp.Spell_Core_HRG_SUS in ( 			
'NZ30A','NZ30B','NZ30C','NZ31A','NZ31B','NZ31C','NZ32A','NZ32B','NZ32C','NZ33A','NZ33B','NZ33C','NZ34A','NZ34B','NZ34C','NZ40A','NZ40B','NZ40C','NZ41A','NZ41B','NZ41C','NZ42A','NZ42B','NZ42C','NZ43A','NZ43B','NZ43C','NZ44A','NZ44B','NZ44C','NZ50A','NZ50B','NZ50C','NZ51A','NZ51B','NZ51C'	
								)
					--and pr.Provider_Code not in (			
					--		'RJZ','RQM','RQ3','RR1','RD8','RFF','RQ8','RHU','RNL','RVV'	
					--			) -- EXCLUDED DUE TO EXTREME DATA QUALITY ISSUES: INCOMPLETENESS SUGGESTS SERIOUS POSSIBILITY OF BIAS IN SAMPLING.
					--and bb.Gestation_Length_Baby_1 is not null			
					--and bb.Gestation_Length_Baby_1 < 53
					--and sp.Der_Postcode_CCG_Code = '15E'
					--and sp.Der_Postcode_MSOA_2011_Code like 'E%'
					--and imd2.Effective_Snapshot_Date = '2019-12-31'
							
			group by 					
				--sp.Der_Postcode_LSOA_2011_Code,			
				--lsoa.LSOA_Name,
				--imd.Index_of_Multiple_Deprivation,
				--imd2.IMD_Score,
				--imd2.IMD_Rank,
				--imd2.IMD_Decile,
				--imd2.Income_Rank,
				--imd2.Income_Score,
				--imd2.Income_Decile,
				--imd2.Employment_Score,
				--imd2.Employment_Rank,
				--imd2.Employment_Decile,
				--imd.Income_Deprivation_Domain,
				--imd.Employment_Deprivation_Domain,
				--sp.Der_Postcode_MSOA_2011_Code
					sp.Der_Financial_Year,
					sp.Der_Provider_Code,
					pr.Provider_Name,
					sp.Der_Provider_Site_Code,
					pr.Provider_Site_Name,
					icb.[ODS ICB Code],
					icb.[ICB Name],
					icb.[NHS Trusts],
					icb.[ODS Trust Code],
					icb.[Local Authority],
					icb.[NHS England Region],
					icb.[ODS LA Code],
					icb.[ODS Sub ICB Code],
					icb.[ONS ICB Boundary Code],
					icb.[Sub ICB Locations_(formerly CCGs)],
					sp.Der_Postcode_CCG_Code,
					ccg.Org_Name,
					ccg.Mapped_Org_Name
			),

ncc as (	
					select 
						--sp.Der_Postcode_MSOA_2011_Code as 'MSOA_2011_Code',	
						sp.Der_Financial_Year,
						sp.Der_Provider_Code,
						sp.Der_Provider_Site_Code,
						sp.Der_Postcode_CCG_Code,
						--cc.Unbundled_HRG,
						--hrg.HRG_Desc,
						--sum(cc.CC_Days_LOS) as 'bedDays',
						sum(case when cc.Unbundled_HRG = 'XA01Z' then 4.0
							when cc.Unbundled_HRG = 'XA02Z' then 2.0
							when cc.Unbundled_HRG = 'XA03Z' then 1.0
							when cc.Unbundled_HRG = 'XA04Z' then 0.8
							when cc.Unbundled_HRG = 'XA05Z' then 0.6
							else 1.0 end) as 'CWAU',
						--sum(cast(Person_Weight as float)) as 'Baby_kilos_total_[WeightNumerator]',
						count (distinct sp.APCS_Ident) as 'NCC_admissions'
						--sum(cast(Person_Weight as float))/sum(cc.CC_Days_LOS) as 'babyWeight_mean' -- because records are at daily level
						--NUMBER OF BABIES FROM NCC???
				
					--select count(distinct cc.APCS_Ident) as 'Spells'
		
					from nhse_susplus_live.[dbo].[tbl_Data_PbR_CC] cc
						left outer join NHSE_Reference.dbo.tbl_Ref_PbR_Full_Unbundled_HRG hrg
						on cc.Unbundled_HRG = hrg.HRG_Code
					left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCS] sp				
						on cc.APCS_Ident = sp.APCS_Ident

					where CC_Type = 'NCC'
					--and cc.CC_Patient_Type = 'CHI'
					--and cc.Unbundled_HRG like 'XA%'
					--and HRG_Code is not null
					--and cc.Der_Financial_Year = '2019/20'
					--and cc.CC_Days_LOS > 0
					--APCS_Ident = '494003084'

					group by --sp.Der_Postcode_MSOA_2011_Code	
						sp.Der_Financial_Year,
						sp.Der_Provider_Code,
						sp.Der_Provider_Site_Code,
						sp.Der_Postcode_CCG_Code
									)

select 	a.Der_Financial_Year,
		a.Der_Postcode_CCG_Code,
		a.Der_Provider_Code,
		a.Provider_Name,
		a.Der_Provider_Site_Code,
		a.Provider_Site_Name,
		a.[ODS ICB Code],
		a.[ICB Name],
		a.[NHS Trusts],
		a.[ODS Trust Code],
		a.[Local Authority],
		a.[NHS England Region],
		a.[ODS LA Code],
		a.[ODS Sub ICB Code],
		a.[ONS ICB Boundary Code],
		a.[Sub ICB Locations_(formerly CCGs)],

		a.Births_all,
		(a.extremePreterm_0_27 + a.veryPreterm_28_32 + a.preTerm_33_37 + a.postTerm_43_52) as 'Gestation_numerator_0_37wks_43wksPlus',
		(a.extremePreterm_0_27 + a.veryPreterm_28_32 + a.preTerm_33_37 + a.fullTerm_38_40 + a.lateTerm_41_42 + a.postTerm_43_52) 
				as 'Gestation_denominator_valid_0_52wks',
		
		a.birthsUnder1500g as 'Birthweight_numerator_under1500g',
		a.Birthweight_denominator,
		--a.birthsUnder1500g,
		--a.birthsBetween1500and2000g,
		--a.birthsBetween2001and2500g,
		--a.birthsBetween2501and3000g,
		--a.birthsBetween3001and3500g,
		--a.birthsBetween3501and4000g,
		--a.birthsOver4000g,

		a.DQ_Issues as 'Records_with_a_DQ_issue', 

		case when b.NCC_admissions is NULL then 0 else b.NCC_admissions end as 'NCC_Admissions', 
		case when b.CWAU is NULL then 0 else b.CWAU end as 'CWAU'

from baby a
left outer join ncc b
	on a.Der_Financial_Year = b.Der_Financial_Year
	and a.Der_Provider_Code = b.Der_Provider_Code
	and a.Der_Provider_Site_Code = b.Der_Provider_Site_Code
	and a.Der_Postcode_CCG_Code = b.Der_Postcode_CCG_Code
left outer join NHSE_Sandbox_DC.dbo.[Universal_CCG_Mapper_v2$] c
	on a.Der_Postcode_CCG_Code = c.CCG_any_year