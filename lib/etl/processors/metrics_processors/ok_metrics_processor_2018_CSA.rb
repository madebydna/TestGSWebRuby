require 'set'
require_relative '../../metrics_processor'

class OKMetricsProcessor2018CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3535'
	end


	map_breakdown_id = {
		'All Students' => 1
	}

	map_subject_id = {
		#ACT mispelling
		'Engllish' => 17,
		#remediation and ACT
		'English' => 17,
		'Math' => 5,
		'Reading' => 2,
		#ACT only
		'Science' => 19,
		'Composite Score' => 1,
		#remediation only
		'Unduplicated' => 89,
		#ps enrollment
		'NA' => 0
	}

#ACT
#district
	source('act_district_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			breakdown: 'All Students',
			grade: 'All',
			data_type: 'ACT average score',
			data_type_id: 448,
			year: 2018
		})
		.transform('Rename columns',MultiFieldRenamer, {
			district: :district_name,
			number_of_testers: :cohort_count
		})
		.transform('transpose data type and subject columns',Transposer,
			:subject,:value,:engllish,:reading,:math,:science,:composite_score)
		.transform('Assign entity_type',WithBlock) do |row|
			if row[:district_name] == 'state'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'district'
			end
			row
		end
		.transform('Make subjects into text fields for easier mapping',WithBlock) do |row|
			row[:subject] = row[:subject].to_s.split('_').map(&:capitalize).join(' ')
			row
		end
	end
#school
	source('act_school_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'school',
			breakdown: 'All Students',
			grade: 'All',
			data_type: 'ACT average score',
			data_type_id: 448,
			year: 2018
		})
		.transform('Rename columns',MultiFieldRenamer, {
			district: :district_name,
			high_school: :school_name,
			number_of_testers: :cohort_count,
			state_id_load: :state_id
		})
		.transform('transpose data type and subject columns',Transposer,
			:subject,:value,:engllish,:reading,:math,:science,:composite_score)
		.transform('Make subjects into text fields for easier mapping',WithBlock) do |row|
			row[:subject] = row[:subject].to_s.split('_').map(&:capitalize).join(' ')
			row
		end
	end
#PS ENROLLMENT
#district
	source('ps_enroll_district_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			breakdown: 'All Students',
			grade: 'NA',
			data_type: 'college enrollment',
			data_type_id: 481,
			year: 2018,
			subject: 'NA'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			county: :district_name,
			high_school: :school_name,
			number_of_2017_public_high_school_graduates: :cohort_count,
			percent_direct_to_collegegoing_in_the_academic_year: :value,
			state_id_load: :state_id
		})
		.transform('Assign entity_type', WithBlock) do |row|
			if row[:district_name] == 'TOTAL ALL DISTRICTS'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'district'
			end
			row
		end
	end
#school
	source('ps_enroll_school_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'school',
			breakdown: 'All Students',
			grade: 'NA',
			data_type: 'college enrollment',
			data_type_id: 481,
			year: 2018,
			subject: 'NA'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			state_id_load: :state_id,
			number_of_2017_public_high_school_graduates: :cohort_count,
			percent_direct_to_collegegoing_in_the_academic_year: :value
		})
	end
#PS REMEDIATION
#district
	source('ps_remed_district_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			breakdown: 'All Students',
			grade: 'NA',
			data_type: 'college remediation',
			data_type_id: 413,
			year: 2017
		})
		.transform('Rename columns',MultiFieldRenamer, {
			county: :district_name,
			state_id_load: :state_id,
			students: :cohort_count
		})
		.transform('Assign entity_type', WithBlock) do |row|
			if row[:cohort_count] == '17598'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'district'
			end
			row
		end
		.transform('transpose data type and subject columns',Transposer,
			:subject,:value,:science_pct,:english_pct,:math_pct,:reading_pct,:unduplicated_pct)
		.transform('Make subjects into text fields for easier mapping',WithBlock) do |row|
			m = row[:subject].match /^([a-z]+)_pct$/
			row[:subject] = m[1].to_s.capitalize
			row
		end
	end
#school
	source('ps_remed_school_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'school',
			breakdown: 'All Students',
			grade: 'NA',
			data_type: 'college remediation',
			data_type_id: 413,
			year: 2017
		})
		.transform('Rename columns',MultiFieldRenamer, {
			county: :district_name,
			high_school: :school_name,
			state_id_load: :state_id,
			students: :cohort_count
		})
		.transform('transpose data type and subject columns',Transposer,
			:subject,:value,:science_pct,:english_pct,:math_pct,:reading_pct,:unduplicated_pct)
		.transform('Make subjects into text fields for easier mapping',WithBlock) do |row|
			m = row[:subject].match /^([a-z]+)_pct$/
			row[:subject] = m[1].to_s.capitalize
			row
		end
	end


	shared do |s|
		s.transform('Fill other columns',Fill,{
			notes: 'DXT-3535: OK CSA'
		})
		.transform('Delete blank values',DeleteRows,:value,nil,'*','NA')
		.transform('Trim values to 6 places after the decimal and multiply by 100 where needed',WithBlock) do |row|
			if [481,413].include? row[:data_type_id]
				row[:value] = row[:value].to_f * 100
			else
				row[:value] = row[:value]
			end
			row[:value] = sprintf('%.6f', row[:value]).to_f.to_s
			row
		end
		.transform('Assign date_valid based on year',WithBlock) do |row|
			if row[:year] == 2018
				row[:date_valid] = '2018-01-01 00:00:00'
			elsif row[:year] == 2017
				row[:date_valid] = '2017-01-01 00:00:00'
			end
			row
		end
		.transform('Delete blank values',DeleteRows,:value,nil,'*')
		.transform('Delete private schools and districts with no state_ids',DeleteRows,:state_id,'NA')
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	end


	def config_hash
	{
		source_id: 64,
		state: 'ok'
	}
	end
end

OKMetricsProcessor2018CSA.new(ARGV[0],max:nil).run