require_relative "../test_processor"
#GS::ETL::Logging.disable

class XXTestProcessor201xTestName < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 201x
	end

	source('filename.txt',[],col_sep:'\t') do |s|
		s.tranform({
		}
	end)

	shared do |s|
		s.tranform()
	end

	def config_hash
		{
		source_id: ,
		state: 'xx',
		notes: 'DXT-xxxx XX Test 201x',
		url: 'http://www.xxdoe.org/',
		file: 'xx/201x/xx.201x.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

XXTestProcessor201xTestName.new(ARGV[0],max:20,offset:nil).run
