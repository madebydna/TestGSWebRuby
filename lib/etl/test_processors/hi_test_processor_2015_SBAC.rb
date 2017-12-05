require_relative "../test_processor"
GS::ETL::Logging.disable


class HITestProcessor2015SBAC < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2015
	end

	source('HI_school.txt',[],col_sep:"\t") do |s|
		s.transform('entity_level',Fill,{
			entity_level:'school'
		})
	end
	source('SBA2014-15_state.txt',[],col_sep:"\t") do |s|
		s.transform('entity_level',Fill,{
			entity_level:'state',
			school_name:'state',
			school_id: 'state',
			state_id:'state',
		})
		.transform('total grade',WithBlock,) do |row|
			if row[:grade] == 'TOTAL'
				row[:grade] = 'All'
			else
				row[:grade]=row[:grade].split(' ').last
			end
			row	
			#require 'byebug'
			#byebug
		end
	end

	shared do |s|
		s.transform('transpose prof bands',Transposer,:proficiency_band,:value_float,:elametexceededachievementstandard,:mathmetexceededachievementstandard)
		.transform('subject',WithBlock,) do |row|
			if row[:proficiency_band] =~ /^ela/
			       row[:subject] = 'ELA'
				row[:subject_id] = 4
				row[:number_tested] = row[:elantested].tr('""','')
			elsif row[:proficiency_band] =~ /^math/
				row[:subject] = 'math'
				row[:subject_id] = 5
				row[:number_tested] = row[:mathntested].tr('""','')
			end
		row
		end	
		.transform('rename headers',MultiFieldRenamer,{
		schoolcode: :school_id,
		schoolname: :school_name
		})
		.transform('remove %',WithBlock,) do |row|
			row[:value_float] = row[:value_float].tr('%','')
			#require 'byebug'
			#byebug
			row
		end
		.transform('delete value float = *',DeleteRows,:value_float,'*')
		.transform('fill other',Fill,{
		breakdown:'All',
		breakdown_id:'1',
		district_name: 'hawaii district',
		district_id: 'hawaii district id',
		year: 2015,
		level_code: 'e,m,h',
		entity_type: 'public_charter',
		test_data_type: 'SBAC',
		test_data_type_id: 313,
		proficiency_band_id: 'null'
		})
	end

	def config_hash
	{
		source_id:14,
		state: 'hi',
		notes: 'DXT-1757 HI SBAC 2015',
		url: 'http://www.hawaiipublicschools.org/',
		file: 'hi/2015/hi.2015.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
	}
	end

end
HITestProcessor2015SBAC.new(ARGV[0],max:nil).run
