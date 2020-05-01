require_relative '../../metrics_processor'

class KYMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3464'
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
		'LEN' => 33
	}

	map_subject_id = {
		'Reading' => 2,
		'Math' => 5,
		'Composite' => 1
	}

	source('GROWTH_2018.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00'
	    })
	end

	source('GROWTH_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2019,
	      date_valid: '2019-01-01 00:00:00'
	    })
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			demographic: :breakdown,
			sch_number: :school_id,
			sch_name: :school_name,
			dist_number: :district_id,
			dist_name: :district_name
		})
		.transform('delete COOP value rows',DeleteRows,:district_id, '901','902','903','904','904','905','906','907','908','909')
		.transform('delete COOP value rows',DeleteRows,:school_name,'---COOP Total---')
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'CSG','HOM','MIG','ELM','ELN')
		.transform('transpose subject columns',Transposer,:subject,:value,:growth_rate,:rd_rate,:ma_rate)
		.transform('prepare to delete suppressed rows, rename subjects',WithBlock) do |row|
			if row[:subject] == :growth_rate
				row[:subject] = 'Composite'
				if row[:rate_suppressed] == 'Y' || row[:rate_suppressed].nil?
					row[:row_suppressed] = 'skip'
				end
			elsif row[:subject] == :rd_rate
				row[:subject] = 'Reading'
				if row[:rd_suppressed] == 'Y' || row[:rd_suppressed].nil?
					row[:row_suppressed] = 'skip'
				end
			elsif row[:subject] == :ma_rate
				row[:subject] = 'Math'
				if row[:ma_suppressed] == 'Y' || row[:ma_suppressed].nil?
					row[:row_suppressed] = 'skip'
				end
			end
			row
		end
		.transform('delete suppressed rows',DeleteRows,:row_suppressed,'skip')
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			notes: 'DXT-3464: KY Growth',
			grade: 'All'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			if row[:school_name] == '---State Total---'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:school_name] == '---District Total---'
				row[:entity_type] = 'district'
				row[:state_id] = row[:cntyno] + row[:district_id] + '000'
			else row[:entity_type] = 'school'
				row[:state_id] = row[:cntyno] + row[:district_id] + row[:school_id]
			end
			row
		end
		.transform('loading cohort count',WithBlock) do |row|
			if row[:year] == 2018
				row[:cohort_count] = row[:count]
			elsif row[:year] = 2019
				row[:cohort_count] = row[:rd_cnt]
			end
			row
		end
		.transform('assigning either elementary or middle school growth data types',WithBlock) do |row|
			if row[:level] == 'ES'
				row[:data_type_id] = 493
			elsif row[:level] == 'MS'
				row[:data_type_id] = 494
			end
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

KYMetricsProcessor2019Growth.new(ARGV[0],max:nil).run