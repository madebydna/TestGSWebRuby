require_relative "../../test_processor"

class MTTestProcessor2019SBAC < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2019
    @ticket_n = 'DXT-3424'
	end

	map_breakdown = {
		'All Students' => 1,
    'American Indian or Alaskan Native' => 18,
    'Asian' => 16,
    'Black or African American' => 17,
    'Economically Disadvantaged' => 23,
    'Hispanic' => 19, 
    'Multi-Racial'=> 22, 
    'White' => 21
	}
  map_sub = {
    'ELA' => 4,
    'Math' => 5
  }

  map_prof = {
    "prof and above" => 1,
  }

 source("mt_2018_2019.txt",[], col_sep: "\t")


shared do |s|
   s.transform("Fill Columns",Fill,
     {
       data_type_id: 232,
       notes:'DXT-3424 MT MT SBAC'
     })
    .transform("set description", WithBlock) do |row|
        if row[:year] == '2018'
              row[:date_valid] ='2018-01-01 00:00:00'
              row[:description] = 'In 2017-2018, students in Montana took the SBAC assessment, which measures grades 3-8 in ELA and Math.'    
        elsif row[:year] == '2019'
              row[:date_valid] ='2019-01-01 00:00:00'
              row[:description] = 'In 2018-2019, students in Montana took the SBAC assessment, which measures grades 3-8 in ELA and Math.'
        end
        row
    end 
    .transform("mapping breakdown ids", HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_sub, to: :subject_id)
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, map_prof, to: :proficiency_band_id)
 end


	def config_hash
		{
			source_id:30,
			state:'mt'
    }
	end
end

MTTestProcessor2019SBAC.new(ARGV[0],max:nil,offset:nil).run
