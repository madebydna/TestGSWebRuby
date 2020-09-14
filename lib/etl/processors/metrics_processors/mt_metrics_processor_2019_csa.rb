require_relative '../../metrics_processor'

class MTMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3625'
	end

	map_breakdown_id = {
		'all' => 1,
		'asian' => 16,
		'black' => 17,
        'female' => 26,
        'frl' => 23,
		'hispanic' => 19,
		'lep' => 32,
		'male' => 25,
		'multiracial' => 22,
        'nativeamerican' => 18,
        'nonfrl' => 24,
		'nonlep' => 33,
		'nonswd' => 30,
		'pacificislander' => 20,
		'swd' => 27,
        'white' => 21
	}

	map_subject_id = {
		'Average Composite Score' => 1,
		'Average English Score' => 17,
		'Average Math Score' => 5,
		'Average Reading Score' => 2,
        'Average Science Score' => 19,
        'Composite Score' => 1,
        'English Score' => 17,
        'Math Score' => 5,
        'Reading Score' => 2,
        'Science Score' => 19,
		'Not Applicable' => 0,
		'Any Subject' => 89
	}

	source('ACT_Perf_State.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
          entity_type: 'state',
          state_id: 'state',
          data_type: 'average ACT score',
          data_type_id: 448,
          grade: 'All'
        })
        .transform('delete unwanted subject rows',DeleteRows,:subject,'English Language Arts (ELA) Score','STEM Score','Writing Subject Score')
	end

    source('ACT_Perf_District_School.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
          data_type: 'average ACT score',
          data_type_id: 448,
          grade: 'All'
        })
        .transform('rename columns',MultiFieldRenamer,{
            district_name_id: :district_name,
            school_name_id: :school_name
        })
        .transform('delete unwanted subject rows',DeleteRows,:subject,'Average English Language Arts (ELA) Score','Average STEM Score','Average Writing Subject Score')
        .transform('assign entity type and create state_ids',WithBlock) do |row|
			if row[:school_name].nil?
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
            else 
                row[:entity_type] = 'school'
				row[:state_id] = row[:school_id]
			end
			row
		end
	end

	source('Grad_Rate_State.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
            data_type: 'graduation rate',
            data_type_id: 443,
            grade: 'NA',
            subject: 'Not Applicable',
            entity_type: 'state',
            state_id: 'state'
        })
        .transform('rename columns',MultiFieldRenamer,{
            year: :school_year
        })
		.transform('delete unwanted school year rows',DeleteRows,:school_year,'2014-2015 Graduation Rate','2015-2016 Graduation Rate','2016-2017 Graduation Rate','2017-2018 Graduation Rate')
	end

	source('Grad_Rate_District_School.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
            data_type: 'graduation rate',
            data_type_id: 443,
            grade: 'NA',
            subject: 'Not Applicable'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
            year: :school_year,
			district_name_id: :district_name,
            school_name_id: :school_name
        })
        .transform('delete unwanted school year rows',DeleteRows,:school_year,'2014-2015 Graduation Rates','2015-2016 Graduation Rates','2016-2017 Graduation Rates','2017-2018 Graduation Rates')
		.transform('assign entity type and create state_ids',WithBlock) do |row|
            if row[:school_id] == '-'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
            else 
                row[:entity_type] = 'school'
				row[:state_id] = row[:school_id]
			end
			row
		end
	end

	source('Enroll_Remediation_State.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			grade: 'NA',
            entity_type: 'state',
            state_id: 'state'
        })
        .transform('delete unwanted school year rows',DeleteRows,:hs_senior_year,'2016-2017','2017-2018')
        .transform('setting data_type, data_type_id, subject, and cohort counts',WithBlock) do |row|
			if row[:variable][/ps_enroll_rate/]
				row[:data_type] = 'enrollment rate'
				row[:data_type_id] = 487
				row[:subject] = 'Not Applicable'
				row[:cohort_count] = row[:hs_grads]
			elsif row[:variable][/remed_enroll_rate/]
				row[:data_type] = 'remediation rate'
				row[:data_type_id] = 413
				row[:subject] = 'Any Subject'
                row[:cohort_count] = row[:ps_enrollees]
			else
				row[:data_type] = 'Error'
                row[:data_type_id] = 'Error'
                row[:cohort_count] = 'Error'
			end
			row
		end
    end
    
    source('Enroll_Remediation_District_School.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			grade: 'NA'
        })
        .transform('rename columns',MultiFieldRenamer,{
            entity_level: :entity_type,
			state_id_x: :school_state_id,
            state_id_y: :district_state_id
        })
        .transform('delete unwanted school year rows',DeleteRows,:hs_senior_year,'2016-2017','2017-2018')
        .transform('delete unwanted county rows',DeleteRows,:entity_type,'county')
        .transform('setting data_type, data_type_id, subject, and cohort counts',WithBlock) do |row|
			if row[:variable][/ps_enroll_rate/]
				row[:data_type] = 'enrollment rate'
				row[:data_type_id] = 487
				row[:subject] = 'Not Applicable'
				row[:cohort_count] = row[:hs_grads]
			elsif row[:variable][/remed_enroll_rate/]
				row[:data_type] = 'remediation rate'
				row[:data_type_id] = 413
				row[:subject] = 'Any Subject'
                row[:cohort_count] = row[:ps_enrollees]
			else
				row[:data_type] = 'Error'
                row[:data_type_id] = 'Error'
                row[:cohort_count] = 'Error'
			end
			row
        end
        .transform('assign entity type and create state_ids',WithBlock) do |row|
            if row[:entity_type] == 'school'
				row[:state_id] = row[:school_state_id]
            elsif row[:entity_type] == 'district'
                row[:state_id] = row[:district_state_id]
            else
                row[:entity_type] = 'Error'
                row[:state_id] = 'Error'
			end
			row
        end
    end

    shared do |s|
		s.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3625: MT CSA',
			year: 2019,
	        date_valid: '2019-01-01 00:00:00'
		})
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
        .transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
        .transform('delete blank values',DeleteRows,:value,nil)
        .transform('Adjust values', WithBlock) do |row|
            row[:value] = row[:value].gsub("%","")
            row
        end
        .transform('Fix state state_id for Two Eagle River School and its district',WithBlock) do |row|
			if row[:state_id] == '9405'
				row[:state_id] = 'D13C02D13C02'
			elsif row[:state_id] == '9396'
				row[:state_id] = 'D13C02'
			else
				row[:state_id] = row[:state_id]
			end
			row
		end
	end
    
	def config_hash
	{
		source_id: 30,
        state: 'mt'
	}
	end
end

MTMetricsProcessor2019CSA.new(ARGV[0],max:nil).run