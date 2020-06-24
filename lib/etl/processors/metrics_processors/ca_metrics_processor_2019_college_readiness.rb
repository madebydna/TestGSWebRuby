require_relative '../../metrics_processor'

class CAMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3501'
	end

	map_breakdown_id = {
		'RB' => 17,
		'RI' => 18,
		'RA' => 16,
		'RF' => 38,
		'RH' => 19,
		'RP' => 37,
		'RT' => 22,
		'RW' => 21,
		'GM' => 25,
		'GF'=> 26,
		'SE' => 32,
		'SD' => 27,
		'SS' => 23,
		'TA' => 1
	}

	map_subject_id = {
		"PctERWBenchmark12" => 2,
		"PctERWBenchmark11" => 2,
		"PctMathBenchmark12" => 5,
		"PctMathBenchmark11" => 5,
		"PctBothBenchmark12" => 1,
		"PctBothBenchmark11" => 1,
		"AvgScrRead" => 2,
		"AvgScrEng" => 17,
		"AvgScrMath" => 5,
		"AvgScrSci" => 19,
		"CompositeAvgScr" => 1,
		"PctGE21" => 1
	}

	source('transposed_cohort1819.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			notes: 'DXT-3501: CA College Readiness',
			grade: 'NA',
			subject: 'Not Applicable'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			districtcode: :district_id,
			schoolcode: :school_id,
			districtname: :district_name,
			schoolname: :school_name,
			reportingcategory: :breakdown
		})
		.transform('delete unwanted aggregate level rows',DeleteRows,:aggregatelevel,'C')
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'SM','SF','SH','RD')
		.transform('delete unwanted Charter School rows',DeleteRows,:charterschool,'Yes','No ')
		.transform('delete unwanted DASS rows',DeleteRows,:dass,'Yes','No ')
		.transform('delete unwanted school rows',DeleteRows,:school_name,'Nonpublic, Nonsectarian Schools')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('setting entity type and state_id',WithBlock) do |row|
			if row[:aggregatelevel] == 'T'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:aggregatelevel] == 'D'
				row[:entity_type] = 'district'
				row[:state_id] = row[:countycode] + row[:district_id]
			elsif row[:aggregatelevel] == 'S' and row[:school_name] != "District Office"
				row[:entity_type] = 'school'
				row[:state_id] = row[:countycode] + row[:district_id] + row[:school_id]
			else
				row[:row_suppressed] = 'skip'
			end
			row
		end
		.transform('setting data_type, data_type_id, and cohort_count',WithBlock) do |row|
			if row[:variable] == "Regular HS Diploma Graduates (Rate)"
				row[:data_type] = 'grad rate'
				row[:data_type_id] = 443
				row[:cohort_count] = row[:cohortstudents]
			elsif row[:variable] == "Met UC/CSU Grad Req's (Rate)"
				row[:data_type] = 'UC/CSU grad rate'
				row[:data_type_id] = 464
				row[:cohort_count] = row[:regular_hs_diploma_graduates_count]
			end
			row
		end
		.transform('delete blank values',DeleteRows,:value,'*')
		.transform('skip suppressed rows',DeleteRows,:row_suppressed,'skip')
	end

	source('transposed_sat19.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			notes: 'DXT-3501: CA College Readiness',
			data_type: 'SAT percent college ready',
			data_type_id: 442,
			breakdown_id: 1
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			cdcode: :district_id,
			dname: :district_name,
			sname: :school_name,
			variable: :subject
		})
		.transform('delete unwanted Rtype rows',DeleteRows,:rtype,'C')
		.transform('delete blank values',DeleteRows,:value,'*','N/A',nil)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('setting entity type and state_id',WithBlock) do |row|
			if row[:rtype] == 'X'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:rtype] == 'D'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
			elsif row[:rtype] == 'S'
				row[:entity_type] = 'school'
				row[:state_id] = row[:cds]
			end
			row
		end
		.transform('setting grade level and cohort_count',WithBlock) do |row|
			if row[:subject].include? '11'
				row[:grade] = '11'
				row[:cohort_count] = row[:numtsttakr11]
			elsif row[:subject].include? '12'
				row[:grade] = '12'
				row[:cohort_count] = row[:numtsttakr12]
			end
			row
		end
	end

	source('transposed_act19.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			notes: 'DXT-3501: CA College Readiness',
			breakdown_id: 1,
			grade: "All"
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			cdcode: :district_id,
			dname: :district_name,
			sname: :school_name,
			variable: :subject,
			numtsttakr: :cohort_count
		})
		.transform('delete unwanted Rtype rows',DeleteRows,:rtype,'C')
		.transform('delete blank values',DeleteRows,:value,'*','N/A','#DIV/0!',nil)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('setting entity type and state_id',WithBlock) do |row|
			if row[:rtype] == 'X'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:rtype] == 'D'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
			elsif row[:rtype] == 'S'
				row[:entity_type] = 'school'
				row[:state_id] = row[:cds]
			end
			row
		end
		.transform('setting data_type and data_type_id',WithBlock) do |row|
			if row[:subject] == "PctGE21"
				row[:data_type] = 'ACT percent college ready'
				row[:data_type_id] = 454
			else
				row[:data_type] = 'ACT average score'
				row[:data_type_id] = 448
			end
			row
		end
	end

	source('transposed_cgr12mo18.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			notes: 'DXT-3501: CA College Readiness',
			data_type: 'college enrollment',
			data_type_id: 474,
			grade: 'NA',
			subject: 'Not Applicable'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			districtcode: :district_id,
			schoolcode: :school_id,
			districtname: :district_name,
			schoolname: :school_name,
			reportingcategory: :breakdown,
			high_school_completers: :cohort_count
		})
		.transform('delete unwanted aggregate level rows',DeleteRows,:aggregatelevel,'C')
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'SM','SF','SH','RD')
		.transform('delete unwanted Charter School rows',DeleteRows,:charterschool,'Yes','No ')
		.transform('delete unwanted Alternative School Accountability Status rows',DeleteRows,:alternativeschoolaccountabilitystatus,'Yes','No ')
		.transform('delete unwanted Completer Type rows',DeleteRows,:completertype,'AGY','AGN','NGC')
		.transform('delete unwanted school rows',DeleteRows,:school_name,'Nonpublic, Nonsectarian Schools')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('setting entity type and state_id',WithBlock) do |row|
			if row[:aggregatelevel] == 'T'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:aggregatelevel] == 'D'
				row[:entity_type] = 'district'
				row[:state_id] = row[:countycode] + row[:district_id]
			elsif row[:aggregatelevel] == 'S' and row[:school_name] != "District Office"
				row[:entity_type] = 'school'
				row[:state_id] = row[:countycode] + row[:district_id] + row[:school_id]
			else
				row[:row_suppressed] = 'skip'
			end
			row
		end
		.transform('delete blank values',DeleteRows,:value,'*')
		.transform('skip suppressed rows',DeleteRows,:row_suppressed,'skip')
	end

	def config_hash
	{
		source_id: 8,
        state: 'ca'
	}
	end
end

CAMetricsProcessor2019CSA.new(ARGV[0],max:nil).run