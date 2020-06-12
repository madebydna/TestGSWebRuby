require_relative '../../metrics_processor'

class OKMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-2443'
	end

	map_breakdown_id = {
		'All' => 1,
		'EconomicDisadvantage_No' => 24,
		'EconomicDisadvantage_Yes' => 23,
		'ELL_No' => 33,
		'ELL_Yes' => 32,
		'IEP_No' => 30,
		'IEP_Yes' => 27,
		'Race_AmericanIndian' => 18,
		'Race_Asian' => 16,
		'Race_Black' => 17,
		'Race_Hispanic' => 19,
		'Race_White' => 21
	}

	map_subject_id = {
		'Composite' => 1,
		'ELA' => 4,
		'Mathematics' => 5
	}

	source('Growth2018_ReportCard.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
	      grade: 'All',
	      date_valid: '2018-01-01 00:00:00',
	      breakdown: 'All'
	    })
	end

	source('Growth2018_ReportSubgroup.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      date_valid: '2018-01-01 00:00:00'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			gradelevel: :grade,
			reportsubgroup: :breakdown
		})
		.transform('format grades',WithBlock) do |row|
	    	if row[:grade].include? 'All'
	    		row[:grade] = 'All'
	    	else
	    		row[:grade] = row[:grade].tr('0','')
	    	end
	    	row
	    end
	end

	source('Growth2019_ReportCard.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
	      grade: 'All',
	      date_valid: '2019-01-01 00:00:00',
	      breakdown: 'All'
	    })
	end

	source('Growth2019_ReportSubgroup.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      date_valid: '2019-01-01 00:00:00'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			gradelevel: :grade,
			reportsubgroup: :breakdown
		})
		.transform('format grades',WithBlock) do |row|
	    	if row[:grade].include? 'All'
	    		row[:grade] = 'All'
	    	else
	    		row[:grade] = row[:grade].tr('0','').tr(' ','')
	    	end
	    	row
	    end
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			schoolyear: :year,
			subjectgroup: :subject,
			indicatorvalue: :value,
			districtname: :district_name,
			schoolname: :school_name
		})
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'Race_Other','RegularEducation_No','RegularEducation_Yes')
		.transform('delete unwanted district rows',DeleteRows,:districtcode,'OTHP')
		.transform('delete suppressed rows',DeleteRows,:value,'s')
		.transform('standardize 2018 values',WithBlock) do |row|
			if row[:year] == '2018'
				row[:value] = '%.2f' % (row[:value].to_f * 100)
			end
			row
		end
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			data_type_id: 447,
			notes: 'DXT-2443: OK Growth',
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			if row[:educationagencytype] == 'State'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:educationagencytype] == 'District'
				row[:entity_type] = 'district'
				row[:state_id] = row[:countycode].rjust(2,'0') + '-' + row[:districtcode]
			else row[:entity_type] = 'school'
				row[:state_id] = row[:countycode].rjust(2,'0') + '-' + row[:districtcode] + '-' + row[:sitecode]
			end
			row
		end
	end

	def config_hash
	{
		source_id: 41,
        state: 'ok'
	}
	end
end

OKMetricsProcessor2019Growth.new(ARGV[0],max:nil).run