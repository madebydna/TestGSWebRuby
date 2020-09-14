require_relative '../../metrics_processor'

class MNMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3616'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'American Indian/Alaskan Native Students' => 18,
		'Asian Students' => 16,
        'Black Students' => 17,
        'English Learner Students' => 32,
		'Female Students' => 26,
		'Hispanic Students' => 19,
		'Male Students' => 25,
		'Non-English Learner Students' => 33,
        'Non-Special Education Students' => 30,
        'Pacific Islander/Native Hawaiian Students' => 20,
		'Special Education Students' => 27,
		'Students Eligible for Free/Reduced Priced Meals' => 23,
		'Students Not Eligible for Free/Reduced Priced Meals' => 24,
		'Two or More Races Students' => 22,
        'White Students' => 21
	}

	map_subject_id = {
		'English' => 17,
		'Math' => 5,
		'Reading' => 2,
		'Science' => 19,
        'Composite' => 1,
		'Not Applicable' => 0,
		'Any Subject' => 89
    }

	source('Grad_Rate_State.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'state',
          state_id: 'state',
          data_type: 'grad rate',
          data_type_id: 443,
          grade: 'NA',
          subject: 'Not Applicable',
          year: 2019,
          date_valid: '2019-01-01 00:00:00'
        })
        .transform('rename columns',MultiFieldRenamer,{
            four_year_total: :cohort_count,
            four_year_percent: :value,
            demographic_description: :breakdown
        })
        .transform('delete unwanted subject breakdowns',DeleteRows,:breakdown,'Homeless Students','Migrant Students','Students with Limited or Interrupted Formal Education')
    end
    
    source('Grad_Rate_District.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'district',
          data_type: 'grad rate',
          data_type_id: 443,
          grade: 'NA',
          subject: 'Not Applicable',
          year: 2019,
          date_valid: '2019-01-01 00:00:00'
        })
        .transform('rename columns',MultiFieldRenamer,{
            four_year_total: :cohort_count,
            four_year_percent: :value,
            demographic_description: :breakdown
        })
        .transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0')
			row
		end
        .transform('delete unwanted subject breakdowns',DeleteRows,:breakdown,'Homeless Students','Migrant Students','Students with Limited or Interrupted Formal Education')
    end
    
    source('Grad_Rate_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          data_type: 'grad rate',
          data_type_id: 443,
          grade: 'NA',
          subject: 'Not Applicable',
          year: 2019,
          date_valid: '2019-01-01 00:00:00'
        })
        .transform('rename columns',MultiFieldRenamer,{
            four_year_total: :cohort_count,
            four_year_percent: :value,
            demographic_description: :breakdown
        })
        .transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0') + row[:school_number].gsub('.0','').rjust(3,'0')
			row
		end
        .transform('delete unwanted subject breakdowns',DeleteRows,:breakdown,'Homeless Students','Migrant Students','Students with Limited or Interrupted Formal Education')
	end

    source('ACT_Data.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
          grade: 'All',
          year: 2019,
          date_valid: '2019-01-01 00:00:00',
          breakdown: 'All Students'
        })
        .transform('rename columns',MultiFieldRenamer,{
            hs_name: :school_name,
            n: :cohort_count
        })
        .transform('Mark Minnesota Dept. of Education District rows for skipping', WithBlock) do |row|
			if row[:district_name] == 'MINNESOTA DEPT OF EDUCATION' and row[:school_name] == 'All Schools'
				row[:skip] = 'Skip'
			else
				row[:skip] = nil
			end
			row
        end
        .transform('delete skipped rows',DeleteRows,:skip,'Skip')
        .transform('assign entity type and create state_ids',WithBlock) do |row|
			if row[:analysis_level] == 'District'
				row[:entity_type] = 'district'
				row[:state_id] = row[:dist_tye_x].gsub('.0','').rjust(2,'0') + row[:dist_num_x].gsub('.0','').rjust(4,'0')
            else 
                row[:entity_type] = 'school'
				row[:state_id] = row[:dist_tye_y].gsub('.0','').rjust(2,'0') + row[:dist_num_y].gsub('.0','').rjust(4,'0') + row[:sch_num_y].gsub('.0','').rjust(3,'0')
			end
			row
        end
        .transform('setting subject, data_type, and data_type_id',WithBlock) do |row|
			if row[:variable] == 'Avg Eng'
                row[:subject] = 'English'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
			elsif row[:variable] == 'Avg Math'
                row[:subject] = 'Math'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
			elsif row[:variable] == 'Avg Reading'
                row[:subject] = 'Reading'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
			elsif row[:variable] == 'Avg Sci'
                row[:subject] = 'Science'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'Avg Comp'
                row[:subject] = 'Composite'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'CRB % Eng'
                row[:subject] = 'English'
                row[:data_type] = 'ACT % college ready'
                row[:data_type_id] = 454
            elsif row[:variable] == 'CRB % Math'
                row[:subject] = 'Math'
                row[:data_type] = 'ACT % college ready'
                row[:data_type_id] = 454
            elsif row[:variable] == 'CRB % Reading'
                row[:subject] = 'Reading'
                row[:data_type] = 'ACT % college ready'
                row[:data_type_id] = 454
            elsif row[:variable] == 'CRB % Sci'
                row[:subject] = 'Science'
                row[:data_type] = 'ACT % college ready'
                row[:data_type_id] = 454
            elsif row[:variable] == 'CRB % All Four'
                row[:subject] = 'Composite'
                row[:data_type] = 'ACT % college ready'
                row[:data_type_id] = 454
			else 
                row[:subject] = 'Error'
                row[:data_type] = 'Error'
                row[:data_type_id] = 'Error'
			end
			row
		end
	end

	source('Enrollment.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
            grade: 'NA',
            year: 2018,
            date_valid: '2018-01-01 00:00:00',
            breakdown: 'All Students',
            data_type: 'college enrollment',
            data_type_id: 412,
            subject: 'Not Applicable'
        })
        .transform('rename columns',MultiFieldRenamer,{
            hs_grads__percent_enroll_in_fall_in_mn: :value,
        })
        .transform('assign entity type and create state_ids',WithBlock) do |row|
            if row[:report_level] == 'State'
                row[:entity_type] = 'state'
                row[:state_id] = 'state'
            elsif row[:report_level] == 'District'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0')
            elsif row[:report_level] = 'School' 
                row[:entity_type] = 'school'
				row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0') + row[:school_number].gsub('.0','').rjust(3,'0')
            else
                row[:entity_type] = 'Error'
                row[:state_id] = 'Error'
            end
			row
        end   
    end

    source('Persistence.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
            grade: 'NA',
            year: 2018,
            date_valid: '2018-01-01 00:00:00',
            breakdown: 'All Students',
            data_type: 'college persistence',
            data_type_id: 409,
            subject: 'Not Applicable'
        })
        .transform('rename columns',MultiFieldRenamer,{
            hs_graduates_starting_college__year_1: :cohort_count,
            hs_graduates_persisting__percent_2nd_academic_year: :value
        })
        .transform('assign entity type and create state_ids',WithBlock) do |row|
            if row[:report_level] == 'State'
                row[:entity_type] = 'state'
                row[:state_id] = 'state'
            elsif row[:report_level] == 'District'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0')
            elsif row[:report_level] = 'School' 
                row[:entity_type] = 'school'
				row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0') + row[:school_number].gsub('.0','').rjust(3,'0')
            else
                row[:entity_type] = 'Error'
                row[:state_id] = 'Error'
            end
			row
        end   
    end

    source('Remediation.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
            grade: 'NA',
            year: 2019,
            date_valid: '2019-01-01 00:00:00',
            breakdown: 'All Students',
            data_type: 'college remediation',
            data_type_id: 413,
            subject: 'Any Subject'
        })
        .transform('rename columns',MultiFieldRenamer,{
            pct_of_hs_grads_enrolled_in_dev_ed_in_first_or_second_fall_term: :value
        })
        .transform('assign entity type and create state_ids',WithBlock) do |row|
            if row[:report_level] == 'State'
                row[:entity_type] = 'state'
                row[:state_id] = 'state'
            elsif row[:report_level] == 'District'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0')
            elsif row[:report_level] = 'School' 
                row[:entity_type] = 'school'
				row[:state_id] = row[:district_type].gsub('.0','').rjust(2,'0') + row[:district_number].gsub('.0','').rjust(4,'0') + row[:school_number].gsub('.0','').rjust(3,'0')
            else
                row[:entity_type] = 'Error'
                row[:state_id] = 'Error'
            end
			row
        end   
    end

    shared do |s|
		s.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3616: MN CSA'
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
		source_id: 27,
        state: 'mn'
	}
	end
end

MNMetricsProcessor2019CSA.new(ARGV[0],max:nil).run