select --top 100000 
			--cc.CC_Ident, cc.APCS_Ident,
			sp.Der_Postcode_LSOA_2011_Code,
			count(*) as 'Births_count',
			sum(cast(first_weight.Person_initial_weight as float)) as 'TotalFirstWeight',
			sum(case when cast(first_weight.Person_initial_weight as float) < 1.500 
				then 1 else 0
				end) as 'birthsUnder1500g',

			sum(case when cast(first_weight.Person_initial_weight as float) between 1.500 and 2.500
				then 1 else 0
				end) as 'birthsBetween1500and2500g',

			sum(case when cast(first_weight.Person_initial_weight as float) > 2.500 
				then 1 else 0
				end) as 'birthsOver2500g'
			
			--cc.APCE_Ident, 	cc.APCS_Ident, 	
			--Provider_Code, 	Commissioner_Code, 	CC_Type, 	
			--Hospital_Spell_No, 	Episode_Number, 	
			--Admission_Date, 	Discharge_Date, 	
			--Episode_Start_Date, 	Episode_End_Date, 	
			--CC_Days_LOS, 	Total_Episode_Level_CC_Days_LOS, 	CC_Days_Tariff, 	
			--Total_Episode_Level_CC_Days_Tariff, 	
			--CC_Period_Number, 	--Unbundled_HRG, CC_Local_Identifier, 
			--CC_Activity_Date, 	
			--cc.Person_Weight,--, first_weight.CC_Ident, 
			--avg(cast(first_weight.Person_initial_weight as float)) as 'MeanFirstWeight'
			--meanWgt.Mean_person_weight_over_spell,
			--meanWgt.StDev_person_weight_over_spell
			--, 	CC_Activity_Code1
--select * 
		from nhse_susplus_live.[dbo].[tbl_Data_PbR_CC] cc
		left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp
			on cc.APCS_Ident = sp.APCS_Ident
		left outer join (
							select cc.apcs_ident, cc.apce_ident, CC_Ident, 
								cc.Person_Weight as 'Person_initial_weight',
							ROW_NUMBER() OVER (PARTITION BY APCE_Ident
								ORDER BY cc.CC_Activity_Date asc)
								AS Day_number
							--ROW_NUMBER() OVER (PARTITION BY APCE_Ident
							--	ORDER BY cc.CC_Activity_Date desc)
							--	AS Day_number2
							from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc
							where CC_Type = 'NCC'
								and cc.CC_Patient_Type = 'CHI'
								and Unbundled_HRG like 'XA%'
								and cc.Unbundled_HRG is not null
								and cc.Der_Financial_Year = '2018/19'
								--and cc.episode_start_date = cc.CC_Activity_Date
						) first_weight
				on cc.CC_Ident = first_weight.CC_Ident
		--left outer join (
		--					select APCS_Ident, 
		--							avg(cast(Person_Weight as float)) as 'Mean_person_weight_over_spell',
		--							stdev(cast(Person_Weight as float)) as 'StDev_person_weight_over_spell'
		--					from NHSE_SUSPlus_Live.dbo.tbl_Data_PbR_CC cc
		--					where CC_Type = 'NCC'
		--						and cc.CC_Patient_Type = 'CHI'
		--						and Unbundled_HRG like 'XA%'
		--						and cc.Der_Financial_Year = '2018/19'
		--					GROUP BY APCS_Ident
		--				) meanWgt
		--		on cc.APCS_Ident = meanWgt.APCS_Ident
			--left outer join NHSE_Reference.dbo.tbl_Ref_PbR_Full_Unbundled_HRG hrg
			--on cc.Unbundled_HRG = hrg.HRG_Code
			--left outer join NHSE_SUSPlus_Live.dbo.tbl_Data_SEM_APCS sp
			--on cc.APCS_Ident = sp.APCS_Ident
			--left outer join NHSE_Reference.dbo.tbl_Ref_ODS_ProviderSite pr
			--on sp.Der_Provider_Site_Code = pr.Provider_Site_Code

		where CC_Type = 'NCC'
		--and cc.CC_Patient_Type = 'CHI'
		--and Unbundled_HRG like 'XA%'
		--and cc.Unbundled_HRG is not null
		and cc.Der_Financial_Year = '2018/19'
		--and cc.CC_Days_LOS > 0
		--and first_weight.Day_number = 1

		group by Der_Postcode_LSOA_2011_Code
		--order by cc.APCS_Ident, cc.apce_ident, cc.CC_Activity_Date asc


select *
from nhse_sandbox_dc.dbo.LSOA_imd_scores_all_domains_2019

