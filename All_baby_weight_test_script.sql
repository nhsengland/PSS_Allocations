select sp.Der_Financial_Year,
		--top 100
		--sp.APCS_Ident, ep.apce_ident, bb.Birth_Weight_Baby_1,
			
				pr.Provider_Name, 
				pr.Provider_Site_Name, 
				--sp.Der_Postcode_LSOA_2011_Code as 'LSOA_Code',
				--sp.Der_Postcode_MSOA_2011_Code as 'MSOA_2011_Code',
				--sp.Der_Postcode_MSOA_Code as 'MSOA_Code',
--				sp.Der_Postcode_CCG_Code,
--				hrg.HRG_Desc,
--				--count(*) AS 'Baby_episodes'
--				sum(sp.Der_Age_at_CDS_Activity_Date) as 'Total_mother_years_[num]',
--				sum(case 
--					when sp.Der_Age_at_CDS_Activity_Date < 25 then 1
--					else 0 
--					end) as 'Spells_mother_under25',
--				sum(case 
--					when sp.Der_Age_at_CDS_Activity_Date between 25 and 34 then 1
--					else 0 
--					end) as 'Spells_mother_25to34',
--				sum(case 
--					when sp.Der_Age_at_CDS_Activity_Date > 34 then 1
--					else 0 
--					end) as 'Spells_mother_35plus'
			count(*) as 'Records',
			--sum(case when bb.Birth_Order_Baby_1 is not null then 1 else 0 end + --as 'Baby1',
			--	case when bb.Birth_Order_Baby_2 is not null then 1 else 0 end + --as 'Baby2',
			--	case when bb.Birth_Order_Baby_3 is not null then 1 else 0 end + --as 'Baby3',
			--	case when bb.Birth_Order_Baby_4 is not null then 1 else 0 end + --as 'Baby4',
			--	case when bb.Birth_Order_Baby_5 is not null then 1 else 0 end + --as 'Baby5',
			--	case when bb.Birth_Order_Baby_6 is not null then 1 else 0 end + --as 'Baby6',
			--	case when bb.Birth_Order_Baby_7 is not null then 1 else 0 end + --as 'Baby7',
			--	case when bb.Birth_Order_Baby_8 is not null then 1 else 0 end + --as 'Baby8',
			--	case when bb.Birth_Order_Baby_9 is not null then 1 else 0 end
			--	) 
			--	as 'babiesTotal', --as 'Baby9'
			--sum(
			--	case when Birth_Weight_Baby_1 is NULL then 0 else Birth_Weight_Baby_1 end +
			--	case when Birth_Weight_Baby_2 is NULL then 0 else Birth_Weight_Baby_2 end +
			--	case when Birth_Weight_Baby_3 is NULL then 0 else Birth_Weight_Baby_3 end +
			--	case when Birth_Weight_Baby_4 is NULL then 0 else Birth_Weight_Baby_4 end +
			--	case when Birth_Weight_Baby_5 is NULL then 0 else Birth_Weight_Baby_5 end +
			--	case when Birth_Weight_Baby_6 is NULL then 0 else Birth_Weight_Baby_6 end +
			--	case when Birth_Weight_Baby_7 is NULL then 0 else Birth_Weight_Baby_7 end +
			--	case when Birth_Weight_Baby_8 is NULL then 0 else Birth_Weight_Baby_8 end +
			--	case when Birth_Weight_Baby_9 is NULL then 0 else Birth_Weight_Baby_9 end 
			--	)
			--	as 'Baby_Weight_Total_[grams]',
			
			sum(case when bb.Birth_Weight_Baby_1 is not null then 1 else 0 end) as 'Total_neonates_baby_1',
			sum(cast(bb.Gestation_Length_Baby_1 as int)) as 'Total_wgt_forMean',
			--sum(case when bb.Birth_Weight_Baby_1 < 1500 then 1 else 0 end) as 'birthsUnder1500g',
			--sum(case when bb.Birth_Weight_Baby_1 between 1500 and 2000 then 1 else 0 end) as 'birthsBetween1500and2000g',
			--sum(case when bb.Birth_Weight_Baby_1 between 2001 and 2500 then 1 else 0 end) as 'birthsBetween2001and2500g',
			--sum(case when bb.Birth_Weight_Baby_1 between 2501 and 3000 then 1 else 0 end) as 'birthsBetween2501and3000g',
			--sum(case when bb.Birth_Weight_Baby_1 between 3001 and 3500 then 1 else 0 end) as 'birthsBetween3001and3500g',
			--sum(case when bb.Birth_Weight_Baby_1 between 3501 and 4000 then 1 else 0 end) as 'birthsBetween3501and4000g',
			--sum(case when bb.Birth_Weight_Baby_1 > 4000 then 1 else 0 end) as 'birthsOver4000g',
			sum(case when bb.Gestation_Length_Baby_1 BETWEEN 0 AND 27 then 1 else 0 end) as 'gl_0_27_extremePreterm',

			sum(case when bb.Gestation_Length_Baby_1 BETWEEN 28 AND 32 then 1 else 0 end) as 'gl_28_32_veryPreterm_WHO',
			sum(case when bb.Gestation_Length_Baby_1 BETWEEN 33 AND 37 then 1 else 0 end) as 'gl_33_37_Preterm_WHO',
			sum(case when bb.Gestation_Length_Baby_1 BETWEEN 38 AND 41 then 1 else 0 end) as 'gl_38_41_Term_WHO',

			--sum(case when bb.Gestation_Length_Baby_1 BETWEEN 28 AND 32 then 1 else 0 end) as 'gl_28_31_veryPreterm_ONS',
			--sum(case when bb.Gestation_Length_Baby_1 BETWEEN 33 AND 36 then 1 else 0 end) as 'gl_32_36_Preterm_ONS',
			--sum(case when bb.Gestation_Length_Baby_1 BETWEEN 37 AND 41 then 1 else 0 end) as 'gl_37_41_Term_ONS',

			sum(case when bb.Gestation_Length_Baby_1 > 41 then 1 else 0 end) as 'gl_42plus_postTerm'

		--select count(*) as 'recordCount_GestationLengthPresent'
		from --select top 1000 * from
		[NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_APCE_Baby] bb
			left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCE] ep
			on bb.apce_ident = ep.apce_ident
			left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCS] sp
			on ep.apcs_ident = sp.apcs_ident
			left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr
			on sp.Der_Provider_Site_Code = pr.Provider_Site_Code
			left outer join NHSE_Reference.dbo.vw_Ref_PbR_HRG_AllYr_Compound hrg
			on sp.Spell_Core_HRG_SUS = hrg.HRG_Code
			--left outer join [NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_APCE_Baby] bb
			--on sp.apcs_ident = bb.apcs_ident

	--where   --sp.Der_Financial_Year = '2018/19'
				--sp.Der_Activity_Month = 201904
				--and sp.Spell_Core_HRG_SUS in ( 

				--		'NZ30A','NZ30B','NZ30C','NZ31A','NZ31B','NZ31C','NZ32A','NZ32B','NZ32C','NZ33A','NZ33B','NZ33C','NZ34A','NZ34B','NZ34C','NZ40A',
				--		'NZ40B','NZ40C','NZ41A','NZ41B','NZ41C','NZ42A','NZ42B','NZ42C','NZ43A','NZ43B','NZ43C','NZ44A','NZ44B','NZ44C','NZ50A','NZ50B',
				--		'NZ50C','NZ51A','NZ51B','NZ51C'
				--			)
				--and pr.Provider_Code not in (
				--		'RJZ','RQM','RQ3','RR1','RD8','RFF','RQ8','RHU','RNL','RVV'
				--			) -- EXCLUDED DUE TO EXTREME DATA QUALITY ISSUES: INCOMPLETENESS SUGGESTS SERIOUS POSSIBILITY OF BIAS IN SAMPLING.
				--			-- ALL RE-INCLUDED FOR DQ TESTING PURPOSES
				-- bb.Gestation_Length_Baby_1 is not null

		group by sp.Der_Financial_Year,
				pr.Provider_Name, 
				pr.Provider_Site_Name
				--sp.Der_Postcode_CCG_Code
				--sp.Der_Postcode_LSOA_2011_Code,
				--sp.Der_Postcode_MSOA_2011_Code,
				--sp.Der_Postcode_MSOA_Code,
				--sp.Der_Postcode_CCG_Code
				--hrg.HRG_Desc
		--order by sp.apcs_ident asc

/*
	BABY TABLE TEST SCRIPT: DOES THE COMPLETION LEVEL OF THE BIRTHWEIGHT DATA IN THE BABY TABLE CORRELATE WITH THE OVERALL ACTIVITY LEVEL

	select bb.APCE_Ident, 
			bb.Birth_Order_Baby_1,
			bb.Birth_Weight_Baby_1,
			bb.Birth_Order_Baby_2,
			bb.Birth_Weight_Baby_2,
			bb.Birth_Order_Baby_3,
			bb.Birth_Weight_Baby_3
	from nhse_susplus_live.dbo.tbl_Data_SEM_APCE_Baby bb
			left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCE] ep
			on bb.apce_ident = ep.apce_ident
			left outer join nhse_susplus_live.[dbo].[tbl_Data_SEM_APCS] sp
			on ep.apcs_ident = sp.apcs_ident
			left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr
			on sp.Der_Provider_Site_Code = pr.Provider_Site_Code
	where bb.Birth_Order_Baby_3 is not null
		and sp.Der_Financial_Year = '2018/19'

*/