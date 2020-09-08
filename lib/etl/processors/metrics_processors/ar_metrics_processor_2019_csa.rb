require_relative '../../metrics_processor'

class ARMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3404'
	end

	map_breakdown_id = {
        # ACT/SAT files
        'All Students' => 1,
        # grad rate files
		'Overall Grad Rate' => 1,
		'Hispanic Grad Rate' => 19,
		'Native American Grad Rate' => 18,
        'Asian Grad Rate' => 16,
        'African American Grad Rate' => 17,
		'Hawaiian/Pacific Islander Grad Rate' => 20,
		'Caucasian Grad Rate' => 21,
		'Two or More Grad Rate' => 22,
		'Economic Disadvantage Grad Rate' => 23,
        'SPED Grad Rate' => 27,
        'ELL Grad Rate' => 32,
        'LEP Grad Rate' => 32,
        # enrollment files
		'College Going Rate All Students ' => 1,
		' College Going Rate Black/African American' => 17,
		' College Going Rate Economically Disadvantaged' => 23,
        ' College Going Rate Hispanic/Latino' => 19,
        ' College Going Rate LEP' => 32,
        ' College Going Rate SPED' => 27,
        ' College Going Rate White' => 21
	}

	map_subject_id = {
        # ACT/SAT files
        'Composite' => 1,
		'English' => 17,
		'Math' => 5,
		'Reading' => 2,
        'Science' => 19,
        # remediation files
        'Any Subject' => 89,
        # grad rate and enrollment files
        'Not Applicable' => 0
    }

	source('ACT_SAT_District.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'district',
          breakdown: 'All Students',
          grade: 'All',
          year: 2019,
          date_valid: '2019-01-01 00:00:00'
        })
        .transform('rename columns',MultiFieldRenamer,{
            district_lea: :state_id,
            district_decription: :district_name
        })
        .transform('setting subject, data_type, and data_type_id',WithBlock) do |row|
			if row[:variable] == 'Percent who Took ACT'
                row[:subject] = 'Composite'
                row[:data_type] = 'ACT participation rate'
                row[:data_type_id] = 396
			elsif row[:variable] == 'ACT Average Composite Score'
                row[:subject] = 'Composite'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
			elsif row[:variable] == 'ACT Average English Scale Score'
                row[:subject] = 'English'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
			elsif row[:variable] == 'ACT Average Scale Score Mathematics'
                row[:subject] = 'Math'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'ACT Average Scale Score  Reading'
                row[:subject] = 'Reading'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'ACT Average Scale Score  Science'
                row[:subject] = 'Science'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'Percent Who Took SAT'
                row[:subject] = 'Composite'
                row[:data_type] = 'SAT participation rate'
                row[:data_type_id] = 439
            elsif row[:variable] == 'SAT Average Total Score'
                row[:subject] = 'Composite'
                row[:data_type] = 'SAT average score'
                row[:data_type_id] = 446
            elsif row[:variable] == 'SAT Average Math Score'
                row[:subject] = 'Math'
                row[:data_type] = 'SAT average score'
                row[:data_type_id] = 446
            elsif row[:variable] == 'SAT Average Reading Score'
                row[:subject] = 'Reading'
                row[:data_type] = 'SAT average score'
                row[:data_type_id] = 446
			else 
                row[:subject] = 'Error'
                row[:data_type] = 'Error'
                row[:data_type_id] = 'Error'
			end
			row
        end
        .transform('prepare to delete invalid ACT scores from Division of Youth Services School System',WithBlock) do |row|
            if row[:data_type_id].to_i == 448 and row[:state_id] == '6094000'
                row[:skip] = 'Skip'
            else
                row[:skip] = 'NULL'
            end
			row
        end
        .transform('delete skip values',DeleteRows,:skip,'Skip')
        .transform('trim to 6 places after the decimal',WithBlock) do |row|
			row[:value] = row[:value].to_f.truncate(6)
			row
		end
    end

    source('ACT_SAT_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          breakdown: 'All Students',
          grade: 'All',
          year: 2019,
          date_valid: '2019-01-01 00:00:00'
        })
        .transform('rename columns',MultiFieldRenamer,{
            school_lea: :state_id,
            school_description: :school_name,
            district_decription: :district_name
        })
        .transform('setting subject, data_type, and data_type_id',WithBlock) do |row|
			if row[:variable] == 'Percent who Took ACT'
                row[:subject] = 'Composite'
                row[:data_type] = 'ACT participation rate'
                row[:data_type_id] = 396
			elsif row[:variable] == 'ACT Average Composite Score'
                row[:subject] = 'Composite'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
			elsif row[:variable] == 'ACT Average English Scale Score'
                row[:subject] = 'English'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
			elsif row[:variable] == 'ACT Average Scale Score Mathematics'
                row[:subject] = 'Math'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'ACT Average Scale Score  Reading'
                row[:subject] = 'Reading'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'ACT Average Scale Score  Science'
                row[:subject] = 'Science'
                row[:data_type] = 'ACT average score'
                row[:data_type_id] = 448
            elsif row[:variable] == 'Percent Who Took SAT'
                row[:subject] = 'Composite'
                row[:data_type] = 'SAT participation rate'
                row[:data_type_id] = 439
            elsif row[:variable] == 'SAT Average Total Score'
                row[:subject] = 'Composite'
                row[:data_type] = 'SAT average score'
                row[:data_type_id] = 446
            elsif row[:variable] == 'SAT Average Math Score'
                row[:subject] = 'Math'
                row[:data_type] = 'SAT average score'
                row[:data_type_id] = 446
            elsif row[:variable] == 'SAT Average Reading Score'
                row[:subject] = 'Reading'
                row[:data_type] = 'SAT average score'
                row[:data_type_id] = 446
			else 
                row[:subject] = 'Error'
                row[:data_type] = 'Error'
                row[:data_type_id] = 'Error'
			end
			row
        end
        .transform('prepare to delete invalid ACT scores of 0',WithBlock) do |row|
            if row[:data_type_id].to_i == 448 and row[:value].to_i == 0
                row[:skip] = 'Skip'
            else
                row[:skip] = 'NULL'
            end
			row
        end
        .transform('delete skip values',DeleteRows,:skip,'Skip')
        .transform('trim to 6 places after the decimal',WithBlock) do |row|
			row[:value] = row[:value].to_f.truncate(6)
			row
		end
    end

    source('Grad_Rate_District.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'district',
          grade: 'NA',
          year: 2019,
          date_valid: '2019-01-01 00:00:00',
          data_type: 'grad rate',
          data_type_id: 443,
          subject: 'Not Applicable'
        })
        .transform('rename columns',MultiFieldRenamer,{
            district_lea: :state_id,
            district_decription: :district_name,
            variable: :breakdown
        })
        .transform('trim to 6 places after the decimal',WithBlock) do |row|
			row[:value] = row[:value].to_f.truncate(6)
			row
		end
    end

    source('Grad_Rate_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          grade: 'NA',
          year: 2019,
          date_valid: '2019-01-01 00:00:00',
          data_type: 'grad rate',
          data_type_id: 443,
          subject: 'Not Applicable'
        })
        .transform('rename columns',MultiFieldRenamer,{
            school_lea: :state_id,
            school_description: :school_name,
            district_decription: :district_name,
            variable: :breakdown
        })
        .transform('trim to 6 places after the decimal',WithBlock) do |row|
			row[:value] = row[:value].to_f.truncate(6)
			row
		end
    end

    source('Enrollment_District.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'district',
          grade: 'NA',
          year: 2019,
          date_valid: '2019-01-01 00:00:00',
          data_type: 'enrollment rate',
          data_type_id: 482,
          subject: 'Not Applicable'
        })
        .transform('rename columns',MultiFieldRenamer,{
            lea: :state_id,
            variable: :breakdown
        })
        .transform('normalize percents',WithBlock) do |row|
			row[:value] = (row[:value].to_f * 100).round(2)
			row
		end
    end

    source('Enrollment_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          grade: 'NA',
          year: 2019,
          date_valid: '2019-01-01 00:00:00',
          data_type: 'enrollment rate',
          data_type_id: 482,
          subject: 'Not Applicable'
        })
        .transform('rename columns',MultiFieldRenamer,{
            lea: :state_id,
            district_decription: :district_name,
            variable: :breakdown
        })
        .transform('normalize percents',WithBlock) do |row|
			row[:value] = (row[:value].to_f * 100).round(2)
			row
		end
    end

    source('Remediation_State.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'state',
          grade: 'NA',
          year: 2018,
          date_valid: '2018-01-01 00:00:00',
          data_type: 'remediation rate',
          data_type_id: 413,
          subject: 'Any Subject',
          state_id: 'state',
          breakdown: 'All Students'
        })
        .transform('rename columns',MultiFieldRenamer,{
            remediation_rates: :value
        })
        .transform('normalize percent and trim to 6 places after decimal',WithBlock) do |row|
            row[:value] = (row[:value].to_f * 100).truncate(6)
            row
        end
    end

    source('Remediation_District.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'district',
          grade: 'NA',
          year: 2018,
          date_valid: '2018-01-01 00:00:00',
          data_type: 'remediation rate',
          data_type_id: 413,
          subject: 'Any Subject',
          breakdown: 'All Students'
        })
        .transform('rename columns',MultiFieldRenamer,{
            district_lea: :state_id,
            college_remediation_rate: :value
        })
        .transform('normalize percents',WithBlock) do |row|
            row[:value] = (row[:value].to_f * 100).round(4)
            row
        end
    end

    source('Remediation_School.txt',[],col_sep:"\t") do |s|
        s.transform('Fill missing default fields', Fill, {
          entity_type: 'school',
          grade: 'NA',
          year: 2018,
          date_valid: '2018-01-01 00:00:00',
          data_type: 'remediation rate',
          data_type_id: 413,
          subject: 'Any Subject',
          breakdown: 'All Students'
        })
        .transform('rename columns',MultiFieldRenamer,{
            district_decription: :district_name,
            school_lea: :state_id,
            remediation_rates: :value
        })
        .transform('normalize percents',WithBlock) do |row|
            row[:value] = (row[:value].to_f * 100).round(4)
            row
        end
    end

    shared do |s|
		s.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3404: AR CSA'
        })
        .transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
        .transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end
    
	def config_hash
	{
		source_id: 7,
        state: 'ar'
	}
	end
end

ARMetricsProcessor2019CSA.new(ARGV[0],max:nil).run