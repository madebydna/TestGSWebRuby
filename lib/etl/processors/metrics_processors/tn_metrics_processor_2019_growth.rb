require 'set'
require_relative '../../metrics_processor'

class TNMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3423'
	end

	 map_subject_id = {
	 	'Algebra I' => 6,
	 	'Algebra II' => 10,
		'Biology I' => 22,
		'Chemistry' => 35,
		'English I' => 17,
		'English II' => 21,
		'English III' => 49,
		'Geometry' => 8,
		'US History' => 23,
		'U.S. History' => 23,
		'Composite (Math/ELA/Science)' => 1,
		'English Language Arts' => 4,
		'Math' => 5,
		'Science' => 19,
		'Social Studies' => 18,
		'Integrated Math I' => 7,
		'Integrated Math II' => 9,
		'Integrated Math III' => 11,
		'Composite' => 1,
		'English' => 17,
		'Reading' => 2,
		'Science/Reasoning' => 19,
	}


	source('tvaas_district_subject_level_2019.txt',[],col_sep:",") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: '2019',
	      entity_type: 'district'
	    })
	    s.transform('Rename columns',MultiFieldRenamer, {
		  district_number: :district_id,
		  district: :district_name
		})
	end
	source('data_2018_TVAAS_District_Subject_Level.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: '2018',
	      entity_type: 'district'
	    })
	    s.transform('Rename columns',MultiFieldRenamer, {
		  district_number: :district_id,
		  district: :district_name
		})
	end
	source('tvaas_school_subject_level_2019.txt',[],col_sep:",") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: '2019',
	      entity_type: 'school'
	    })
	    s.transform('Rename columns',MultiFieldRenamer, {
		  district_number: :district_id,
		  district: :district_name,
		  school_number: :school_id,
		  school: :school_name
		})
	end
	source('data_2018_TVAAS_School_Subject_Level.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: '2018',
	      entity_type: 'school'
	    })
	    s.transform('Rename columns',MultiFieldRenamer, {
		  district_number: :district_id,
		  district: :district_name,
		  school_number: :school_id,
		  school: :school_name
		})
	end

	shared do |s|
		s.transform('Assign date_valid based on year',WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			end
			row
		end
		.transform('Rename columns',MultiFieldRenamer,{
		  number_of_students: :cohort_count,
		  index: :value
		})
		.transform('Create data type field', WithBlock) do |row|
			if row[:test] == 'ACT'
				row[:data_type] = 'Student Growth - ACT'
				row[:data_type_id] = 496
			elsif ['EOC','Grades 3-8'].include? row[:test]
				row[:data_type] = 'Student Growth'
				row[:data_type_id] = 447
			else
				row[:data_type] = 'Error'
				row[:data_type_id] = 'Error'
			end
			row
		end
		.transform('Create grade field', WithBlock) do |row|
			if row[:test] == 'ACT'
				row[:grade] = 'All'
			elsif row[:test] == 'EOC'
				row[:grade] = 'All'
			elsif row[:test] == 'Grades 3-8'
				if ['3','4','5','6','7','8'].include? row[:grade]
					row[:grade] = row[:grade]
				else
					row[:grade] = 'All'
				end
			end
			row
		end
		.transform('Padding school and district ids', WithBlock) do |row|
			row[:school_id] = '%04i' % (row[:school_id].to_i)
			row[:district_id] = '%03i' % (row[:district_id].to_i)
     		row
   		end
   		.transform("Creating state school and district ids", WithBlock) do |row|
   			if row[:entity_type] == 'district'
   				row[:state_id] = row[:district_id]
   			elsif row[:entity_type] == 'school'
				row[:state_id] = row[:district_id] + row[:school_id]
			else
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('Map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('remove "*"" value rows', DeleteRows, :value, '*')
		.transform('Fill other columns',Fill,{
			notes: 'DXT-3423: TN Growth',
			breakdown: 'All Students',
			breakdown_id: 1
		})
	end


	def config_hash
	{
		source_id: 47,
        state: 'tn'
	}
	end
end

TNMetricsProcessor2019Growth.new(ARGV[0],max:nil).run