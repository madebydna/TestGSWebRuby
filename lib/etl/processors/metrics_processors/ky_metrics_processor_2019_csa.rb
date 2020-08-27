require_relative '../../metrics_processor'

class KYMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3597'
	end

	map_breakdown_id = {
		'TST' => 1,
		'ACD' => 27,
		'ACO' => 30,
		'LUP' => 23,
		'LUN' => 24,
		'ETP' => 37,
		'ETI' => 18,
		'ETB' => 17,
		'ETH' => 19,
		'ETW' => 21,
		'ETO' => 22,
		'ETA' => 16,
		'SXF' => 26,
		'SXM' => 25,
		'LEP' => 32,
		'LEN' => 33,
		'African-American' => 17,
		'American Indian' => 18,
		'Asian' => 16,
		'English Learners' => 32,
		'Free/Reduced Price Lunch' => 23,
		'Hispanic' => 19,
		'Pacific Islander' => 37,
		'Total, All Students' => 1,
		'Two or More Races' => 22,
		'White' => 21,
		'Black' => 17
	}

	map_subject_id = {
		'AVG_COMP' => 1,
		'AVG_RD' => 2,
		'AVG_MA' => 5,
		'AVG_ENG' => 17,
		'AVG_SC' => 19,
		'Not Applicable' => 0
	}

	source('GraduationRate.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2019,
	      date_valid: '2019-01-01 00:00:00'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			demographic: :breakdown,
			sch_number: :school_id,
			sch_name: :school_name,
			dist_number: :district_id,
			dist_name: :district_name,
			cohort4yr: :cohort_count,
			gradrate4yr: :value
		})
		.transform('delete COOP value rows',DeleteRows,:school_name,'---COOP Total---')
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'MIG','HOM','ELM','CSG')
		.transform('fill other columns',Fill,{
			data_type: 'grad rate',
			data_type_id: 443,
			notes: 'DXT-3597: KY CSA',
			grade: 'NA',
			subject: 'Not Applicable'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			if row[:school_name] == '---State Total---'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:school_name] == '---District Total---'
				row[:entity_type] = 'district'
				row[:state_id] = row[:cntyno] + row[:district_id] + '000'
			else row[:entity_type] = 'school'
				row[:state_id] = row[:state_sch_id]
			end
			row
		end
	end

	source('CollegeAdmissionExam.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2019,
	      date_valid: '2019-01-01 00:00:00'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			variable: :subject,
			demographic: :breakdown,
			sch_number: :school_id,
			sch_name: :school_name,
			dist_number: :district_id,
			dist_name: :district_name,
			tested_bench: :cohort_count,
			gradrate4yr: :value
		})
		.transform('delete COOP value rows',DeleteRows,:school_name,'---COOP Total---')
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'MIL','MIG','HOM','ELM','CSG','FOS')
		.transform('fill other columns',Fill,{
			data_type: 'ACT Average score',
			data_type_id: 448,
			notes: 'DXT-3597: KY CSA',
			grade: 'All'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			if row[:school_name] == '---State Total---'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:school_name] == '---District Total---'
				row[:entity_type] = 'district'
				row[:state_id] = row[:cntyno] + row[:district_id] + '000'
			else row[:entity_type] = 'school'
				row[:state_id] = row[:state_sch_id]
			end
			row
		end
	end

	source('KYCSADataCollegeEnrollment.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			demographic: :breakdown,
			percent_enrolling_postsecondary: :value,
			number_graduates: :cohort_count
		})
		.transform('delete unwanted value rows',DeleteRows,:value,'<10')
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'Other/Unknown')
		.transform('fill other columns',Fill,{
			data_type: 'college enrollment',
			data_type_id: 481,
			notes: 'DXT-3597: KY CSA',
			grade: 'NA',
			subject: 'Not Applicable'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			if row[:sch_name] == 'State Total'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:sch_name] == 'District Total'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_state_id]
			else row[:entity_type] = 'school'
				row[:state_id] = row[:school_state_id]
			end
			row
		end
		.transform('normalize percents',WithBlock) do |row|
			row[:value] = '%.1f' % (row[:value].to_f * 100)
			row
		end
	end

	source('KYCSADataCollegePerformance.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			demographic: :breakdown,
			percent_grads_persisting_yr2: :value,
			number_enrolling_postsecondary: :cohort_count
		})
		.transform('delete unwanted value rows',DeleteRows,:value,'<10')
		.transform('fill other columns',Fill,{
			data_type: 'college persistence',
			data_type_id: 409,
			notes: 'DXT-3597: KY CSA',
			grade: 'NA',
			subject: 'Not Applicable'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			if row[:sch_name] == 'State Total'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:sch_name] == 'District Total'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_state_id]
			else row[:entity_type] = 'school'
				row[:state_id] = row[:school_state_id]
			end
			row
		end
		.transform('normalize percents',WithBlock) do |row|
			row[:value] = '%.1f' % (row[:value].to_f * 100)
			row
		end
	end

	def config_hash
	{
		source_id: 21,
        state: 'ky'
	}
	end
end

KYMetricsProcessor2019CSA.new(ARGV[0],max:nil).run