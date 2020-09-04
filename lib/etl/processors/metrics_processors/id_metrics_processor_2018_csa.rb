require_relative '../../metrics_processor'

class IDMetricsProcessor2018CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3580'
	end


	source('enroll_school.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			year: 2018,
			date_valid: '2018-01-01 00:00:00',
			entity_type: 'school',
			data_type: 'college enrollment',
			data_type_id: 412,
			notes: 'DXT-3580: ID CSA',
			subject: 'NA',
			subject_id: 0,
			breakdown: 'All',
			breakdown_id: 1,
			grade: 'NA'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			districtid: :district_id,
			school_district: :district_name,
			schoolid: :school_id,
			high_school: :school_name,
			go_on: :value
		})
		.transform('multiplying the values by 100',WithBlock) do |row|
			row[:value] = (row[:value].to_f*100).to_s
			row
		end
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id] + row[:school_id]
			row
		end
	end

	source('persist_school.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			year: 2018,
			date_valid: '2018-01-01 00:00:00',
			entity_type: 'school',
			data_type: 'college persistence',
			data_type_id: 409,
			notes: 'DXT-3580: ID CSA',
			subject: 'NA',
			subject_id: 0,
			breakdown: 'All',
			breakdown_id: 1,
			grade: 'NA'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			highschoolid: :school_id,
			val: :value
		})
		.transform('multiplying the values by 100',WithBlock) do |row|
			row[:value] = row[:value][0..-2]
			row
		end
	end

	def config_hash
	{
		source_id: 71,
        state: 'id'
	}
	end
end

IDMetricsProcessor2018CSA.new(ARGV[0],max:nil).run