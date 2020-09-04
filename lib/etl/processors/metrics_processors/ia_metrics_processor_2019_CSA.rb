require 'set'
require_relative '../../metrics_processor'

class IAMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3592'
	end


	map_breakdown_id = {
		'All Students' => 1,
		'FRL' => 23,
		'Students with Disabilities' => 27,
		'Native American' => 18,
		'Asian' => 16,
		'Black/African American' => 17, 
		'ELL' => 32,
		'Hispanic' => 19,
		'Multi-Racial' => 22, 
		'Hawaiian/Pacific Islander' => 20,
		'Non-FRL' => 24,
		'Non-ELL' => 33,
		'Students without Disabilities' => 30,
		'White' => 21
	}

	map_subject_id = {
		'Eng' => 17,
		'Math' => 5,
		'Reading' => 2,
		'Sci' => 19,
		'Comp' => 1,
		'All Four' => 1,
		'Any Subject' => 89,
		'NA' => 0
	}


	source('act_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'school',
			breakdown: 'All Students',
			grade: 'All'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			state_id: :small_state_id,
			full_state_id: :state_id,
			n: :cohort_count,
			name: :school_name,
			grad_year: :year
		})
		.transform('transpose data type and subject columns',Transposer,
			:subject_data_type,:value,:avg_eng,:avg_math,:avg_reading,:avg_sci,:avg_comp,:crb__eng,:crb__math,:crb__reading,:crb__sci,:crb__all_four)
		.transform('Create data type id and subject for transposed values', WithBlock) do |row|
			if [:avg_eng,:avg_math,:avg_reading,:avg_sci,:avg_comp].include? row[:subject_data_type]
				row[:data_type] = 'ACT average score'
				row[:data_type_id] = 448
				row[:subject] = row[:subject_data_type].to_s.split('_')[1].capitalize
			elsif [:crb__eng,:crb__math,:crb__reading,:crb__sci,:crb__all_four].include? row[:subject_data_type]
				row[:data_type] = 'ACT percent college ready'
				row[:data_type_id] = 454
				m = row[:subject_data_type].match /^crb__(.*)$/
				row[:subject] = m[1].to_s.split('_').map(&:capitalize).join(' ')
			end
			row
		end
		.transform('delete bad years',DeleteRows,:year,'2015','2016','2017','2018')
		.transform('delete bad values',DeleteRows,:value,'Small N')
	end
	source('ps_final.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			grade: 'NA'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			data_year: :year,
			aggregation_level: :entity_type,
			fixed_district_code: :district_id,
			fixed_school_code: :school_id,
			full_state_id: :state_id,
			subgroup: :breakdown,
			measure: :data_type,
			denominator: :cohort_count,
			percentage: :value
		})
		.transform('Assign data type id and subjects', WithBlock) do |row|
			if row[:data_type] == '4-Year Graduation Rate'
				row[:data_type_id] = 443
				row[:subject] = 'NA'
			elsif row[:data_type] == 'Enrollment Rate within One Year'
				row[:data_type_id] = 474
				row[:subject] = 'NA'
			elsif row[:data_type] == 'Remediation Rate within One Year'
				row[:data_type_id] = 413
				row[:subject] = 'Any Subject'
			else
				row[:data_type_id] = 'Error'
				row[:subject] = 'Error'
			end
			row
		end
		.transform('Turn value into percents from decimals', WithBlock) do |row|
			row[:value] = row[:value].to_f * 100
			row[:value] = sprintf('%.6f', row[:value]).to_f.to_s
			row
		end
		.transform('Skip bad schools', DeleteRows,:state_id,'skip')
	end


	shared do |s|
		s.transform('Fill other columns',Fill,{
			notes: 'DXT-3592: IA CSA'
		})
		.transform('Set entity_type to lowercase',WithBlock) do |row|
			row[:entity_type] = row[:entity_type].to_s.downcase
			row
		end
		.transform('Trim values to 6 places after the decimal',WithBlock) do |row|
			row[:value] = sprintf('%.6f', row[:value]).to_f.to_s
			row
		end
		.transform('Assign date_valid based on year',WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2018-2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2016-2017'
				row[:date_valid] = '2018-01-01 00:00:00'
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	end


	def config_hash
	{
		source_id: 19,
		state: 'ia'
	}
	end
end

IAMetricsProcessor2019CSA.new(ARGV[0],max:nil).run