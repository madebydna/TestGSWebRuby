require_relative '../../metrics_processor'

class NDMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3564'
	end

	map_breakdown_id = {
        # ACT and Grad files
        'All' => 1,
		'Asian American' => 16,
		'Black' => 17,
		'English Learner' => 32,
        'Female' => 26,
        'Hispanic' => 19,
		'IEP (student with disabilities)' => 27,
		'Low Income' => 23,
		'Male' => 25,
		'Native American' => 18,
        'Native Hawaiian or Pacific Islander' => 20,
        'Two or More Races' => 22,
        'White' => 21,
        # Enrollment and Persistence files
        'All Students' => 1
	}

	map_subject_id = {
        # ACT files
        'Composite' => 1,
		'Language' => 17,
		'Mathematics' => 5,
		'Reading' => 2,
        'Science' => 19,
        # Grad rate, Enrollment, Persistence files
        'Not Applicable' => 0
    }

	source('ACT_State.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'state',
          state_id: 'state',
          grade: 'All',
          data_type: 'ACT average score',
          data_type_id: 448
        })
        .transform('rename columns',MultiFieldRenamer,{
            subgroup_desc: :breakdown,
            number_students_tested: :cohort_count,
            average_score: :value
        })
    end

    source('ACT_District.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'district',
          grade: 'All',
          data_type: 'ACT average score',
          data_type_id: 448
        })
        .transform('rename columns',MultiFieldRenamer,{
            entity_id: :state_id,
            entity_name: :district_name,
            subgroup_desc: :breakdown,
            number_students_tested: :cohort_count,
            average_score: :value
        })
    end

    source('ACT_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          grade: 'All',
          data_type: 'ACT average score',
          data_type_id: 448
        })
        .transform('rename columns',MultiFieldRenamer,{
            entity_id: :state_id,
            entity_name: :school_name,
            subgroup_desc: :breakdown,
            number_students_tested: :cohort_count,
            average_score: :value
        })
    end

    source('Grad_State.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'state',
          state_id: 'state',
          subject: 'Not Applicable',
          grade: 'NA',
          data_type: 'grad rate',
          data_type_id: 443
        })
        .transform('rename columns',MultiFieldRenamer,{
            subgroup_desc: :breakdown,
            student_count: :cohort_count
        })
        .transform('normalize percents and round to get to original values',WithBlock) do |row|
			row[:value] = (row[:traditional_graduation_rate].to_f * 100).round(1)
			row
		end
    end

    source('Grad_District.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'district',
          subject: 'Not Applicable',
          grade: 'NA',
          data_type: 'grad rate',
          data_type_id: 443
        })
        .transform('rename columns',MultiFieldRenamer,{
            district_id: :state_id,
            subgroup_desc: :breakdown,
            student_count: :cohort_count
        })
        .transform('normalize percents and round to get to original values',WithBlock) do |row|
			row[:value] = (row[:traditional_graduation_rate].to_f * 100).round(1)
			row
		end
    end

    source('Grad_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          subject: 'Not Applicable',
          grade: 'NA',
          data_type: 'grad rate',
          data_type_id: 443
        })
        .transform('rename columns',MultiFieldRenamer,{
            entity_id: :state_id,
            entity_name: :school_name,
            subgroup_desc: :breakdown,
            student_count: :cohort_count
        })
        .transform('normalize percents and round to get to original values',WithBlock) do |row|
			row[:value] = (row[:traditional_graduation_rate].to_f * 100).round(1)
			row
		end
    end

    source('Enrollment_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          breakdown: 'All Students',
          subject: 'Not Applicable',
          grade: 'NA',
          data_type: 'enrollment rate',
          data_type_id: 414
        })
        .transform('rename columns',MultiFieldRenamer,{
            hs_entity_name: :school_name,
            pct_enrolled: :value
        })
        .transform('padding state_id',WithBlock) do |row|
			row[:state_id] = row[:hs_institution_id].rjust(10,'0')
			row
		end
    end

    source('Persistence_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          breakdown: 'All Students',
          subject: 'Not Applicable',
          grade: 'NA',
          data_type: 'persistence rate',
          data_type_id: 409
        })
        .transform('rename columns',MultiFieldRenamer,{
            district: :district_name,
            high_school: :school_name,
            count: :cohort_count,
            entity_name: :school_name
        })
        .transform('padding state_id',WithBlock) do |row|
			row[:state_id] = row[:state_id].rjust(10,'0')
			row
        end
        .transform('normalize percents and round to get to original values',WithBlock) do |row|
			row[:value] = (row[:retention_rate].to_f * 100).round(1)
			row
		end
    end

    shared do |s|
		s.transform('Fill missing default fields', Fill, {
            notes: 'DXT-3564: ND CSA',
            year: 2019,
            date_valid: '2019-01-01 00:00:00'
        })
        .transform('fix cohort counts', WithBlock) do |row|
			unless row[:cohort_count].nil?
				row[:cohort_count] = row[:cohort_count].gsub('.0','')
			end
		    row
		end
        .transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
        .transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end
    
	def config_hash
	{
		source_id: 38,
        state: 'nd'
	}
	end
end

NDMetricsProcessor2019CSA.new(ARGV[0],max:nil).run